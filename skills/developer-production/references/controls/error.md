# Error handling

## ERR-001 — Closed error catalog

**CRITICAL when an operation has an observable failure path.** Every error reaching a caller or becoming an async disposition must be in the catalog: stable code, outcome (HTTP status/disposition), retryability per `REL-002`, log level. Map framework/library exceptions explicitly. Cover at least:

- **Input:** malformed/wrong-type/missing/oversized data, bad path/query, unsupported method or media type.
- **Identity:** unauthenticated, invalid/expired token, missing permission, wrong tenant.
- **Business:** not-found, conflict/invalid state, duplicate, violated rule.
- **Data:** unique/FK/check constraint, optimistic lock, deadlock, pool exhausted.
- **Dependency:** timeout, unavailable, contract-violating response, downstream 4xx/5xx, circuit open. Partner-specific codes map through each client's table per `EXC-003`.
- **Load:** rate limit, quota, backpressure.
- **Async:** deserialization failure, schema mismatch, retries exhausted.
- **Unknown outcome:** timeout after a side effect (reconcile).
- **Unclassified:** any other exception → `INTERNAL_ERROR`, not retried.

Add new failure paths to the catalog before merge; no ad hoc codes in handlers.

## ERR-002 — Safe public errors

**CRITICAL when an error reaches a caller.** Return a catalog code, a safe message, and a correlation ID. Never expose raw exceptions, stack traces, SQL, class names, secrets, tokens, internal paths, sensitive payloads, or verbatim downstream errors (the only exception is a sanitized partner message on a pass-through row per `EXC-004`). Do not leak existence: resources outside the caller's permission/tenant return the same outcome as not-found when existence is sensitive. Validation gives per-field detail without echoing sensitive values.

## ERR-003 — Log at the final boundary

**CRITICAL when logging a failure.** Log a terminal error once, at the final handler; intermediate layers keep cause/context. Level follows the catalog: expected input/business errors raise no ERROR alert; `INTERNAL_ERROR` and prolonged dependency failures do. Retries get metrics and appropriate logs; avoid log storms.

## ERR-004 — Purposeful catch

**CRITICAL for every catch/handler.** Each catch must handle the error fully (recover or fall back per `REL-003`), convert it to a catalog error keeping the cause, or rethrow. Forbidden: ignoring, log-and-continue as success, returning `null`/defaults that hide the error; losing cause/stack; broad `Exception`/`Throwable` catches outside the final handler; catching fatal runtime errors (OOM, stack overflow); exceptions as normal control flow. Release resources on every path (try-with-resources/`finally`/`defer`); cleanup errors must not mask the original.

## ERR-005 — Final handler at every entry point

**CRITICAL for every entry point:** HTTP/gRPC, consumer, scheduled job, CLI, background executor/thread, async callback. One final handler maps exceptions to the catalog (`ERR-001`) and responds per `ERR-002`. Unmappable exceptions become `INTERNAL_ERROR`, logged at ERROR with the exception type for later cataloging. Async work has an explicit disposition: retry, quarantine/DLT (error code, redacted cause, attempt count, original metadata, replay path), or stop. Never let exceptions in `@Async`, `CompletableFuture`, goroutines, or schedulers vanish unlogged; one failing item must not kill a worker or batch unless intended.

## ERR-006 — Cancellation

**CRITICAL when an operation has a deadline, can be cancelled, or runs on an interruptible thread.** Propagate cancel/deadline to outbound calls, preserve interrupt signals (Java: restore the flag), stop work, release resources. Caller or shutdown cancellation raises no ERROR alert and is not a dependency failure.

## ERR-O01 — New diagnostic surface

**OPTIONAL.** Consider when adding a dashboard, diagnostic endpoint, or finer error taxonomy; protect sensitive data.

Minimal HTTP example: `{ "code": "DEPENDENCY_TIMEOUT", "message": "Temporarily unable to process the request", "correlationId": "..." }`. Cause and dependency details go only to redacted logs/traces; choose the HTTP status by operation outcome.

**Evidence:** the catalog; tests that each catalog code and common framework exceptions (bad JSON, wrong method/media type, constraints, timeouts) return the right code and outcome; unknown exception → `INTERNAL_ERROR` with no leaked details; errors in jobs, consumers, and background executors are logged and have a disposition.
