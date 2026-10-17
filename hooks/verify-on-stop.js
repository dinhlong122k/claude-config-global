#!/usr/bin/env node
// SubagentStart/SubagentStop gate for task-executor (matcher in settings.json).
// Start: record git HEAD per agent as the diff base.
// Stop: if code files changed since base, block the FIRST stop when added lines carry
// placeholders/conflict markers or the final report has no `VERIFY:` block.
// Blocks at most once per agent so a wrong finding can never wedge the run.
// Fail-open on infrastructure errors (no git, no repo): a broken hook must not stop work.
'use strict';
const fs = require('fs');
const os = require('os');
const path = require('path');
const { execFileSync } = require('child_process');

const STATE_DIR = path.join(os.tmpdir(), 'claude-verify-on-stop');
const CODE_EXTENSIONS = new Set([
  '.c', '.cc', '.cpp', '.cs', '.go', '.h', '.hpp', '.java', '.js', '.jsx', '.kt', '.kts',
  '.mjs', '.cjs', '.php', '.py', '.rb', '.rs', '.scala', '.sql', '.swift', '.ts', '.tsx', '.vue',
]);
const PLACEHOLDER = /\b(TODO|FIXME|XXX|HACK)\b/;
const CONFLICT_MARKER = /^(<{7}|={7}|>{7})(\s|$)/;
const VERIFY_BLOCK = /^\s*VERIFY\s*:/m;
const MAX_FINDINGS = 20;
const HUNK_HEADER = /^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@/;

function git(cwd, args) {
  return execFileSync('git', args, {
    cwd, encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'], maxBuffer: 64 * 1024 * 1024,
  });
}

function isCodeFile(file) {
  return CODE_EXTENSIONS.has(path.extname(file).toLowerCase());
}

function statePath(input) {
  const key = String(input.agent_id || input.session_id || 'unknown').replace(/[^\w-]/g, '_');
  return path.join(STATE_DIR, key + '.json');
}

function readState(file) {
  try { return JSON.parse(fs.readFileSync(file, 'utf8')); } catch { return {}; }
}

function writeState(file, state) {
  fs.mkdirSync(STATE_DIR, { recursive: true });
  fs.writeFileSync(file, JSON.stringify(state));
}

// Parses `git diff -U0` output into { file, line, text } for every added line.
function parseAddedLines(diff) {
  const added = [];
  let file = null;
  let line = 0;
  for (const raw of diff.split('\n')) {
    if (raw.startsWith('+++ ')) {
      file = raw === '+++ /dev/null' ? null : raw.slice(4).replace(/^b\//, '');
      continue;
    }
    const hunk = HUNK_HEADER.exec(raw);
    if (hunk) { line = Number(hunk[1]); continue; }
    if (file && raw.startsWith('+')) {
      added.push({ file, line, text: raw.slice(1) });
      line += 1;
    }
  }
  return added;
}

function collectAddedLines(root, base) {
  const added = parseAddedLines(git(root, ['diff', '-U0', '--no-color', '--no-ext-diff', base]))
    .filter((entry) => isCodeFile(entry.file));
  const untracked = git(root, ['ls-files', '--others', '--exclude-standard'])
    .split('\n').filter((f) => f && isCodeFile(f));
  for (const file of untracked) {
    let content;
    try { content = fs.readFileSync(path.join(root, file), 'utf8'); } catch { continue; }
    content.split('\n').forEach((text, index) => added.push({ file, line: index + 1, text }));
  }
  return added;
}

// Returns human-readable findings; empty array means the stop is allowed.
function findIssues(addedLines, lastMessage) {
  const issues = [];
  for (const { file, line, text } of addedLines) {
    if (issues.length >= MAX_FINDINGS) break;
    if (CONFLICT_MARKER.test(text)) issues.push(`Conflict marker: ${file}:${line}`);
    else if (PLACEHOLDER.test(text)) issues.push(`Placeholder: ${file}:${line} — ${text.trim()}`);
  }
  const touchedCode = addedLines.length > 0;
  if (touchedCode && typeof lastMessage === 'string' && !VERIFY_BLOCK.test(lastMessage)) {
    issues.push('Report thiếu khối `VERIFY:` (lệnh đã chạy → PASS/FAIL, hoặc `CHƯA CHẠY: <lý do>`).');
  }
  return issues;
}

function onStart(input, root, file) {
  writeState(file, { base: git(root, ['rev-parse', 'HEAD']).trim(), blocked: false });
}

function onStop(input, root, file) {
  const state = readState(file);
  if (state.blocked || input.stop_hook_active) { fs.rmSync(file, { force: true }); return null; }
  const base = state.base || 'HEAD';
  const issues = findIssues(collectAddedLines(root, base), input.last_assistant_message);
  if (issues.length === 0) { fs.rmSync(file, { force: true }); return null; }
  writeState(file, { ...state, blocked: true });
  return {
    decision: 'block',
    reason: 'verify-on-stop: sửa các điểm sau hoặc giải trình trong report rồi dừng lại.\n- '
      + issues.join('\n- '),
  };
}

function main(raw) {
  let input;
  try { input = JSON.parse(raw); } catch { return null; }
  let root;
  try { root = git(input.cwd || process.cwd(), ['rev-parse', '--show-toplevel']).trim(); } catch { return null; }
  const file = statePath(input);
  if (input.hook_event_name === 'SubagentStart') { onStart(input, root, file); return null; }
  if (input.hook_event_name === 'SubagentStop') return onStop(input, root, file);
  return null;
}

if (require.main === module) {
  let raw = '';
  process.stdin.on('data', (chunk) => (raw += chunk));
  process.stdin.on('end', () => {
    let result = null;
    try { result = main(raw); } catch (error) {
      process.stderr.write(`verify-on-stop skipped: ${error.message}\n`);
    }
    if (result) process.stdout.write(JSON.stringify(result));
    process.exit(0);
  });
}

module.exports = { parseAddedLines, findIssues };
