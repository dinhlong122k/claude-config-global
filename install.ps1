# Install global Claude Code config. Usage: .\install.ps1   (re-run anytime to update)
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$home_ = Join-Path $env:USERPROFILE '.claude'
New-Item -ItemType Directory -Force $home_ | Out-Null
foreach ($d in 'agents','hooks','skills') {
    New-Item -ItemType Directory -Force (Join-Path $home_ $d) | Out-Null
    Copy-Item (Join-Path $here "$d\*") (Join-Path $home_ $d) -Recurse -Force
}
if (Test-Path "$home_\CLAUDE.md") { Copy-Item "$home_\CLAUDE.md" "$home_\CLAUDE.md.bak-$(Get-Date -Format yyyyMMddHHmmss)" }
Copy-Item "$here\CLAUDE.md" "$home_\CLAUDE.md" -Force
Set-Content -Path "$home_\.global-config-repo" -Value $here -Encoding ascii -NoNewline
node "$here\merge-settings.js" "$here\settings.template.json" "$home_\settings.json" $home_
if (Get-Command claude -ErrorAction SilentlyContinue) {
    claude plugin install superpowers@claude-plugins-official
    claude plugin install caveman@anthropic-plugin-directory
}
Write-Host "Done. Also needed: node, codegraph CLI (npm i -g @colbymchenry/codegraph), then 'codegraph init' per project."
