# Bảo mật

## SEC-001 — Input và quyền truy cập

**CRITICAL khi nhận input hoặc thao tác tài nguyên có quyền.** Validate type, size, format và allowed values tại boundary; kiểm tra authorization server side trên operation/resource, gồm tenant scope. Dùng parameter binding; chống path traversal và cross-tenant key/file access.

## SEC-002 — Secret và trust

**CRITICAL khi dùng credential, private key, token hoặc external traffic.** Secret lấy từ cơ chế quản lý an toàn, không commit/log/echo; quyền service account tối thiểu. Xác minh peer qua TLS/SSH trust policy; không tắt certificate/host-key verification. Có cách rotate/revoke.

## SEC-003 — Dữ liệu nhạy cảm

**CRITICAL khi xử lý PII hoặc dữ liệu nhạy cảm.** Phân loại trước khi lưu/truyền/log/cache; giới hạn quyền và retention. Không đưa secret/token vào cache nghiệp vụ, log hoặc DLT không được bảo vệ.

## SEC-004 — Login và token

**CRITICAL khi feature thực hiện login, reset mật khẩu hoặc phát token.** Chốt identity provider/flow; chống user enumeration và abuse; rõ token/session lifetime, rotation, revoke và storage/cookie policy. Nếu dùng Keycloak hoặc rate limit, đọc integration tương ứng.

## SEC-005 — Injection và parse không an toàn

**CRITICAL khi dữ liệu ngoài đi vào interpreter, parser hoặc output.** Không ghép chuỗi vào SQL/NoSQL, OS command, LDAP, XPath, template, regex, header hay log: dùng parameter binding, API nhận argument dạng mảng (không qua shell), template engine tự escape, và loại CR/LF khỏi giá trị đưa vào header/log. XML tắt DTD/external entity; không deserialize kiểu tùy ý từ input (Java native serialization, pickle, YAML unsafe load, polymorphic JSON không allow-list). Regex áp lên input phải tránh backtracking thảm họa hoặc có giới hạn độ dài. Khi render HTML, encode theo ngữ cảnh (HTML/attribute/JS/URL).

## SEC-006 — Nhận file từ bên ngoài

**CRITICAL khi nhận file qua upload, SFTP, object storage hoặc partner.** Giới hạn kích thước trước khi đọc hết; xác định loại file bằng nội dung (magic bytes) theo allow-list, không tin extension/`Content-Type`; giới hạn kích thước và số entry sau giải nén, chặn path trong archive (zip slip). Tên lưu trữ do server sinh, không dùng tên client làm path. File chưa qua kiểm tra nằm ở vùng cách ly, không phục vụ trực tiếp; khi trả file cho người dùng, đặt `Content-Disposition: attachment` và `nosniff`. Semantics riêng của MinIO/SFTP xem integration tương ứng.

## SEC-007 — Audit log hành động nhạy cảm

**CRITICAL khi feature cho phép đổi quyền, đổi dữ liệu của người khác, thao tác admin, xuất dữ liệu hàng loạt hoặc truy cập dữ liệu nhạy cảm.** Ghi audit event tách khỏi technical log: actor (user/service, tenant), action, resource ID, kết quả, thời điểm UTC, correlation ID và nguồn (IP/client) khi có. Không ghi giá trị nhạy cảm, chỉ ghi field nào đổi. Audit được ghi cùng transaction với thay đổi hoặc qua cơ chế bền vững theo `DATA-002`; ghi audit thất bại thì hành động không được báo thành công. Người bị audit không sửa/xóa được audit của mình.

## SEC-O01 — Mã hóa cấp trường

**OPTIONAL.** Cân nhắc khi thêm key lifecycle và mã hóa cấp trường ngoài storage encryption mặc định.

## SEC-O02 — Threat model chuyên sâu

**OPTIONAL.** Cân nhắc khi mở rộng sang threat-model workshop/tooling cho nhiều trust boundary; kiểm tra input/auth/secret cơ bản vẫn là critical.

## SEC-O03 — Quét malware cho file

**OPTIONAL.** Cân nhắc khi file từ bên ngoài được người dùng khác tải về hoặc hệ thống khác xử lý. Thêm dependency scanner và trạng thái file (pending/clean/rejected); file chưa `clean` không được phục vụ.

## SEC-O04 — Kiểm soát giao dịch tài chính

**OPTIONAL — financial domain theo `GOV-OPT-002`, khi feature tạo/duyệt giao dịch tiền, đổi hạn mức, thông tin thụ hưởng hoặc cấu hình phí.** Thao tác vượt ngưỡng cần maker-checker (người tạo khác người duyệt, kiểm tra server side); đổi thông tin thụ hưởng/thiết bị/hạn mức yêu cầu xác thực lại (step-up) và có thời gian chờ hoặc thông báo; audit theo `SEC-007` là append-only, chống sửa (hash chain hoặc storage WORM) và giữ theo thời hạn pháp lý.

**Bằng chứng:** test truy cập trái phép/chéo tenant; test payload injection, XML entity, file sai loại/quá cỡ/zip bomb/zip slip; audit event được ghi cho hành động nhạy cảm và không chứa giá trị nhạy cảm; rà secret/config và log redaction.
