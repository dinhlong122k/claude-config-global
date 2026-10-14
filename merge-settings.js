#!/usr/bin/env node
// Merge settings.template.json into ~/.claude/settings.json (idempotent, keeps existing keys).
const fs = require('fs'), path = require('path');
const [,, templatePath, targetPath, claudeHome] = process.argv;
const tpl = JSON.parse(fs.readFileSync(templatePath, 'utf8').split('__CLAUDE_HOME__').join(claudeHome.replace(/\\/g, '/')));
let cur = {};
if (fs.existsSync(targetPath)) {
  fs.copyFileSync(targetPath, targetPath + '.bak-' + Date.now());
  cur = JSON.parse(fs.readFileSync(targetPath, 'utf8'));
}
const norm = (c) => String(c).replace(/\\/g, '/').replace(/\.(cmd|exe|bat)\b/gi, '').replace(/\s+/g, ' ').trim().toLowerCase();
const cmds = (groups) => new Set((groups || []).flatMap(g => (g.hooks || []).map(h => norm(h.command))));
for (const [k, v] of Object.entries(tpl)) {
  if (k === 'hooks') {
    cur.hooks = cur.hooks || {};
    for (const [ev, groups] of Object.entries(v)) {
      const have = cmds(cur.hooks[ev]);
      cur.hooks[ev] = (cur.hooks[ev] || []).concat(groups.filter(g => !(g.hooks || []).some(h => have.has(norm(h.command)))));
    }
  } else if (k === 'permissions') {
    cur.permissions = cur.permissions || {};
    cur.permissions.allow = [...new Set([...(cur.permissions.allow || []), ...v.allow])];
  } else if (v && typeof v === 'object' && !Array.isArray(v)) {
    cur[k] = Object.assign({}, cur[k], v);
  } else {
    cur[k] = v;
  }
}
fs.mkdirSync(path.dirname(targetPath), { recursive: true });
fs.writeFileSync(targetPath, JSON.stringify(cur, null, 2) + '\n');
console.log('settings merged ->', targetPath);
