# Runtime: configuration, lifecycle, jobs

Owner of rules for how a process starts, runs background work, and stops. Stack adapters map these to framework idioms; integrations add broker/client specifics (for example `KAFKA-012`).

## RUN-001 — Configuration validated at startup

**CRITICAL when adding or changing configuration.** Every new setting is typed, has a unit in its name or type (`timeoutMs`, `Duration`), and is validated at startup: required, range, format. Missing or invalid required config fails startup with a message naming the key, never a later runtime error. Defaults are safe for production or absent; never ship a dev default (localhost, disabled TLS, debug logging) that silently applies in production. Values differ per environment through the repo's mechanism; secrets come by reference per `SEC-002`. Do not log config values that may be secrets.

## RUN-002 — Graceful shutdown

**CRITICAL when adding an entry point, worker, listener, scheduler, pool, or long-lived client.** On termination signal: stop accepting new work (fail readiness, stop polling, stop scheduling), let in-flight work finish within a bounded drain timeout shorter than the platform kill grace period, then commit/flush and close clients in reverse dependency order. Work not finished by the deadline is cancelled per `ERR-006` and left in a state that a restart resumes or retries safely.

## RUN-003 — Health and readiness

**CRITICAL when the service runs under an orchestrator or load balancer that probes it.** Liveness answers "is the process stuck" and never depends on downstreams (a DB outage must not restart every pod). Readiness answers "can this instance serve now" and reflects startup completion, shutdown, and only the dependencies without which every request fails. Probes are cheap, unauthenticated only on an internal port/path, and expose no version, config, or dependency detail.

## RUN-004 — Scheduled and batch jobs

**CRITICAL when adding or changing a scheduled job, batch, or one-off backfill.**

- **Single execution:** with multiple instances, ensure one run per schedule (DB lease/lock row, platform singleton job, or a unique run record); a lost lease must not leave two runners.
- **Idempotent rerun:** a crashed or repeated run produces the same result; progress is checkpointed so a restart resumes instead of redoing side effects.
- **Bounded work:** process in chunks with a per-run cap and a max duration; one bad item goes to a disposition per `ERR-005` without failing the rest.
- **Time:** schedule in an explicit timezone; define behavior for DST gaps/overlaps and for missed runs (catch up once, skip, or alert).
- **Visibility:** each run logs start/end, counts (processed/failed/skipped), and duration; a run that did not happen or stalled is detectable per `OBS-002`.

## RUN-005 — Bounded resource use

**CRITICAL when processing input whose size is controlled by a caller, partner, or data growth (files, exports, imports, large queries, message batches).** Stream or page instead of loading everything into memory; cap in-memory collections, buffers, and decompressed size; set limits on queue length and worker concurrency so overload causes rejection/backpressure, not OOM. Temporary files go to a bounded location and are deleted on every path.

## RUN-O01 — Leader election or distributed scheduler

**OPTIONAL when DB-lease single execution (`RUN-004`) is insufficient** (many jobs, sub-second scheduling, cross-region). Adds a coordination dependency; decide via `GOV-DEC-001`.

## RUN-O02 — Dynamic configuration reload

**OPTIONAL when the plan needs config changes without restart.** Reloaded values are validated like `RUN-001`; a bad value keeps the last good config and alerts. Never hot-reload secrets or security policy without an audit record.

## RUN-O03 — Financial cut-off and end-of-day jobs

**OPTIONAL — financial domain per `GOV-OPT-002`, when a job settles, accrues interest, closes a business day, or reconciles with a partner.** The job runs against an explicit business date (not "now"), is rerunnable for a given business date without double posting, records a completion marker per business date, and blocks dependent jobs until reconciliation passes or an operator overrides with an audit record.

**Evidence:** startup fails with a clear message on missing/invalid config; shutdown test shows in-flight work completes or is safely resumable; two instances do not run the same job concurrently; rerun after a mid-run crash yields no duplicates; large-input test stays within memory limits.
