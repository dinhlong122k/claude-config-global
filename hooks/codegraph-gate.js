#!/usr/bin/env node
// PreToolUse gate: in repos with .codegraph/, force one codegraph_explore call
// per session before Grep/Glob/Read/Bash-search on code files.
const fs = require('fs');
const os = require('os');
const path = require('path');

const EXPLORE = 'mcp__codegraph__codegraph_explore';
const NON_CODE = new Set([
  '.md', '.txt', '.json', '.yml', '.yaml', '.xml', '.properties', '.toml',
  '.ini', '.env', '.csv', '.log', '.lock', '.gradle', '.sql', '.html', '.css',
  '.svg', '.png', '.jpg', '.pdf',
]);

function findCodegraph(start) {
  let dir = path.resolve(start || process.cwd());
  for (;;) {
    if (fs.existsSync(path.join(dir, '.codegraph'))) return dir;
    const up = path.dirname(dir);
    if (up === dir) return null;
    dir = up;
  }
}

function isNonCodeTarget(s) {
  if (!s || typeof s !== 'string') return false;
  return NON_CODE.has(path.extname(s.trim()).toLowerCase());
}

function deny(reason) {
  process.stdout.write(JSON.stringify({
    hookSpecificOutput: {
      hookEventName: 'PreToolUse',
      permissionDecision: 'deny',
      permissionDecisionReason: reason,
    },
  }));
  process.exit(0);
}

let raw = '';
process.stdin.on('data', (c) => (raw += c));
process.stdin.on('end', () => {
  let input;
  try { input = JSON.parse(raw); } catch { process.exit(0); }

  const tool = input.tool_name;
  const ti = input.tool_input || {};
  const sid = String(input.session_id || 'nosession').replace(/[^\w-]/g, '_');
  const dir = path.join(os.tmpdir(), 'claude-codegraph-gate');
  const marker = path.join(dir, sid);

  if (tool === EXPLORE) {
    try {
      fs.mkdirSync(dir, { recursive: true });
      fs.writeFileSync(marker, String(Date.now()));
    } catch {}
    process.exit(0);
  }

  if (!findCodegraph(input.cwd)) process.exit(0);
  if (fs.existsSync(marker)) process.exit(0);

  let blocked = false;
  if (tool === 'Read') {
    blocked = !isNonCodeTarget(ti.file_path);
  } else if (tool === 'Grep') {
    blocked = !(isNonCodeTarget(ti.glob) || isNonCodeTarget(ti.path));
  } else if (tool === 'Glob') {
    blocked = !isNonCodeTarget(ti.pattern);
  } else if (tool === 'Bash') {
    const cmd = String(ti.command || '');
    blocked = /(^|[|;&]\s*)(grep|egrep|rg|find|findstr|ag|ack)\b/.test(cmd);
  }

  if (blocked) {
    deny(
      'CodeGraph gate: repo has .codegraph/. Call mcp__codegraph__codegraph_explore ' +
      'FIRST (load via ToolSearch "select:mcp__codegraph__codegraph_explore" if deferred), ' +
      'then retry. After one explore call this gate opens for the session.'
    );
  }
  process.exit(0);
});
