# Adapter Go

**Khi áp dụng:** repository dùng Go. Đây là checklist theo stack; không phải thư viện code mẫu đã kiểm chứng.

## CRITICAL

| ID | Cách áp dụng |
| --- | --- |
| GO-001 | Truyền `context.Context`/deadline qua handler, repository và external client; hủy goroutine và đóng response/session. |
| GO-002 | Test race/concurrent write khi xử lý request hoặc message song song; bảo vệ DB invariant bằng constraint/transaction. |
| GO-003 | Wrap error giữ cause, map tại boundary; test timeout/cancellation, stream close và shutdown. |

## OPTIONAL — cân nhắc theo nhu cầu

| ID | Quyết định |
| --- | --- |
| GO-O01 | Thêm router/framework/DI container mới? |

Interface nhỏ do consumer sở hữu; external client ở adapter. Kiểm tra API/version của thư viện đang pin trong repo.
Wrapper dùng chung thuộc `ARC-EXT-O01`; tách deployment thuộc `ARC-STR-O01`.
