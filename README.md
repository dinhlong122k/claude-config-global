# claude-global-config

Global Claude Code config: CLAUDE.md, agents, hooks, skills, settings.

Install on any machine (needs `node`):

    git clone <this-repo> && cd claude-global-config
    ./install.ps1        # Windows
    ./install.sh         # macOS / Linux / Git Bash

Re-run after `git pull` to update. Existing settings.json is merged (backup `.bak-*` kept), never overwritten.

Not included on purpose: credentials, history, per-machine tools (orca hooks, statusLine, autoMode env), `skills/synced` (account-synced).
Requires `codegraph` CLI on PATH for the codegraph hooks.
