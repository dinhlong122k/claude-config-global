# Khả năng quan sát

## OBS-001 — Correlation xuyên boundary

**CRITICAL với request/job/file/message.** Tạo hoặc nhận correlation ID theo convention, validate ID do client gửi và truyền qua outbound call/message metadata. ID không chứa PII. Log operation, dependency, outcome và duration.

## OBS-002 — Metric tối thiểu

**CRITICAL với dependency hoặc xử lý async.** Đo success/failure/timeout/retry, latency và lag/backlog nếu có. Label cardinality thấp; không đặt user ID, object key, path hoặc message key trong metric label.

## OBS-003 — Log có cấu trúc và đúng mức

**CRITICAL khi thêm log.** Log dạng có cấu trúc theo convention repo (key/value hoặc JSON) với field cố định: thời điểm, level, service, correlation ID, operation, outcome. Message tĩnh, dữ liệu đi vào field, không ghép chuỗi. Level: ERROR cần người xử lý, WARN bất thường tự phục hồi, INFO sự kiện nghiệp vụ/vòng đời, DEBUG tắt ở production; level lỗi theo `ERR-003`. Không log trong vòng lặp nóng không giới hạn; không log secret, token, PII hay body nhạy cảm theo `SEC-003`. Audit nghiệp vụ thuộc `SEC-007`, không thay bằng technical log.

## OBS-O01 — Distributed tracing mở rộng

**OPTIONAL.** Cân nhắc khi thêm instrumentation hoặc sampling mới cho luồng xuyên service.

## OBS-O02 — Alert/dashboard mới

**OPTIONAL.** Cân nhắc khi thêm alert/SLO/dashboard riêng; cần owner vận hành. Metric tối thiểu vẫn critical.

## OBS-O03 — Metric nghiệp vụ

**OPTIONAL.** Cân nhắc khi plan cần theo dõi chỉ số nghiệp vụ (đơn tạo, thanh toán thành công, tỷ lệ chuyển đổi) để phát hiện lỗi mà metric kỹ thuật không thấy; giữ label cardinality thấp như `OBS-002`.

**Bằng chứng:** log/metric mẫu đã redaction và test truyền context khi khả thi.
