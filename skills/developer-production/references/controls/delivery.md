# Safe delivery: migrations, compatibility, rollout

Owner of rules that keep a change safe while old and new versions run side by side (rolling deploy, consumers upgrading at different times, rollback). Contract ownership stays in `ARC-DEP-002`; consistency of a single write stays in `DATA-002`.

## DLV-001 — Schema migration compatible with rolling deploy

**CRITICAL when changing a DB schema, index, or stored data shape.** Assume the previous app version keeps running against the new schema until the deploy finishes and after a rollback. Use expand → migrate → contract:

- **Expand:** add nullable/defaulted columns, new tables, new indexes; never rename or drop in the same release as the code that stops using them.
- **Migrate:** code writes both shapes (or the new shape with a read fallback) before any backfill; backfill runs in bounded batches, resumable, idempotent, outside the request path.
- **Contract:** drop/rename/tighten (`NOT NULL`, new constraint) only in a later release, after no running version reads the old shape.

Check lock impact on large or hot tables (DDL that rewrites or blocks writes, index builds without the engine's online/concurrent option, long transactions). Migrations are versioned in the repo's tool, run once, and are never edited after release. State the rollback path: down-migration, or a forward fix when down would lose data.

## DLV-002 — Backward-compatible contracts

**CRITICAL when changing an API, event/message schema, file format, or shared cache value.** Default to additive changes: new optional fields, new endpoints, new enum values only where consumers tolerate unknown values. Never, in one release: remove or rename a field, change a type/unit/meaning, make an optional field required, tighten validation on existing input, or change a default. Readers ignore unknown fields; writers keep producing every field current consumers need. A breaking change needs a new version (path, header, topic, or schema version) plus a deprecation period with the old one still served, decided via `GOV-DEC-001`. Cached or persisted serialized values must stay readable by both versions, or carry a versioned key.

## DLV-003 — Deploy order and rollback

**CRITICAL when a change spans more than one deployable or a DB migration plus code.** Write the order (migration → producer/provider → consumer, or the reverse when the consumer must tolerate the new shape first) and confirm every intermediate state works. Rollback of the code must not break on data already written by the new version.

## DLV-O01 — Feature flag

**OPTIONAL when the plan needs to separate deploy from release, roll out gradually, or keep a kill switch.** Cost: flag store, both code paths tested, cleanup. The flag has an owner, a default that is safe when the flag store is unavailable, and a removal ticket; never gate a security or data-integrity control behind a flag.

## DLV-O02 — Progressive rollout

**OPTIONAL when a change is high-risk and the platform supports canary, blue/green, or percentage rollout.** Define the health signal (error rate, latency, business metric per `OBS-002`) and the automatic or manual rollback threshold.

## DLV-O03 — Online schema change tooling

**OPTIONAL when a table is too large for native online DDL.** Adds a tool (gh-ost, pt-online-schema-change, or equivalent) and operational steps; decide via `GOV-DEC-001`.

## DLV-O04 — Regulated change records

**OPTIONAL — financial domain per `GOV-OPT-002`, when changing money-movement, ledger, or reconciliation logic.** Migrations that rewrite financial data keep a before/after snapshot or a reversible journal; ledger rows are corrected by compensating entries, never by UPDATE/DELETE; the change carries a reconciliation check comparing totals before and after.

**Evidence:** migration runs on a copy of the current schema with the previous app version's tests still passing; backfill is restartable; contract tests show old clients/consumers still work; written deploy order; rollback tested or forward-fix path stated.
