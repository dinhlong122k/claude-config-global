---
name: developer-production
description: Implements production code in an existing repo exactly as specified by a given plan/task (APIs, DB, security, Kafka/Redis/SFTP/MinIO/Keycloak integrations, rate limiting). Selects technical rules by change trigger and verifies with commands actually run. Use when implementing or modifying code from a plan; not for planning, pure review, or documentation.
---

# Production development from a plan

The plan/task is the only source of scope. This skill defines how to do that scope correctly and minimally.

## Rules

1. **Follow the plan exactly.** Do everything it lists, nothing it doesn't. Every change must trace to a plan step, acceptance criterion, or listed file. Worthwhile work outside the plan goes in the report, not the code.
2. **Plan files are read-only.** Only tick finished steps and record the `Kiểm chứng` line. Plan missing, contradictory, or diverging from reality → stop the dependent part, report it (agent chính: ask) per [decision-gate](references/governance/decision-gate.md). Never fill gaps by guessing.
3. **Rules by trigger.** Read only references whose trigger appears in the change, via [routing](references/routing.md). `CRITICAL` rules constrain how to build planned work; they never justify new features. `OPTIONAL` items are skipped unless the plan requires them.
4. **Surgical edits.** Touch only files in the task. No renames, reformatting, or restructuring of unrelated code.
5. **Never report pass for a check not run.** Take format/lint/build/test commands from the repo; do not invent them.

## Anti-over-engineering

Default to the smallest code that satisfies the acceptance criteria: reuse existing utils/modules/patterns, prefer functions in existing modules.

Do not add unless the plan lists it, or it has ≥2 real call sites/implementations today:
- class, interface, abstract base, file, or package
- wrapper, factory, manager, helper, builder, DTO/mapper layer
- config option, feature flag, parameter, or extension point nobody reads
- generic or "reusable" version of a one-off need
- cache, retry, batching, async, or log/metric not required by the plan
- error type, test utility, or validation beyond the planned failure paths

Before finishing, for each new class/file/function/param/config, name the plan line that requires it. None → inline it into its single caller or delete it.

## Clean code

Intent-revealing names; short single-purpose functions; few params; no deep nesting, magic values, duplicated logic, or swallowed errors; comments explain why only. After tests pass, refactor only code you wrote or changed in task files (behavior unchanged), then rerun tests.

## Workflow

1. Read the task, referenced flows, and relevant code. No plan/task for this change → stop and say so.
2. Pick references (rule 3). Check APIs/config against pinned dependency versions; use the repo's equivalent when one exists.
3. Write tests for acceptance criteria → implement → run tests.
4. Refactor, then review the diff per [CQ-001](references/controls/code-quality.md): every hunk traces to the plan; remove the rest. Rerun checks.
5. Report: commands run with results, `CHƯA CHẠY` with reason, assumptions, out-of-plan findings.

Subagents never ask the user or dispatch reviewers: questions, blockers, and changed logic files go in the report. Orchestration and review belong to `CLAUDE.md`.

## References

- [Routing](references/routing.md): trigger → reference.
- [Feature review](references/workflow/feature-review.md): checklist for integrations/multi-boundary changes; fill only rows with a trigger.
- [Plan deviation](references/workflow/plan-execution.md): closed-world rule for gaps (`PLAN-EXE-001`), classify deviations for the report, scope check; never edit the plan.
- [Catalog extension](references/governance/skill-extension-assumptions.md): read only when editing this skill.
