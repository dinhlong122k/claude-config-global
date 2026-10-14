---
name: planner
description: Lập plan theo template trước khi code cho feature vừa/lớn — làm rõ bài toán bằng superpowers:brainstorming, rồi giao task-planner chuyển design đã duyệt thành docs/IMPLEMENTATION_PLAN.md + docs/flows/F-*.md + docs/TASKS.md có ID truy vết tới test. Dùng thay superpowers:writing-plans; không dùng cho sửa nhỏ 1–2 file.
---

# Planner — brainstorming → plan theo template

Skill này chạy ở **agent chính**: chỉ agent chính hội thoại được với người dùng, nên phần làm rõ bài toán không giao cho subagent. Subagent `task-planner` chỉ chuyển design đã duyệt thành artifact.

## Chọn kích thước trước

| Việc | Cách làm |
| --- | --- |
| Sửa nhỏ, 1–2 file, rõ ràng | Không dùng skill này. Plan Mode hoặc làm thẳng. |
| Feature vừa/lớn, nhiều flow, đụng dữ liệu/API/auth | Chạy đủ quy trình dưới đây. |

## Quy trình

1. **Làm rõ bài toán** — invoke `superpowers:brainstorming`. Trong lúc hỏi, đảm bảo design doc cuối cùng có đủ thứ `task-planner` cần (xem "Đầu vào tối thiểu"). Không đọc checklist này ra như danh sách câu hỏi.
2. **Cổng 1 — duyệt design.** Theo HARD-GATE của brainstorming: người dùng duyệt design doc (`docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`). Chưa duyệt thì không sang bước 3.
3. **Sinh artifact** — sau khi design được duyệt, giao subagent `task-planner` (thay cho `superpowers:writing-plans`), truyền: path design doc, project root, và các quyết định chốt trong chat chưa nằm trong doc. `task-planner` ghi theo [templates](templates/):
   - `docs/IMPLEMENTATION_PLAN.md` — index, theo [IMPLEMENTATION_PLAN.md](templates/IMPLEMENTATION_PLAN.md)
   - `docs/flows/F-xx-<slug>.md` — mỗi flow một file, theo [flow.md](templates/flow.md)
   - `docs/TASKS.md` — theo [TASKS.md](templates/TASKS.md)
4. **Xử lý kết quả `task-planner`.**
   - `BLOCKED` → làm theo lý do trả về (thường là quay lại bước 1).
   - Còn mục trong "Câu hỏi mở" hoặc nhánh `TODO` trong flow → đưa người dùng trong **một** tin nhắn, quan trọng trước; cập nhật bằng cách giao lại `task-planner`.
5. **Cổng 2 — duyệt plan.** Đưa người dùng: danh sách flow, nhánh/invariant mà `task-planner` tự bổ sung (đánh dấu "đề xuất"), và các task rủi ro cao. Người dùng nên dồn thời gian review vào bảng nhánh của flow, không phải task.
6. **Thực thi** — theo [plan-execution](../developer-production/references/workflow/plan-execution.md) với `task-executor` và `plan-reviewer`. Khi thực thi một task, chỉ nạp `IMPLEMENTATION_PLAN.md` + flow mà task đó tham chiếu, không nạp toàn bộ `docs/flows/`.

Plan thay đổi giữa chừng → giao lại `task-planner` ở chế độ cập nhật; phân loại nhỏ/lớn theo `GOV-DEC-001`.

## Đầu vào tối thiểu của design doc

Design doc từ brainstorming nên trả lời được (nếu không, `task-planner` sẽ ghi vào "Câu hỏi mở" thay vì đoán):

- Mục tiêu, lý do, non-goals, anti-goals.
- Hành vi hiện có phải bảo toàn.
- Mỗi flow: actor, trigger, happy path, các nhánh lỗi/biên mà người dùng quan tâm.
- Trạng thái và chuyển trạng thái, nếu có lifecycle.
- Ràng buộc: contract/API không được đổi, dữ liệu, bảo mật, hiệu năng.
- Phần nào người dùng quyết, phần nào giao cho agent.

## Quy ước ID (dùng chung mọi artifact)

| ID | Ý nghĩa | Ví dụ |
| --- | --- | --- |
| `REQ-nnn` | Requirement + acceptance criteria | `REQ-003` |
| `C-nn` | Ràng buộc MUST / MUST NOT | `C-02` |
| `NG-nn` | Non-goal | `NG-01` |
| `F-nn` | Flow | `F-02` |
| `F-nn.Sk` / `F-nn.Bk` / `F-nn.Ik` | Bước / nhánh / invariant của flow | `F-02.B3` |
| `DEC-nnn` | Quyết định thiết kế (theo `GOV-DEC-001`) | `DEC-004` |
| `T-nn` | Task | `T-05` |

Tên test chứa ID nhánh hoặc invariant nó chứng minh, ví dụ `F02_B2_duplicate_callback_is_noop`, để `plan-reviewer` đối chiếu theo ID thay vì đọc hiểu tự do.

## Giới hạn kích thước

- `IMPLEMENTATION_PLAN.md` là index: giữ khoảng ≤ 200 dòng; chi tiết flow nằm trong `docs/flows/`.
- Một flow > ~150 dòng → tách sub-flow.
- Flow viết ở mức hợp đồng (bước, nhánh, điều kiện, side effect, invariant), không viết pseudo-code từng dòng.
- Không chép lại convention đã có trong CLAUDE.md hoặc `developer-production`; chỉ tham chiếu ID rule.
