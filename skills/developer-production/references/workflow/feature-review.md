# Phiếu rà soát trước khi code

Checklist làm việc cho integration hoặc nhiều boundary; không bắt buộc tạo file hay điền bảng cho feature nhỏ. Chỉ ghi mục có trigger. Không đặt số timeout, retry, TTL, quota từ ví dụ.

## Quyết định

| ID | Điểm chưa rõ | Phương án/trade-off | Quyết định và người chốt | Reference phát sinh |
| --- | --- | --- | --- | --- |
| DEC-... | ... | ... | Quyết định hoặc chờ người có thẩm quyền | Reference liên quan |

## Rule và optional

| Rule ID | Trigger | CRITICAL/OPTIONAL | ÁP DỤNG / KHÔNG ÁP DỤNG / CHỜ CHỐT | Evidence hoặc chấp thuận |
| --- | --- | --- | --- | --- |
| ... | ... | ... | ... | ... |

Chỉ ghi control có trigger và optional được cân nhắc thực sự. Hỏi khi lựa chọn vượt phạm vi hoặc có hệ quả đáng kể theo `GOV-DEC-001`.

## Config, call và failure

| Dependency/operation | Endpoint/topic/bucket/path, auth, scope | Timeout/deadline/pool/size | Idempotency và side effect | Lỗi transient/permanent/kết quả không rõ | Caller thấy gì; retry/ack/commit/DLT |
| --- | --- | --- | --- | --- | --- |
| ... | ... | ... | ... | ... | ... |

Với message, ghi schema/key/group, commit point, invalid payload, retry, quarantine/DLT owner và xử lý khi gửi DLT thất bại. Với file/object, ghi partial state, checksum/size, cleanup và reconciliation. Với rate limit, ghi quota/scope/429/store outage.

## Bàn giao

Ghi lệnh formatter, static analysis, build và test **thực chạy**; evidence success, validation/auth, timeout/unavailable, duplicate/retry/rollback; diff và secret review; rủi ro còn lại. Check chưa chạy ghi `CHƯA CHẠY` và lý do.
