'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawnSync } = require('child_process');

const HOOK = path.join(__dirname, '..', '..', 'hooks', 'codegraph-gate.js');

function indexedRepo() {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'codegraph-gate-'));
  fs.mkdirSync(path.join(dir, '.codegraph'));
  return dir;
}

let sessionSeq = 0;
function newSession() {
  return `gate-test-${process.pid}-${Date.now()}-${++sessionSeq}`;
}

function runGate(cwd, session_id, tool_name, tool_input) {
  const input = { cwd, session_id, tool_name, tool_input };
  const result = spawnSync('node', [HOOK], { input: JSON.stringify(input), encoding: 'utf8' });
  assert.equal(result.status, 0, result.stderr);
  return result.stdout ? JSON.parse(result.stdout).hookSpecificOutput.permissionDecision : 'allow';
}

test('reading code before explore is denied in an indexed repo', () => {
  const dir = indexedRepo();
  assert.equal(runGate(dir, newSession(), 'Read', { file_path: path.join(dir, 'a.ts') }), 'deny');
});

test('reading non-code files is allowed before explore', () => {
  const dir = indexedRepo();
  assert.equal(runGate(dir, newSession(), 'Read', { file_path: path.join(dir, 'pom.xml') }), 'allow');
});

test('shell codegraph explore opens the gate for the session', () => {
  const dir = indexedRepo();
  const sid = newSession();
  assert.equal(runGate(dir, sid, 'Bash', { command: 'codegraph explore "OrderService"' }), 'allow');
  assert.equal(runGate(dir, sid, 'Read', { file_path: path.join(dir, 'a.ts') }), 'allow');
});

test('MCP explore opens the gate for the session', () => {
  const dir = indexedRepo();
  const sid = newSession();
  runGate(dir, sid, 'mcp__codegraph__codegraph_explore', { query: 'x' });
  assert.equal(runGate(dir, sid, 'Grep', { pattern: 'x' }), 'allow');
});

test('bash grep before explore is denied', () => {
  const dir = indexedRepo();
  assert.equal(runGate(dir, newSession(), 'Bash', { command: 'grep -rn foo src' }), 'deny');
});

test('repo without .codegraph is never gated', () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'codegraph-none-'));
  assert.equal(runGate(dir, newSession(), 'Read', { file_path: path.join(dir, 'a.ts') }), 'allow');
});
