# Xử lý khi code lệch plan

Áp dụng khi flow hoặc code thực tế không khớp task, hoặc task/flow không nói gì về một trường hợp code phải xử lý. Người thực thi **không sửa plan, flow hay `docs/TASKS.md`** (trừ tick step và ghi dòng `Kiểm chứng` của task đang làm); chỉ phân loại và báo trong report. Nội dung plan thuộc template của skill `planner`; thứ tự thực thi và ai review thuộc `CLAUDE.md` và agent `task-executor`.

## PLAN-EXE-001 — Closed world: plan không nói thì không tự sáng tác

**CRITICAL.** Hành vi quan sát được (response, status/error code, dữ liệu ghi xuống, event phát ra, quyền truy cập, log nghiệp vụ) chỉ được viết khi nó truy về được một ID trong task/flow (`REQ-*`, `F-nn.Sk`, `F-nn.Bk`, `F-nn.Ik`, `C-*`). Plan đúng nhưng thiếu không phải giấy phép để tự lấp chỗ trống: chỗ trống phải được làm lộ ra, không được "đoán hợp lý".

Gặp trường hợp code phải xử lý mà task/flow không liệt kê, giải theo thứ tự, dừng ở mức đầu tiên trả lời được:

1. Mục "Trường hợp không liệt kê" của flow quy định mặc định → làm theo, ghi `DECISIONS: <ID flow> mặc định`.
2. Code hiện có đã có hành vi cho đúng trường hợp đó (validator, error mapper, middleware dùng chung) → dùng lại, không viết bản song song; ghi `DECISIONS` kèm `path:line`.
3. Vẫn phải chọn một hành vi quan sát được mới → **GAP**: không code phần đó, không viết test cho hành vi tự đặt. Làm tiếp phần độc lập của task; ghi `GAPS:` trong report với trường hợp cụ thể, phương án, khuyến nghị.

Chi tiết nội bộ không quan sát được từ ngoài (tên biến cục bộ, tách hàm private, thứ tự câu lệnh không đổi kết quả) không cần ID; quyết định theo `developer-production`.

## Trước mỗi task

Đọc lại task hiện tại và đúng các flow nó tham chiếu. Chạy readiness check của `task-executor` (symbol `Consumes`, file, lệnh). Lệch → phân loại theo bảng dưới **trước khi** sửa code.

## Phân loại

| Loại | Ví dụ | Hành động |
| --- | --- | --- |
| Nhỏ, không đổi hành vi quan sát được | Tên field/symbol trong code có sẵn khác plan nhưng cùng nghĩa; line range trong `Files` đã dịch; edge case mà acceptance criteria hoặc flow **đã ghi rõ kết quả** | Làm theo code thật + acceptance criteria; ghi `DECISIONS` kèm ID |
| Thiếu (gap) | Flow không có nhánh cho input/trạng thái code buộc phải xử lý; không biết trả lỗi gì; `Consumes` trỏ tới symbol không tồn tại; cần file ngoài `Files` | Theo `PLAN-EXE-001`. Gap chặn acceptance criteria của task → trả `NEEDS_CONTEXT` cho task đó và task phụ thuộc |
| Lớn, đổi hướng kiến trúc hoặc scope | Đổi data model, API/contract đã chốt, thêm/bỏ thành phần hoặc flow | Dừng task này và task phụ thuộc, không code tiếp. Subagent trả `BLOCKED` kèm bằng chứng; agent chính hỏi người dùng |

Phân loại theo `GOV-DEC-001`: không có cơ sở chọn an toàn thì coi là gap hoặc lớn, không bao giờ là nhỏ. "Suy ra được" chỉ hợp lệ khi chỉ ra được dòng plan/flow/code làm căn cứ.

## Sau mỗi task — scope check

Mọi hunk trong diff của task phải truy về một ID hoặc một step của task. Hunk không truy được (refactor tiện tay, helper "phòng khi cần", validate thêm, đổi format file khác) → hoàn tác, hoặc nếu thật sự cần để task chạy được thì ghi vào `SCOPE` của report kèm lý do.
