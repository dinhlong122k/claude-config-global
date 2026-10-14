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
5. **Cổng 2 — duyệt plan.** Đưa người dùng: danh sách flow, nhánh/invariant mà `task-planner` tự bổ sung (đánh dấu "đề xuất"), và các task rủi ro cao. Người dùng nên dồn thời gian review vào bảng nhánh của flow, không phải task. Đây là cổng duyệt **cuối cùng trước khi code** — sau cổng này thực thi chạy liên tục.
6. **Thực thi** — invoke `superpowers:subagent-driven-development` với `PLAN_FILE = docs/TASKS.md` (không có subagent tool → `superpowers:executing-plans`).
   - Chạy liên tục, không dừng giữa các task, kể cả task rủi ro cao; review dồn ở cuối (review toàn branch của skill đó). Đây là lựa chọn đã chốt của người dùng.
   - Mỗi implementer chỉ nhận brief của task mình; brief trỏ tới đúng flow/nhánh cần đọc, không nạp toàn bộ `docs/flows/`.
   - Mâu thuẫn giữa task và flow: skill tự phân xử với spec làm chuẩn và ghi ruling vào ledger — không dừng hỏi.
7. **Sau khi chạy xong** — trước khi báo hoàn thành:
   - Giao `plan-reviewer` đối chiếu plan/flow với code theo ID (`F-nn.Bk`, `I-k`, `REQ-*`).
   - Giao `task-planner` (chế độ cập nhật) các ruling trong ledger để cập nhật flow và "Lịch sử thay đổi".
   - Báo người dùng một lượt: kết quả review cuối, các ruling đã đưa ra, và **các task rủi ro cao** (auth, dữ liệu, contract) kèm diff để họ soát lại vì chúng không có cổng dừng giữa chừng.

Plan cần đổi lớn (data model, contract, kiến trúc) mà skill thực thi không phân xử được an toàn → nó dừng theo điều kiện riêng của nó; quay lại bước 1 hoặc giao `task-planner` theo `GOV-DEC-001`.

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
