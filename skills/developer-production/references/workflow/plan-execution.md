# Đồng bộ plan khi triển khai

Áp dụng khi flow thực tế lệch plan, hoặc plan cần cập nhật giữa quá trình code. File này chỉ định nghĩa cách phân loại thay đổi và ghi lịch sử. Contract nội dung của `docs/IMPLEMENTATION_PLAN.md`, `docs/flows/` và `docs/TASKS.md` thuộc template của skill `planner`. Thứ tự thực thi task và ai review thuộc `CLAUDE.md` và agent `task-executor`.

## Trước mỗi task

Đọc lại plan index, task hiện tại và đúng các flow task đó tham chiếu. Đối chiếu với code thực tế và các task đã xong trước đó. Lệch → phân loại theo bảng dưới trước khi sửa code.

## Phân loại thay đổi

| Loại | Ví dụ | Hành động |
| --- | --- | --- |
| Nhỏ, trong phạm vi đã thống nhất | Đổi tên field, thêm một edge case, điều chỉnh không đổi contract | Cập nhật `docs/IMPLEMENTATION_PLAN.md`/flow/`docs/TASKS.md`, ghi lịch sử, rồi tiếp tục task hiện tại |
| Lớn, đổi hướng kiến trúc hoặc scope | Đổi data model, đổi API/contract đã chốt, thêm/bỏ thành phần kiến trúc hoặc flow | Dừng task này và task phụ thuộc, không tự code tiếp. Agent chính đưa người dùng thống nhất lại (brainstorming hoặc Plan Mode); subagent trả `BLOCKED` kèm bằng chứng |

Phân loại theo `GOV-DEC-001`: tự quyết khi thay đổi đảo ngược được và trong phạm vi; hỏi khi ảnh hưởng contract, dữ liệu hoặc rủi ro mà không có cơ sở chọn an toàn.

## Giữ lịch sử quyết định

Không xóa nội dung cũ rồi viết lại. Ghi vào "Lịch sử thay đổi" của plan:

`<YYYY-MM-DD> [nhỏ|lớn] <ID bị ảnh hưởng> — Trước đây: <…>. Nay: <…>. Vì: <lý do/bằng chứng>.`

ID ổn định: không đánh số lại, không tái sử dụng ID đã bỏ. Đổi nhánh/invariant của flow thì cập nhật test, task và ma trận truy vết trong cùng lần sửa.
