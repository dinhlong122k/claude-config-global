# Bảo mật

## SEC-001 — Input và quyền truy cập

**CRITICAL khi nhận input hoặc thao tác tài nguyên có quyền.** Validate type, size, format và allowed values tại boundary; kiểm tra authorization server side trên operation/resource, gồm tenant scope. Dùng parameter binding; chống path traversal và cross-tenant key/file access.

## SEC-002 — Secret và trust

**CRITICAL khi dùng credential, private key, token hoặc external traffic.** Secret lấy từ cơ chế quản lý an toàn, không commit/log/echo; quyền service account tối thiểu. Xác minh peer qua TLS/SSH trust policy; không tắt certificate/host-key verification. Có cách rotate/revoke.

## SEC-003 — Dữ liệu nhạy cảm

**CRITICAL khi xử lý PII hoặc dữ liệu nhạy cảm.** Phân loại trước khi lưu/truyền/log/cache; giới hạn quyền và retention. Không đưa secret/token vào cache nghiệp vụ, log hoặc DLT không được bảo vệ.

## SEC-004 — Login và token

**CRITICAL khi feature thực hiện login, reset mật khẩu hoặc phát token.** Chốt identity provider/flow; chống user enumeration và abuse; rõ token/session lifetime, rotation, revoke và storage/cookie policy. Nếu dùng Keycloak hoặc rate limit, đọc integration tương ứng.

## SEC-O01 — Mã hóa cấp trường

**OPTIONAL.** Cân nhắc khi thêm key lifecycle và mã hóa cấp trường ngoài storage encryption mặc định.

## SEC-O02 — Threat model chuyên sâu

**OPTIONAL.** Cân nhắc khi mở rộng sang threat-model workshop/tooling cho nhiều trust boundary; kiểm tra input/auth/secret cơ bản vẫn là critical.

**Bằng chứng:** test truy cập trái phép/chéo tenant, rà secret/config và log redaction.
