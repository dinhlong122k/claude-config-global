# External client: response model, mapping, error handling

Owner of rules for how each outbound client (HTTP, SOAP, gRPC, partner SDK) models the partner's response, maps data in both directions, and turns partner failures into catalog errors. Boundary placement stays in `ARC-EXT-001`; timeout/retry in `REL-001`/`REL-002`; the catalog and public error shape in `ERR-001`/`ERR-002`; transport details for HTTP in `API-002`.

Each client is treated as having its own response and error format. Never assume two partners share one, even when they look alike today.

## EXC-001 — Per-client response and error model

**CRITICAL when adding or changing an external client.** Each client owns its DTOs in its adapter package: request, success response, and **error response** modeled separately, matching that partner's documented contract (not a shared generic `ExternalResponse<T>` across partners). Record in the client how the partner signals failure; cover every form it uses:

- Transport status (HTTP 4xx/5xx, gRPC status, SOAP fault).
- Success status with an error inside the body (`200` + `{"resultCode": "E102"}`, `success: false`, non-zero `errorCode`).
- Partial success (batch with per-item status).
- SDK/library exceptions that already wrap the partner error.
- Non-conforming body: empty, HTML from a gateway/proxy, wrong content type, truncated, oversized.

The client classifies a response into exactly one of: success, partner business error, partner technical error, contract violation (unparseable or schema-invalid, per `API-002`), transport failure. Parsing the error body never throws past the client: a body that cannot be parsed becomes a contract violation that keeps the status and a size-capped, redacted raw snippet. Readers ignore unknown fields per `DLV-002`.

## EXC-002 — Two-way mapping prepared up front

**CRITICAL when a client sends or receives data.** Write both mappers in the adapter before wiring the call: domain model → external request, and external response → domain result. Domain code never sees partner DTOs; partner DTOs never import domain types.

- **Explicit field mapping:** no reflection/auto-mapping that silently drops or renames fields; every required partner field has a source, every domain field has a stated origin or default.
- **Value conversion:** enums (including an explicit branch for unknown partner values: reject as contract violation or map to a declared `UNKNOWN`), units, scale and rounding of amounts per `API-004`, timezones, date formats, ID formats, length limits and character sets the partner accepts.
- **Validate before send:** data the partner would reject for format reasons fails locally with a catalog code, not a round trip that returns a partner 400.
- **Pure and testable:** mappers have no I/O, so each one is unit-tested with real partner samples (success, each error form, edge values).

## EXC-003 — Per-client error mapping table

**CRITICAL when a client can return an error.** Each client has its own mapping table, kept next to the client (code constant, enum or config file per repo convention), from partner signal to internal catalog entry:

| Partner signal (status / code / exception) | Internal code (`ERR-001`) | Category | Retryable (`REL-002`) | Custom message key | Original message to caller |
| --- | --- | --- | --- | --- | --- |
| `400` + `INVALID_ACCOUNT` | `PAYEE_ACCOUNT_INVALID` | business | no | `payee.account.invalid` | no |
| `200` + `resultCode=E102` | `INSUFFICIENT_BALANCE` | business | no | `balance.insufficient` | no |
| `401` / `403` | `DEPENDENCY_AUTH_FAILED` | technical | no (refresh credential once if the flow supports it) | `dependency.unavailable` | no |
| `429` | `DEPENDENCY_RATE_LIMITED` | technical | yes, honor `Retry-After` | `dependency.busy` | no |
| `5xx`, connect error | `DEPENDENCY_UNAVAILABLE` | technical | per `REL-002` | `dependency.unavailable` | no |
| Read timeout after send | `DEPENDENCY_OUTCOME_UNKNOWN` | unknown outcome | only after status lookup per `API-002` | `request.processing` | no |
| Unparseable/schema-invalid body | `DEPENDENCY_CONTRACT_VIOLATION` | contract | no | `dependency.unavailable` | no |
| Any partner code not in the table | `DEPENDENCY_ERROR` | technical | no | `dependency.unavailable` | no |

