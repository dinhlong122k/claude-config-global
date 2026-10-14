#!/usr/bin/env node
// PostToolUse (Write|Edit): mirror changed skills/agents/hooks/CLAUDE.md from ~/.claude back into the config repo.
// Repo path comes from ~/.claude/.global-config-repo (written by install). Copies only; never commits.
const fs = require('fs'), os = require('os'), path = require('path');
const home = path.join(os.homedir(), '.claude');
const markerPath = path.join(home, '.global-config-repo');
const norm = (p) => path.resolve(p).replace(/\\/g, '/').toLowerCase();

let raw = '';
process.stdin.on('data', (d) => (raw += d));
process.stdin.on('end', () => {
  try {
    if (!fs.existsSync(markerPath)) return;
    const repo = fs.readFileSync(markerPath, 'utf8').trim();
    if (!repo || !fs.existsSync(repo)) return;

    let file = '';
    try { file = JSON.parse(raw).tool_input.file_path || ''; } catch (_) {}
    const h = norm(home) + '/';
    if (file) {
      const f = norm(file);
      const hit = f === h + 'claude.md' || ['skills/', 'agents/', 'hooks/'].some((d) => f.startsWith(h + d));
      if (!hit) return;
    }
    sync(repo);
  } catch (_) { /* never break the session */ }
});

function copyTree(from, to) {
  for (const e of fs.readdirSync(from, { withFileTypes: true })) {
    const s = path.join(from, e.name), d = path.join(to, e.name);
    if (e.isDirectory()) { fs.mkdirSync(d, { recursive: true }); copyTree(s, d); }
    else if (e.isFile()) copyFile(s, d);
  }
}
function copyFile(s, d) {
  const a = fs.statSync(s);
  if (fs.existsSync(d)) {
    const b = fs.statSync(d);
    if (a.size === b.size && Buffer.compare(fs.readFileSync(s), fs.readFileSync(d)) === 0) return;
  }
  fs.mkdirSync(path.dirname(d), { recursive: true });
  fs.copyFileSync(s, d);
}
function sync(repo) {
  const cm = path.join(home, 'CLAUDE.md');
  if (fs.existsSync(cm)) copyFile(cm, path.join(repo, 'CLAUDE.md'));
  for (const dir of ['skills', 'agents']) {
    const base = path.join(home, dir);
    if (!fs.existsSync(base)) continue;
    for (const e of fs.readdirSync(base, { withFileTypes: true })) {
      if (dir === 'skills' && e.name === 'synced') continue; // account-synced, not ours
      const s = path.join(base, e.name), d = path.join(repo, dir, e.name);
      if (e.isDirectory()) { fs.mkdirSync(d, { recursive: true }); copyTree(s, d); }
      else if (e.isFile()) copyFile(s, d);
    }
  }
  // hooks: only files already tracked in the repo (others may be machine-specific)
  const rh = path.join(repo, 'hooks');
  if (fs.existsSync(rh)) {
    for (const name of fs.readdirSync(rh)) {
      const s = path.join(home, 'hooks', name);
      if (fs.existsSync(s)) copyFile(s, path.join(rh, name));
    }
  }
}