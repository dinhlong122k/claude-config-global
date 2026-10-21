# Xử lý khi code lệch plan

Người thực thi **không sửa plan, flow hay `docs/TASKS.md`** (trừ tick step và ghi dòng `Kiểm chứng` của task đang làm); chỉ phân loại và báo trong report.

## PLAN-EXE-001 — Plan im lặng thì không tự sáng tác

**CRITICAL.** Hành vi quan sát được (response, error code, dữ liệu ghi, event, quyền truy cập) chỉ viết khi truy về một ID của task/flow. Trường hợp code phải xử lý mà plan không nói:

1. Flow có mục "Trường hợp không liệt kê" → làm theo.
2. Code hiện có đã xử lý đúng trường hợp đó → dùng lại, không viết bản song song.
3. Còn lại → **gap**: không code phần đó, ghi `GAPS` trong report; gap chặn acceptance criteria → `NEEDS_CONTEXT`.

Chi tiết nội bộ không quan sát được (tên biến, tách hàm private) quyết định theo `developer-production`, không cần ID.

## Phân loại

Đọc lại task và đúng các flow nó tham chiếu, đối chiếu code thật trước khi sửa.

| Loại | Ví dụ | Hành động |
| --- | --- | --- |
| Nhỏ | Tên symbol/line range khác plan nhưng cùng nghĩa; edge case mà plan **đã ghi rõ kết quả** | Làm theo code thật; ghi `DECISIONS` kèm căn cứ |
| Gap | Flow không có nhánh cho trường hợp code buộc xử lý; `Consumes` không tồn tại; cần file ngoài `Files` | Theo `PLAN-EXE-001` |
| Lớn | Đổi data model, contract đã chốt, thêm/bỏ thành phần hoặc flow | Dừng task này và task phụ thuộc, trả `BLOCKED` |

Không có căn cứ để chọn an toàn (`GOV-DEC-001`) → gap hoặc lớn, không bao giờ là nhỏ.

Sau task: hunk trong diff không truy về ID/step nào → hoàn tác.
