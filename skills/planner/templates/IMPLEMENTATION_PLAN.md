# <Tên feature> — Implementation Plan

> Status: DRAFT | APPROVED | IN_PROGRESS | DONE
> Design nguồn: `docs/superpowers/specs/<YYYY-MM-DD-topic>-design.md` (đã duyệt <ngày>)
> File này là **index**. Chi tiết luồng nằm trong `docs/flows/`; task nằm trong `docs/TASKS.md`.
> Khi thực thi một task: đọc file này + đúng các flow task đó tham chiếu, không đọc toàn bộ `docs/flows/`.

## 1. Mục tiêu

<1–3 câu: kết quả mong đợi và vì sao làm.>

## 2. Repository baseline

Chỉ ghi điểm đã đọc thật, dạng `path:line`. Không bịa file.

- `<path:line>` — <entry point / module / pattern cần tái dùng>

## 3. Phạm vi

**Được sửa** (ngoài danh sách này = phải hỏi lại):

- `<glob hoặc path>`

**Non-goals:**

- NG-01 <việc cố ý không làm>

**Hành vi hiện có phải bảo toàn:**

- <hành vi> — bảo vệ bởi `<test hiện có hoặc REQ-xxx>`

## 4. Ràng buộc

- C-01 MUST <…>
- C-02 MUST NOT <…>

## 5. Requirements

| ID | Requirement | Acceptance criteria (kiểm chứng được) | Flow |
| --- | --- | --- | --- |
| REQ-001 | <…> | <hành vi quan sát được / lệnh test> | F-01 |

## 6. Flows

| ID | Flow | Trigger | File | Rủi ro |
| --- | --- | --- | --- | --- |
| F-01 | <tên> | <API/event/job> | [F-01-<slug>](flows/F-01-<slug>.md) | cao / thường |

## 7. Quyết định thiết kế

| ID | Quyết định | Phương án đã loại | Đánh đổi | Nguồn |
| --- | --- | --- | --- | --- |
| DEC-001 | <…> | <…> | <…> | người dùng / agent đề xuất |

Chỉ ghi quyết định ảnh hưởng contract, dữ liệu hoặc trade-off đáng kể (theo `GOV-DEC-001`).

## 8. Contract & dữ liệu

Chỉ phần thay đổi; bỏ mục không áp dụng.

- API/event: <method path / topic — request/response/error codes — idempotency key>
- Schema/migration: <bảng/cột/index — tương thích ngược — cách rollback>

## 9. Câu hỏi mở

Phải **trống** (hoặc mọi mục đã có câu trả lời) trước khi Status = APPROVED.

- [ ] Q-01 <câu hỏi> — ảnh hưởng: <REQ/F/C nào> — đề xuất: <…>

## 10. Rollout / rollback

<feature flag, thứ tự deploy, cách rollback; bỏ nếu không áp dụng>

## 11. Lịch sử thay đổi

Không xóa nội dung cũ. Mỗi thay đổi ghi:

- <YYYY-MM-DD> [nhỏ|lớn] <ID bị ảnh hưởng> — Trước đây: <…>. Nay: <…>. Vì: <lý do/bằng chứng>.
