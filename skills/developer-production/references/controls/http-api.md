# HTTP và API

## API-001 — Contract inbound

**CRITICAL khi thêm/sửa endpoint.** Chốt method/path, schema, status, error code, authentication/authorization, idempotency và compatibility. Validate body/query/path/size; collection phải có giới hạn kết quả để tránh tải không giới hạn. Không expose persistence entity hoặc raw dependency error.

## API-002 — Outbound HTTP

**CRITICAL khi gọi HTTP bên ngoài.** Client ở external adapter; cấu hình deadline/timeout, TLS, response-size limit, error mapping và retry theo `REL-001`, `REL-002`. Không log token hoặc full request/response nhạy cảm.

## API-O01 — Pagination/filter/sort mới

**OPTIONAL khi collection endpoint chưa có contract.** Chốt khi cần về format, giới hạn trang, sort allow-list và tương thích client.

## API-O02 — Contract tooling mới

**OPTIONAL.** Cân nhắc khi thêm OpenAPI generation/validation tool mới; nếu repo đã có tool, tuân theo convention hiện tại.

**Bằng chứng:** contract tests cho thành công, validation, auth và error mapping.
