# Khả năng chịu lỗi

## REL-001 — Timeout và deadline

**CRITICAL khi có outbound I/O.** Chốt operation deadline theo latency budget/SLO. Cấu hình các pha client hỗ trợ: pool acquisition, connect/TLS/SSH handshake, write, read/response, idle/poll và tổng operation. Pha không có ở client ghi không áp dụng cùng cơ chế deadline thay thế. Tổng retry phải nằm trong deadline; không lấy một con số chung cho mọi dependency.

## REL-002 — Retry an toàn

**CRITICAL khi SDK/client/service có retry hoặc có thể gọi lại sau timeout.** Phân loại transient/permanent, giới hạn attempt và tổng thời gian, backoff có jitter, tôn trọng backpressure. Side effect chỉ retry khi idempotent/deduplicate. Timeout sau khi gửi có thể cho kết quả không rõ; cần reconcile. Kiểm tra retry chồng tầng.

## REL-003 — Khi dependency hỏng

**CRITICAL khi dependency có thể unavailable/chậm.** Chốt fail-open/fail-closed/fail-fast hoặc fallback theo nghiệp vụ và security; không biến lỗi ghi thành thành công giả. Giải phóng connection, thread, stream và buffer.

## REL-O01 — Circuit breaker

**OPTIONAL.** Cân nhắc khi thêm breaker nếu downstream lỗi theo cụm và fail-fast có lợi.

## REL-O02 — Bulkhead/adaptive concurrency

**OPTIONAL.** Cân nhắc khi cô lập pool/thread hoặc thêm adaptive limit; cần evidence nghẽn tài nguyên.

**Bằng chứng:** cấu hình và test timeout, hết lượt retry, dependency unavailable.
