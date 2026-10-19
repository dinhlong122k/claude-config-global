# Xử lý khi code lệch plan

Áp dụng khi flow hoặc code thực tế không khớp task. Người thực thi **không sửa plan, flow hay `docs/TASKS.md`** (trừ tick step và ghi dòng `Kiểm chứng` của task đang làm); chỉ phân loại và báo trong report. Nội dung plan thuộc template của skill `planner`; thứ tự thực thi và ai review thuộc `CLAUDE.md` và agent `task-executor`.

## Trước mỗi task

Đọc lại task hiện tại và đúng các flow nó tham chiếu. Đối chiếu với code thực tế và các task đã xong trước đó. Lệch → phân loại theo bảng dưới trước khi sửa code.

## Phân loại

| Loại | Ví dụ | Hành động |
| --- | --- | --- |
| Nhỏ, không đổi contract | Tên field khác trong code có sẵn, thiếu một edge case đã suy ra được từ acceptance criteria | Làm theo cách khớp code và acceptance criteria; ghi lệch vào `DECISIONS` của report |
| Lớn, đổi hướng kiến trúc hoặc scope | Đổi data model, API/contract đã chốt, thêm/bỏ thành phần hoặc flow | Dừng task này và task phụ thuộc, không code tiếp. Agent chính hỏi người dùng; subagent trả `BLOCKED` kèm bằng chứng |

Phân loại theo `GOV-DEC-001`: không có cơ sở chọn an toàn thì coi là lớn.
