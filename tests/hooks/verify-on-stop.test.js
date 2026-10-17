'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const os = require('os');
const path = require('path');
const { execFileSync, spawnSync } = require('child_process');
const { parseAddedLines, findIssues } = require('../../hooks/verify-on-stop.js');

const HOOK = path.join(__dirname, '..', '..', 'hooks', 'verify-on-stop.js');
const REPORT_OK = 'STATUS: DONE\nVERIFY:\n- npm test → PASS';

function makeRepo() {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'verify-on-stop-'));
  const run = (...args) => execFileSync('git', args, { cwd: dir, stdio: 'ignore' });
  run('init', '-q');
  run('config', 'user.email', 'test@example.com');
  run('config', 'user.name', 'test');
  fs.writeFileSync(path.join(dir, 'app.ts'), 'export const a = 1;\n');
  run('add', '.');
  run('commit', '-qm', 'init');
  return { dir, run };
}

let agentSeq = 0;
function runHook(event, cwd, extra = {}) {
  const input = { hook_event_name: event, cwd, session_id: 's', ...extra };
  const result = spawnSync('node', [HOOK], { input: JSON.stringify(input), encoding: 'utf8' });
  assert.equal(result.status, 0, result.stderr);
  return result.stdout ? JSON.parse(result.stdout) : null;
}

function startAgent(cwd) {
  const agent_id = `agent-${process.pid}-${++agentSeq}`;
  runHook('SubagentStart', cwd, { agent_id });
  return agent_id;
}

test('parseAddedLines maps added lines to file and new line number', () => {
  const diff = [
    'diff --git a/src/x.ts b/src/x.ts',
    '--- a/src/x.ts',
    '+++ b/src/x.ts',
    '@@ -3,0 +4,2 @@',
    '+const one = 1;',
    '+// TODO later',
  ].join('\n');
  assert.deepEqual(parseAddedLines(diff), [
    { file: 'src/x.ts', line: 4, text: 'const one = 1;' },
    { file: 'src/x.ts', line: 5, text: '// TODO later' },
  ]);
});

test('parseAddedLines ignores deleted files', () => {
  const diff = ['--- a/gone.ts', '+++ /dev/null', '@@ -1 +0,0 @@', '-x'].join('\n');
  assert.deepEqual(parseAddedLines(diff), []);
});

test('findIssues flags placeholder, conflict marker and missing VERIFY', () => {
  const issues = findIssues(
    [
      { file: 'a.ts', line: 1, text: '// FIXME broken' },
      { file: 'a.ts', line: 2, text: '<<<<<<< HEAD' },
    ],
    'STATUS: DONE',
  );
  assert.equal(issues.length, 3);
  assert.match(issues[0], /Placeholder: a\.ts:1/);
  assert.match(issues[1], /Conflict marker: a\.ts:2/);
  assert.match(issues[2], /VERIFY/);
});

test('findIssues skips report check when no code changed or message unknown', () => {
  assert.deepEqual(findIssues([], 'no verify here'), []);
  assert.deepEqual(findIssues([{ file: 'a.ts', line: 1, text: 'ok' }], undefined), []);
});

test('stop is allowed when diff is clean and report has VERIFY', () => {
  const { dir } = makeRepo();
  const agent_id = startAgent(dir);
  fs.appendFileSync(path.join(dir, 'app.ts'), 'export const b = 2;\n');
  assert.equal(runHook('SubagentStop', dir, { agent_id, last_assistant_message: REPORT_OK }), null);
});

test('stop is blocked once for placeholder in committed change, then allowed', () => {
  const { dir, run } = makeRepo();
  const agent_id = startAgent(dir);
  fs.appendFileSync(path.join(dir, 'app.ts'), '// TODO implement\n');
  run('commit', '-qam', 'wip');
  const first = runHook('SubagentStop', dir, { agent_id, last_assistant_message: REPORT_OK });
  assert.equal(first.decision, 'block');
  assert.match(first.reason, /Placeholder: app\.ts:2/);
  assert.equal(runHook('SubagentStop', dir, { agent_id, last_assistant_message: REPORT_OK }), null);
});

test('untracked code file is checked as fully added', () => {
  const { dir } = makeRepo();
  const agent_id = startAgent(dir);
  fs.writeFileSync(path.join(dir, 'new.py'), 'x = 1\n# XXX hack\n');
  const result = runHook('SubagentStop', dir, { agent_id, last_assistant_message: REPORT_OK });
  assert.match(result.reason, /Placeholder: new\.py:2/);
});

test('non-code files are ignored', () => {
  const { dir } = makeRepo();
  const agent_id = startAgent(dir);
  fs.writeFileSync(path.join(dir, 'TASKS.md'), '- TODO flow branch\n');
  assert.equal(runHook('SubagentStop', dir, { agent_id, last_assistant_message: 'no report' }), null);
});

test('stop_hook_active never blocks', () => {
  const { dir } = makeRepo();
  const agent_id = startAgent(dir);
  fs.appendFileSync(path.join(dir, 'app.ts'), '// TODO\n');
  const result = runHook('SubagentStop', dir, {
    agent_id, stop_hook_active: true, last_assistant_message: 'x',
  });
  assert.equal(result, null);
});

test('outside a git repo the hook fails open', () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'verify-on-stop-nogit-'));
  assert.equal(runHook('SubagentStop', dir, { agent_id: 'x', last_assistant_message: 'x' }), null);
});
