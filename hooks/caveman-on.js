#!/usr/bin/env node
// SessionStart: keep caveman style active for the whole session.
process.stdin.resume();
process.stdin.on('end', () => {
  process.stdout.write(JSON.stringify({
    hookSpecificOutput: {
      hookEventName: 'SessionStart',
      additionalContext:
        'Caveman mode ON for this session (skill: caveman:caveman). ' +
        'Reply in short, blunt sentences with small words, no filler. ' +
        'Code, paths, error names and tool calls stay normal. ' +
        'Reply in the language the user writes in. ' +
        'Stop only if user says "stop caveman", "normal mode" or "talk normal".',
    },
  }));
});
