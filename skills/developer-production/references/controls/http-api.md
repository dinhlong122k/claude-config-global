# HTTP and API

## API-001 — Inbound contract

**CRITICAL when adding or changing an endpoint.** Fix method/path, schema, status codes, error codes, authentication/authorization, idempotency and compatibility. Validate body, query and path; enforce limits on request timeout, body size, array length and JSON depth; collections must have a result cap. Bind by allow-list: server-decided fields (status, owner, tenant, server-computed values) are written only by the server; field-level authorization also applies to responses. Tokens, OTPs and PII go in the body or an opaque ID, never in path or query. Responses return DTOs, never persistence entities or raw dependency errors. Endpoints prone to abuse: see [rate limit](../integrations/rate-limit.md).

## API-002 — Outbound HTTP

**CRITICAL when calling external HTTP.** The client lives in the external adapter; deadline/timeout, TLS, response-size limit, retry per `REL-001`, `REL-002`; response model, data mapping and error mapping per `EXC-001`–`EXC-005`. The host comes from an allow-listed config; disable auto-redirect; URLs with dynamic parts are protected against SSRF (block internal and metadata addresses after DNS resolution). Validate response schema, status and size before use; a contract violation is a dependency error per `ERR-001`. If the downstream supports an idempotency key or client reference, keep the same value across all retries; after a timeout following a send, look up status by that reference before resending. Never log tokens or full sensitive request/response bodies.

## API-003 — Concurrent writes and unknown outcomes

**CRITICAL when an endpoint creates or changes resource state with side effects.** Updates and cancellations check version or `ETag`/`If-Match`; a mismatch returns 409/412. Clients can look up state by resource ID or client reference. Long-running or downstream-dependent work returns 202 with a status resource and reports completion only once a final state exists.

## API-004 — Data types in contracts

**CRITICAL when the contract has exact amounts, timestamps or public IDs.** Exact numbers use decimal strings or integers throughout JSON, code and DB (no binary float); fix scale and rounding mode. Timestamps are RFC 3339 with offset, stored in UTC; calendar-only values use the date type. Public IDs are opaque, unguessable, and separate from internal DB keys.

## API-005 — Response protection headers

**CRITICAL when an endpoint returns sensitive data or PII, or uses cookies/sessions.** HTTPS only, with HSTS (at edge or app, per convention); `Cache-Control: no-store`; explicit `Content-Type` with `X-Content-Type-Options: nosniff`; CORS restricted to an origin allow-list, never `*` with credentials; hide server/framework version headers. With cookie-based auth: cookies are `Secure`, `HttpOnly` (unless the client must read them), `SameSite=Lax` or `Strict`; state-changing requests are protected against CSRF (framework token or double-submit, plus `Origin` check), and safe methods (GET/HEAD) never change state.

## API-006 — Inbound webhooks/callbacks

**CRITICAL when receiving callbacks from external systems.** Verify the signature over the raw body with constant-time comparison before parsing; reject timestamps outside the allowed window; dedupe by event ID with a unique constraint; apply events via state machine, ignoring events older than the current state; persist durably, then return 2xx, processing async per `ERR-005`. Signing secrets are managed and rotated per `SEC-002`.

## API-O01 — New pagination/filter/sort

**OPTIONAL when a collection endpoint has no contract yet.** Decide format, page limits, sort allow-list and client compatibility.

## API-O02 — New contract tooling

**OPTIONAL when adding a new OpenAPI generation/validation tool.** If the repo already has one, follow the existing convention.

## API-O03 — Batch/bulk endpoint

**OPTIONAL when clients send many commands at once.** Decide whether the batch is atomic or per-item, how results are reported per item, the item count limit, and idempotency per item or per batch.

## API-O04 — Application-level message signing

**OPTIONAL when a partner or regulation requires non-repudiation beyond TLS** (JWS, HTTP Message Signatures). Requires key lifecycle management and storage of signature evidence.

## API-O05 — Idempotency key for writes

**OPTIONAL when clients may resend a side-effecting write and the endpoint is not naturally idempotent.** Cost: a key table and a job to purge expired keys. The key arrives via `Idempotency-Key` header or a client reference, scoped per client/tenant. Store the key, request fingerprint and response in the same transaction as the business change per `DATA-001`, with a unique constraint. Same key and same payload returns the original response; same key with a different payload returns a conflict; a key still in progress returns conflict or in-progress. Keep keys longer than the client's retry window and state this in the contract.

## API-O06 — Amounts and business dates

**OPTIONAL — financial domain per `GOV-OPT-002`, when the contract has amounts, exchange rates, fees or interest.** Extends `API-004`: amounts carry an ISO 4217 currency code; scale follows the currency; fix the rounding point (per line or per total); reject values exceeding scale, and negative or zero values where the business does not allow them. Value date, cut-off and statement periods carry the agreed business timezone.

## API-O07 — Money transaction flows

**OPTIONAL — financial domain per `GOV-OPT-002`, when an endpoint or callback changes money transaction state.** `API-O05` becomes mandatory; keep keys at least as long as the reconciliation window with the partner. Money-decision callbacks are checked against the partner's status API when the partner contract does not guarantee full integrity. Transaction and ledger lists use keyset/cursor ordering.

**Evidence:** contract tests for success, validation, auth and error mapping; version mismatch returns 409/412; webhooks with bad signature, old timestamp, duplicate and out-of-order events; outbound timeout after send leads to status lookup; protection headers present on sensitive responses. When `API-O05` applies: replay with the same key, same key with a different payload, concurrent requests. Financial domain: values beyond scale, currency rounding, reconciliation of money callbacks.
