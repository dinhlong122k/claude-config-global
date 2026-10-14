# Xử lý lỗi

## ERR-001 — Taxonomy lỗi

**CRITICAL khi operation có failure path quan sát được.** Phân biệt các lỗi có thể phát sinh: validation, unauthenticated, forbidden, not-found/conflict, dependency transient/permanent, timeout, invalid message hoặc kết quả không rõ sau side effect. Contract công khai dùng mã ổn định, retryability và outcome phù hợp; không retry mọi lỗi kỹ thuật.

## ERR-002 — Lỗi công khai an toàn

**CRITICAL khi lỗi tới caller.** Caller nhận error code, thông điệp an toàn và correlation ID. Không trả raw exception, stack trace, secret, token, path nội bộ hoặc payload nhạy cảm. Async handler có disposition rõ: retry, quarantine/DLT hoặc dừng; không nuốt lỗi.

## ERR-003 — Ghi lỗi ở boundary cuối

**CRITICAL khi log failure.** Log lỗi terminal một lần tại nơi xử lý cuối; lớp trung gian giữ cause/context. Validation/not-found kỳ vọng không tạo ERROR alert. Retry attempt có metric và log phù hợp, tránh log storm.

## ERR-O01 — Diagnostic surface mới

**OPTIONAL.** Cân nhắc khi thêm dashboard, endpoint chẩn đoán hoặc error taxonomy chi tiết hơn; kiểm soát dữ liệu nhạy cảm.

**Bằng chứng:** test đường lỗi và ví dụ error response/message disposition.

Ví dụ contract HTTP tối thiểu: `{ "code": "DEPENDENCY_TIMEOUT", "message": "Tạm thời chưa thể xử lý", "correlationId": "..." }`. Chi tiết cause và dependency chỉ ở log/trace đã redaction; status HTTP được chọn theo outcome của operation.
