# Chốt plan và thực thi theo task

Áp dụng ngay sau khi Plan Mode (hoặc tương đương) đã thống nhất hướng triển khai với người dùng. File này chỉ mô tả cách chốt plan thành artifact, chia task và giữ plan–code đồng bộ trong khi triển khai; không định nghĩa lại contract nội dung của `docs/IMPLEMENTATION_PLAN.md` — contract đó thuộc template của skill `planner`.

## Chốt plan thành artifact

Giao agent `task-planner` (model sonnet — cần dựng bảng nhánh flow và phát hiện nhánh thiếu, không chỉ chép lại). Quy trình đầy đủ (brainstorming → cổng duyệt → task-planner) và template thuộc skill [planner](../../../planner/SKILL.md):

1. Ghi/cập nhật `docs/IMPLEMENTATION_PLAN.md` (index) và `docs/flows/F-*.md` đúng theo design đã duyệt (từ `superpowers:brainstorming` hoặc Plan Mode) — không tự thêm hoặc suy diễn yêu cầu mới; nhánh tự bổ sung phải ghi `(đề xuất)`.
2. Tạo/cập nhật `docs/TASKS.md`: danh sách task rời rạc, có thứ tự, mỗi task có ID ổn định (`T-...`), mục tiêu, file/module dự kiến, dependency, và tiêu chí "done" kiểm chứng được (test pass, build pass, hành vi quan sát được cụ thể). Task đủ nhỏ để review riêng lẻ.
3. Nếu plan/task đã tồn tại, không ghi đè nội dung cũ — xem mục "Giữ lịch sử quyết định" dưới đây.

## Thực thi tuần tự theo task

Plan sinh từ skill [planner](../../../planner/SKILL.md) (`docs/TASKS.md` có heading `## Task N (T-nn)`) thực thi bằng `superpowers:subagent-driven-development`, chạy liên tục và review dồn ở cuối — theo bước 6–7 của skill đó, không theo mục này. Mục này áp dụng cho plan chốt từ Plan Mode không qua skill `planner`.

Giao agent `task-executor` (model sonnet) lặp qua `docs/TASKS.md` theo đúng thứ tự, không nhảy cóc:

1. **Trước mỗi task**: đọc lại `docs/IMPLEMENTATION_PLAN.md` và task hiện tại để xác nhận còn đúng phạm vi đã thống nhất; nếu lệch, xử lý theo "Phân loại thay đổi" trước khi code.
2. Triển khai đúng phạm vi task đó, không gộp các task không liên quan.
3. **Sau mỗi task**: chạy test/build liên quan để xác nhận không phá vỡ hành vi hiện có, rồi đánh dấu task done trong `docs/TASKS.md` kèm lệnh đã chạy và kết quả. Task chưa kiểm chứng được phải ghi "CHƯA CHẠY" và lý do, không tự nhận đã test.
4. **Task rủi ro cao** (đụng auth, dữ liệu, hoặc đổi API/contract công khai): sau khi code xong task đó, dừng lại và hỏi người dùng xác nhận trước khi sang task kế tiếp — không tự tiếp tục chuỗi.
5. Sau một nhóm task liên quan, hoặc ngay sau khi plan vừa đổi đáng kể, giao `plan-reviewer` đối chiếu plan với code thực tế trước khi tiếp tục; với thay đổi logic, vẫn áp dụng `security-reviewer` theo quy trình chính của skill này.

## Cập nhật plan khi có thay đổi (living document)

Giao lại `task-planner` khi phát sinh thay đổi trong lúc code, thay vì chỉ trao đổi trong chat rồi quên:

| Loại thay đổi | Ví dụ | Hành động |
| --- | --- | --- |
| Nhỏ, trong phạm vi đã thống nhất | Đổi tên field, thêm một edge case, điều chỉnh không đổi contract | Agent tự cập nhật `docs/IMPLEMENTATION_PLAN.md`/`docs/TASKS.md`, ghi rõ lý do, rồi tiếp tục task hiện tại |
| Lớn, đổi hướng kiến trúc hoặc scope | Đổi data model, đổi API/contract đã thống nhất, thêm/bỏ một thành phần kiến trúc | Dừng task phụ thuộc, không tự code tiếp; quay lại Plan Mode (hoặc tương đương) để thống nhất lại với người dùng trước khi cập nhật plan |

Phân loại này áp dụng `GOV-DEC-001`: agent tự quyết với thay đổi đảo ngược được và trong phạm vi; hỏi người dùng khi thay đổi ảnh hưởng contract, dữ liệu hoặc rủi ro mà không có cơ sở chọn an toàn.

## Giữ lịch sử quyết định

Khi sửa `docs/IMPLEMENTATION_PLAN.md` hoặc `docs/TASKS.md` do đổi hướng, không xóa sạch nội dung cũ rồi viết lại — ghi tiếp dạng: "Trước đây: <mô tả cũ>. Nay: <mô tả mới>. Vì: <lý do/bằng chứng>." Mục này giúp `plan-reviewer` và các agent/session sau hiểu bối cảnh quyết định khi đối chiếu plan với code.

## Đồng bộ plan–code

Sau mỗi lần plan thay đổi đáng kể (không phải thay đổi nhỏ), giao `plan-reviewer` chạy một vòng đối chiếu nhanh giữa `docs/IMPLEMENTATION_PLAN.md`/`docs/TASKS.md` và code thực tế trước khi tiếp tục task kế tiếp, để tránh lệch pha kéo dài qua nhiều task hoặc nhiều session.
