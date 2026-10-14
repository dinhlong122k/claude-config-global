#!/usr/bin/env bash
# Install global Claude Code config (macOS/Linux/Git Bash). Re-run anytime to update.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
dest="${HOME}/.claude"
mkdir -p "$dest"
for d in agents hooks skills; do mkdir -p "$dest/$d"; cp -R "$here/$d/." "$dest/$d/"; done
[ -f "$dest/CLAUDE.md" ] && cp "$dest/CLAUDE.md" "$dest/CLAUDE.md.bak-$(date +%Y%m%d%H%M%S)"
cp "$here/CLAUDE.md" "$dest/CLAUDE.md"
printf %s "$here" > "$dest/.global-config-repo"
node "$here/merge-settings.js" "$here/settings.template.json" "$dest/settings.json" "$dest"
if command -v claude >/dev/null; then
  claude plugin install superpowers@claude-plugins-official || true
  claude plugin install caveman@anthropic-plugin-directory || true
fi
echo "Done. Also needed: node, codegraph CLI, then 'codegraph init' per project."