Rows above are an example of shape only; real codes come from the partner's contract. Rules:

- Map on the most specific stable signal (partner error code before HTTP status; never on message text unless the partner has no code, and then mark it as fragile).
- The same partner code can map differently per operation; key the table by operation when it does.
- The default row is mandatory. An unmapped code logs at WARN with client, operation and partner code so the table can be extended; it does not become `INTERNAL_ERROR`, because the failure is known to come from the dependency.
- Adding a partner code or changing a row is a catalog change per `ERR-001`.

## EXC-004 — Custom message and original message

**CRITICAL when a partner error can reach a caller, a log, or a stored record.** The client error carries both messages, kept apart:

- **Custom message:** our message, resolved from the message key in the table → catalog default for the internal code → generic fallback. This is what callers see by default per `ERR-002`; supports i18n through the key.
- **Original message:** the partner's raw code, message, status, and partner request/trace ID, preserved unchanged in structured fields of the exception (not concatenated into the custom message), redacted per `SEC-003` and size-capped. It goes to logs, traces, and stored failure records (for support, reconciliation and DLT replay), never to the public response by default.

Passing the original message to the caller is allowed only when the mapping row explicitly says so (the partner documents that message as end-user text, for example a validation hint), and only after sanitizing (strip markup and control characters, cap length, drop internal identifiers). It is returned in a separate field, never replacing the catalog code. Everything else is a leak per `ERR-002`.

## EXC-005 — Typed client exception

**CRITICAL when a client raises an error.** The client converts every failure (EXC-001 categories) into one typed exception per repo convention (one per client or one shared external type), never letting raw HTTP client/SDK exceptions escape the adapter. Minimum fields: client name, operation, internal code, category, retryable, custom message key, partner status, partner code, partner message (redacted), partner request ID, attempt count, and the original cause per `ERR-004`. The final handler (`ERR-005`) maps it to the public error by internal code; it needs no knowledge of any partner's format. Cancellation by our caller stays a cancellation per `ERR-006`, not a dependency failure.

## EXC-006 — Observe per client

**CRITICAL when adding or changing a client.** Log the failure once at the final boundary per `ERR-003`, with client, operation, internal code, partner status/code, partner request ID, attempt and latency; never full sensitive bodies or tokens. Metrics per `OBS-002` are tagged by client, operation and internal code (bounded cardinality: never tag by raw partner message). Alert on `DEPENDENCY_CONTRACT_VIOLATION` and on the default-row count rising, since both mean the partner changed behavior.

## EXC-O01 — Config-driven mapping table

**OPTIONAL when partners add codes often or operations staff need to change messages without a deploy.** Cost: schema validation of the config at startup per `RUN-001`, versioning, and tests that load the real file. Code-level enums stay the default.

## EXC-O02 — Shared client error library

**OPTIONAL when several services call the same partners.** Extract the typed exception, message resolver and test helpers into a shared package per `ARC-EXT-O01`; each partner's DTOs and table stay per client.

## EXC-O03 — Money-moving partner calls

**OPTIONAL — financial domain per `GOV-OPT-002`, when a partner call moves money or changes a transaction state.** Every partner code is mapped to a transaction outcome: final success, final failure, pending, or unknown. Only codes the partner documents as final failure may mark the transaction failed; timeouts, unmapped codes and contract violations are unknown and go to status lookup/reconciliation per `DATA-004`, never to automatic failure or retry with a new reference. Store the partner's original code, message and reference with the transaction for dispute handling.

**Evidence:** per client, mapper unit tests with real partner samples in both directions (including unknown enum values and edge amounts/dates); one test per mapping-table row plus the default row; success-status-with-error-body, empty/HTML/oversized body, connect timeout, read timeout after send; public response shows the custom message and catalog code while the log/exception keeps the original partner code and message; pass-through rows return the sanitized original message in its own field.
