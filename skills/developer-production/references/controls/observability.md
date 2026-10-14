# Khả năng quan sát

## OBS-001 — Correlation xuyên boundary

**CRITICAL với request/job/file/message.** Tạo hoặc nhận correlation ID theo convention, validate ID do client gửi và truyền qua outbound call/message metadata. ID không chứa PII. Log operation, dependency, outcome và duration.

## OBS-002 — Metric tối thiểu

**CRITICAL với dependency hoặc xử lý async.** Đo success/failure/timeout/retry, latency và lag/backlog nếu có. Label cardinality thấp; không đặt user ID, object key, path hoặc message key trong metric label.

## OBS-O01 — Distributed tracing mở rộng

**OPTIONAL.** Cân nhắc khi thêm instrumentation hoặc sampling mới cho luồng xuyên service.

## OBS-O02 — Alert/dashboard mới

**OPTIONAL.** Cân nhắc khi thêm alert/SLO/dashboard riêng; cần owner vận hành. Metric tối thiểu vẫn critical.

**Bằng chứng:** log/metric mẫu đã redaction và test truyền context khi khả thi.
