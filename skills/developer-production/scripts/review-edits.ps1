$ErrorActionPreference = 'Stop'

function Get-CodeFiles([string]$root) {
    $extensions = @('.c', '.cc', '.cpp', '.cs', '.css', '.go', '.h', '.hpp', '.html', '.java', '.js', '.json', '.jsx', '.kt', '.mjs', '.php', '.ps1', '.py', '.rs', '.scss', '.sql', '.swift', '.ts', '.tsx', '.vue', '.yaml', '.yml')
    $excluded = @('.git', '.claude', '.venv', 'bin', 'build', 'coverage', 'dist', 'node_modules', 'obj', 'target', 'vendor')
    $pending = New-Object System.Collections.Generic.Stack[string]
    $pending.Push($root)
    while ($pending.Count -gt 0) {
        $directory = $pending.Pop()
        foreach ($item in Get-ChildItem -LiteralPath $directory -Force -ErrorAction SilentlyContinue) {
            if ($item.PSIsContainer) {
                if ($item.Name -notin $excluded -and -not ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
                    $pending.Push($item.FullName)
                }
            } elseif (-not ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -and $item.Extension.ToLowerInvariant() -in $extensions) {
                $item
            }
        }
    }
}

function Get-Snapshot([string]$root) {
    $snapshot = @{}
    $sha256 = [Security.Cryptography.SHA256]::Create()
    try {
        foreach ($file in Get-CodeFiles $root) {
            $stream = [IO.File]::Open($file.FullName, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite)
            try {
                $digest = $sha256.ComputeHash($stream)
                $snapshot[$file.FullName] = -join ($digest | ForEach-Object { $_.ToString('x2') })
            } finally {
                $stream.Dispose()
            }
        }
    } finally {
        $sha256.Dispose()
    }
    return $snapshot
}

function Get-ProjectRoot([string]$cwd) {
    $directory = [IO.DirectoryInfo]::new([IO.Path]::GetFullPath($cwd))
    while ($null -ne $directory) {
        if (Test-Path -LiteralPath (Join-Path $directory.FullName '.claude\settings.json') -PathType Leaf) {
            return $directory.FullName
        }
        $directory = $directory.Parent
    }
    return $null
}

function ConvertTo-SnapshotTable($snapshot) {
    $table = @{}
    if ($null -ne $snapshot) {
        foreach ($property in $snapshot.PSObject.Properties) {
            $table[$property.Name] = [string]$property.Value
        }
    }
    return $table
}

function Get-ChangedPaths($baseline, $current) {
    return @($current.Keys | Where-Object { -not $baseline.ContainsKey($_) -or $baseline[$_] -ne $current[$_] } | Sort-Object)
}

function Get-PlanHash([string]$root) {
    $path = Join-Path $root 'docs\IMPLEMENTATION_PLAN.md'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return '' }
    return (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
}

