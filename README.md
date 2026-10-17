# claude-global-config

Global Claude Code config: CLAUDE.md, agents, hooks, skills, settings.

Install on any machine (needs `node`):

```
git clone <this-repo> && cd claude-global-config
./install.ps1        # Windows
./install.sh         # macOS / Linux / Git Bash
```

Re-run after `git pull` to update. Existing settings.json is merged (backup `.bak-*` kept), never overwritten.

Not included on purpose: credentials, history, per-machine tools (orca hooks, statusLine, autoMode env), `skills/synced` (account-synced).
Requires `codegraph` CLI on PATH for the codegraph hooks.

## Architecture — divide and conquer

| Layer | Owns | Never contains |
| --- | --- | --- |
| Plan / task files (`docs/…` in each project) | What to build: goal, scope, acceptance criteria, files, tests | Skill or agent names |
| `agents/` | Role, workflow, which skills to preload (`skills:` frontmatter), report contract | Detailed engineering rules |
| `skills/` | Engineering rules, loaded by trigger | Who dispatches whom, when to ask the user |
| `hooks/` | What must hold, enforced deterministically | Advice |

Usage: hand the main session a plan/task file and ask it to implement. `CLAUDE.md` routes execution to `task-executor`, which preloads `developer-production`; reviewers run at the end.

| Hook | Event | Enforces |
| --- | --- | --- |
| `codegraph-gate.js` | PreToolUse | Explore via CodeGraph (MCP or `codegraph explore`) before grepping code in indexed repos |
| `verify-on-stop.js` | SubagentStart/Stop (`task-executor`) | No placeholders / conflict markers in added code; report carries a `VERIFY:` block. Blocks once, fails open |
| `sync-back.js` | PostToolUse | Mirrors edits in `~/.claude` back into this repo |
| `caveman-on.js` | SessionStart | Terse reply style |

## Tests

```
node --test "tests/**/*.test.js"
```
