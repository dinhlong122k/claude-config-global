param(
    [string]$SkillPath = (Join-Path $PSScriptRoot '..')
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $SkillPath).Path
$issues = New-Object System.Collections.Generic.List[string]
$entry = Join-Path $root 'SKILL.md'
$extensionGuide = Join-Path $root 'references\governance\skill-extension-assumptions.md'

if (-not (Test-Path -LiteralPath $entry)) { throw "Thiếu SKILL.md: $entry" }
if (-not (Test-Path -LiteralPath $extensionGuide)) { $issues.Add('Thiếu quy ước mở rộng catalog.') }
$skillFiles = @(Get-ChildItem -LiteralPath $root -Recurse -File -Filter 'SKILL.md')
if ($skillFiles.Count -ne 1) { $issues.Add("Cần đúng một SKILL.md; hiện có $($skillFiles.Count).") }

$front = [IO.File]::ReadAllText($entry, [Text.UTF8Encoding]::new($false))
if ($front -notmatch '(?sm)^---\r?\n(?:(?!^---\s*$).)*^name:\s*developer-production\s*$' -or
    $front -notmatch '(?sm)^---\r?\n(?:(?!^---\s*$).)*^description:\s*\S.+$') {
    $issues.Add('Frontmatter thiếu name/description hợp lệ.')
}

$definitions = @{}
$docs = @(Get-ChildItem -LiteralPath $root -Recurse -File -Filter '*.md')
foreach ($file in $docs) {
    $body = [IO.File]::ReadAllText($file.FullName, [Text.UTF8Encoding]::new($false))
    foreach ($m in [regex]::Matches($body, '\]\(([^)]+)\)')) {
        $link = $m.Groups[1].Value.Split('#')[0]
        if ($link -eq '' -or $link -match '^[a-z]+://') { continue }
        $target = [IO.Path]::GetFullPath((Join-Path $file.DirectoryName $link))
        if (-not $target.StartsWith($root + '\', [StringComparison]::OrdinalIgnoreCase)) {
            $issues.Add("Link ra ngoài skill: $($file.FullName) -> $link")
        } elseif (-not (Test-Path -LiteralPath $target)) {
            $issues.Add("Link hỏng: $($file.FullName) -> $link")
        }
    }

    $isRuleOwner = $file.FullName -match '\\references\\(governance|architecture|controls|integrations|stacks)\\' -and
                   $file.Name -ne 'README.md'
    if (-not $isRuleOwner) { continue }
    if ($file.FullName -match '\\references\\(governance|architecture|controls)\\') {
        foreach ($section in [regex]::Matches($body, '(?ms)^##\s+([A-Z]+(?:-[A-Z]+)*-(?:O)?\d{2,3})\s+.*?(?=^##\s+|\z)')) {
            if ($section.Value -notmatch '\b(CRITICAL|OPTIONAL)\b') {
                $issues.Add("Rule thiếu phân loại: $($section.Groups[1].Value)")
            }
        }
    }
    foreach ($m in [regex]::Matches($body, '(?m)^(?:##\s+|\|\s*)([A-Z]+(?:-[A-Z]+)*-(?:O)?\d{2,3})(?:\s+|\s*\|)')) {
        $id = $m.Groups[1].Value
        if ($definitions.ContainsKey($id)) {
            $issues.Add("Rule ID trùng: $id ($($file.FullName))")
        } else {
            $definitions[$id] = $file.FullName
        }
    }
}

foreach ($file in $docs) {
    $body = [IO.File]::ReadAllText($file.FullName, [Text.UTF8Encoding]::new($false))
    foreach ($m in [regex]::Matches($body, '\b[A-Z]+(?:-[A-Z]+)*-(?:O)?\d{2,3}\b')) {
        $id = $m.Value
        if (-not $definitions.ContainsKey($id)) {
            $issues.Add("Rule ID chưa có owner: $id ($($file.FullName))")
        }
    }
}

foreach ($name in @('sftp','minio','keycloak','redis-cache','rate-limit','kafka')) {
    $path = Join-Path (Join-Path $root 'references\integrations') "$name.md"
    if (-not (Test-Path -LiteralPath $path)) {
        $issues.Add("Thiếu integration: $name")
        continue
    }
    $body = [IO.File]::ReadAllText($path, [Text.UTF8Encoding]::new($false))
    if ($body -notmatch '(?m)^## CRITICAL\s*$' -or $body -notmatch '(?m)^## OPTIONAL') {
        $issues.Add("Thiếu phân loại CRITICAL/OPTIONAL: $name")
    }
    if ([regex]::Matches($body, '(?m)^\|\s*[A-Z]+-\d{3}\s*\|').Count -eq 0 -or
        [regex]::Matches($body, '(?m)^\|\s*[A-Z]+-O\d{2}\s*\|').Count -eq 0) {
        $issues.Add("Thiếu rule CRITICAL hoặc OPTIONAL: $name")
    }
}

foreach ($name in @('java-spring','typescript-node','python','go')) {
    $path = Join-Path (Join-Path $root 'references\stacks') "$name.md"
    if (-not (Test-Path -LiteralPath $path)) {
        $issues.Add("Thiếu stack adapter: $name")
        continue
    }
    $body = [IO.File]::ReadAllText($path, [Text.UTF8Encoding]::new($false))
    if ($body -notmatch '(?m)^## CRITICAL\s*$' -or $body -notmatch '(?m)^## OPTIONAL') {
        $issues.Add("Thiếu phân loại CRITICAL/OPTIONAL: $name")
    }
}

if ($issues.Count -gt 0) {
    $issues | ForEach-Object { Write-Output $_ }
    exit 1
}
Write-Output "Hợp lệ: 1 SKILL.md, $($docs.Count) tài liệu, $($definitions.Count) rule ID duy nhất, 6 integrations, 4 stack adapters."