function Get-ProductionCodeChanges([string[]]$changed, [string[]]$deleted, [string]$root) {
    $claudePath = (Join-Path $root '.claude').TrimEnd('\', '/') + '\'
    return @((@($changed) + @($deleted)) | Where-Object {
        $_ -and -not $_.StartsWith($claudePath, [StringComparison]::OrdinalIgnoreCase)
    })
}

function Check-Security([string[]]$changed, [string[]]$deleted, [string]$root) {
    $paths = @($changed | Where-Object { $_ }) + @($deleted | Where-Object { $_ })
    if ($paths.Count -eq 0) { return $null }
    $prefixLength = $root.TrimEnd('\', '/').Length
    $names = @($paths | ForEach-Object { $_.Substring($prefixLength).TrimStart('\', '/') } | Select-Object -First 30)
    $suffix = if ($paths.Count -gt 30) { " (and $($paths.Count - 30) more files)" } else { '' }
    $context = @"
check_security(): Code files changed in this tool call: $($names -join ', ')$suffix.
Decide whether the edit affects executable logic or security-sensitive configuration. If it does, delegate a read-only review of these files and their relevant callers/data flow to the security-reviewer custom agent, then wait for its findings. If that agent or its model is unavailable, perform the review yourself and say so. Use concrete evidence only; do not claim a scanner ran. Report findings with file:line, exploit scenario, and a short proposed fix, sorted HIGH -> MEDIUM -> LOW (fold CRITICAL into HIGH). Ask the user whether to fix them before making security fixes. If there are no findings, say so briefly. For formatting/comment-only edits, no security report is needed.
"@.Trim()
    $productionChanges = @(Get-ProductionCodeChanges $changed $deleted $root)
    if ($productionChanges.Count -gt 0) {
        $context += "`nRead docs/IMPLEMENTATION_PLAN.md and compare its flow with these code changes. If the plan is missing, create it from the agreed task. Update the plan before continuing with any changed flow; keep implementation within its scope. After a coherent batch of logic edits and before finishing, delegate a read-only comparison to plan-reviewer. If unavailable, compare the plan yourself and say so. Record the actual flow and unfinished steps in the plan."
    }
    return @{ hookSpecificOutput = @{ hookEventName = 'PostToolUse'; additionalContext = $context } }
}

function Get-StatePath([string]$sessionId, [string]$root) {
    $bytes = [Text.Encoding]::UTF8.GetBytes("$sessionId|$root")
    $digest = [Security.Cryptography.SHA256]::Create().ComputeHash($bytes)
    $key = -join ($digest | ForEach-Object { $_.ToString('x2') })
    $stateDir = Join-Path ([IO.Path]::GetTempPath()) 'developer-production-hooks'
    if (-not (Test-Path -LiteralPath $stateDir)) {
        [void](New-Item -ItemType Directory -Path $stateDir -Force)
    }
    return (Join-Path $stateDir "$key.json")
}

function Write-Json($value) {
    [Console]::Out.WriteLine(($value | ConvertTo-Json -Compress -Depth 8))
}

try {
    $inputText = [Console]::In.ReadToEnd()
    $event = $inputText | ConvertFrom-Json
    if ($event.permission_mode -eq 'plan') { Write-Json @{}; exit 0 }
    $root = Get-ProjectRoot ([string]$event.cwd)
    if ([string]::IsNullOrEmpty($root) -or -not (Test-Path -LiteralPath $root -PathType Container)) { exit 0 }
    $statePath = Get-StatePath ([string]$event.session_id) $root

    if ($event.hook_event_name -eq 'PreToolUse') {
        if (-not (Test-Path -LiteralPath $statePath)) {
            $snapshot = Get-Snapshot $root
            $state = @{ baseline = $snapshot; securityBaseline = $snapshot; planBaseline = (Get-PlanHash $root); reviewRequested = $false }
            $json = $state | ConvertTo-Json -Compress -Depth 8
            try {
                $stream = [IO.File]::Open($statePath, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
                try {
                    $writer = New-Object IO.StreamWriter($stream, [Text.UTF8Encoding]::new($false))
                    $writer.Write($json)
                    $writer.Flush()
                } finally {
                    $stream.Dispose()
                }
            } catch [IO.IOException] {
                # A parallel tool call already captured the same baseline.
            }
            Write-Json @{ hookSpecificOutput = @{ hookEventName = 'PreToolUse'; additionalContext = 'For developer-production code changes, read docs/IMPLEMENTATION_PLAN.md before editing. Create it if absent, follow its agreed flow, and update it before changing that flow. Use plan-reviewer after a coherent change batch and security-reviewer after each logic edit when available.' } }
        }
        exit 0
    }

    if ($event.hook_event_name -eq 'PostToolUse') {
        if (-not (Test-Path -LiteralPath $statePath)) { Write-Json @{}; exit 0 }
        $state = Get-Content -LiteralPath $statePath -Raw -Encoding UTF8 | ConvertFrom-Json
        $securityBaseline = if ($null -ne $state.securityBaseline) { $state.securityBaseline } else { $state.baseline }
        $baseline = ConvertTo-SnapshotTable $securityBaseline
        $current = Get-Snapshot $root
        $changed = @(Get-ChangedPaths $baseline $current)
        $deleted = @($baseline.Keys | Where-Object { -not $current.ContainsKey($_) } | Sort-Object)
        if ($null -ne $state.PSObject.Properties['securityBaseline']) {
            $state.securityBaseline = $current
        } else {
            $state | Add-Member -NotePropertyName securityBaseline -NotePropertyValue $current
        }
        [IO.File]::WriteAllText($statePath, ($state | ConvertTo-Json -Compress -Depth 8), [Text.UTF8Encoding]::new($false))
        $result = Check-Security $changed $deleted $root
        if ($null -ne $result) { Write-Json $result } else { Write-Json @{} }
        exit 0
    }

    if ($event.hook_event_name -ne 'Stop') { exit 0 }
    if (-not (Test-Path -LiteralPath $statePath)) { Write-Json @{}; exit 0 }
    $state = Get-Content -LiteralPath $statePath -Raw -Encoding UTF8 | ConvertFrom-Json
    $baseline = ConvertTo-SnapshotTable $state.baseline
    $current = Get-Snapshot $root
    $changed = @(Get-ChangedPaths $baseline $current)
    $deleted = @($baseline.Keys | Where-Object { -not $current.ContainsKey($_) } | Sort-Object)
    if ($changed.Count -eq 0 -and $deleted.Count -eq 0) {
        Remove-Item -LiteralPath $statePath -Force
        Write-Json @{}
        exit 0
    }

    $productionChanges = @(Get-ProductionCodeChanges $changed $deleted $root)
    if ($productionChanges.Count -gt 0) {
        $planPath = Join-Path $root 'docs\IMPLEMENTATION_PLAN.md'
        $planHash = Get-PlanHash $root
        $planText = if ($planHash) { [string](Get-Content -LiteralPath $planPath -Raw -Encoding UTF8) } else { '' }
        if (-not $planHash -or $planHash -eq [string]$state.planBaseline -or -not $planText.Trim()) {
            $reason = "Production code changed, but docs/IMPLEMENTATION_PLAN.md was not created or updated in this task. Read the implemented code flow, create/update the plan to match the agreed scope, record unfinished steps, then continue. Do not add code outside the plan."
            Write-Json @{ decision = 'block'; reason = $reason }
            exit 0
        }
    }

    $issues = New-Object System.Collections.Generic.List[string]
    $gofmt = Get-Command gofmt -ErrorAction SilentlyContinue
    $ruff = Get-Command ruff -ErrorAction SilentlyContinue
    $localRuff = Join-Path $root '.venv\Scripts\ruff.exe'
    if (-not $ruff -and (Test-Path -LiteralPath $localRuff)) { $ruff = $localRuff }
    $node = Get-Command node -ErrorAction SilentlyContinue
    $prettier = Join-Path $root 'node_modules\prettier\bin\prettier.cjs'
    foreach ($path in $changed) {
        $content = [IO.File]::ReadAllText($path, [Text.UTF8Encoding]::new($false))
        if ($content.Length -gt 0 -and -not $content.EndsWith("`n")) { $issues.Add("Missing final newline: $path") }
        $lines = $content -split "`r?`n"
        for ($index = 0; $index -lt $lines.Count; $index++) {
            if ($lines[$index] -match '[ \t]+$') {
                $issues.Add("Trailing whitespace: ${path}:$($index + 1)")
                if ($issues.Count -ge 20) { break }
            }
        }
        if ($path.EndsWith('.ps1', [StringComparison]::OrdinalIgnoreCase)) {
            $tokens = $null
            $parseErrors = $null
            [void][System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$parseErrors)
            foreach ($parseError in $parseErrors) { $issues.Add("PowerShell syntax: ${path}:$($parseError.Message)") }
        }
        $extension = [IO.Path]::GetExtension($path).ToLowerInvariant()
        if ($extension -eq '.json') {
            try { [void]($content | ConvertFrom-Json) }
            catch { $issues.Add("Invalid JSON: $path") }
        }
        if ($extension -eq '.go' -and $gofmt) {
            $unformatted = @(& $gofmt.Source -l $path)
            if ($unformatted.Count -gt 0) { $issues.Add("gofmt check failed: $path") }
        }
        if ($extension -eq '.py' -and $ruff) {
            $ruffCommand = if ($ruff -is [string]) { $ruff } else { $ruff.Source }
            $formatOutput = @(& $ruffCommand format --check $path 2>&1)
            if ($LASTEXITCODE -ne 0) { $issues.Add("ruff format check failed: $path ($($formatOutput -join ' '))") }
        }
        if ($extension -in @('.css', '.html', '.js', '.json', '.jsx', '.mjs', '.scss', '.ts', '.tsx', '.vue', '.yaml', '.yml') -and $node -and (Test-Path -LiteralPath $prettier)) {
            $formatOutput = @(& $node.Source $prettier --check $path 2>&1)
            if ($LASTEXITCODE -ne 0) { $issues.Add("Prettier check failed: $path ($($formatOutput -join ' '))") }
        }
    }

    if ($issues.Count -gt 0) {
        $reason = "Code quality checks found problems in changed files:`n" + ($issues | Select-Object -First 20 | Out-String)
        Write-Json @{ decision = 'block'; reason = $reason.Trim() }
        exit 0
    }

    if (-not [bool]$state.reviewRequested) {
        $state.reviewRequested = $true
        [IO.File]::WriteAllText($statePath, ($state | ConvertTo-Json -Compress -Depth 8), [Text.UTF8Encoding]::new($false))
        $names = (@($changed) + @($deleted) | Select-Object -First 20) -join ', '
        $planReview = if ($productionChanges.Count -gt 0) { 'Confirm plan-reviewer compared docs/IMPLEMENTATION_PLAN.md with the actual flow and that unfinished steps are marked; if unavailable, perform that comparison yourself and say so. ' } else { '' }
        $reason = "Review the changed code before finishing: $names. $planReview" + "Run the repository's formatter in check mode, relevant lint/static analysis and tests; inspect the diff for clarity, duplication, unused code and safe refactoring. Confirm security-reviewer checked each logic edit; if unavailable, review it yourself and say so. Report any findings HIGH -> MEDIUM -> LOW with file:line, evidence and proposed fix, then ask the user whether to fix them. Edit only with existing user authorization, then rerun relevant checks. Report commands and results."
        Write-Json @{ decision = 'block'; reason = $reason }
        exit 0
    }

    Remove-Item -LiteralPath $statePath -Force
    Write-Json @{}
} catch {
    [Console]::Error.WriteLine("Code review hook failed: $($_.Exception.Message)")
    exit 2
}
