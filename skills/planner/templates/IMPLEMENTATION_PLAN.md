# <Tên feature> — Implementation Plan

> Status: DRAFT | APPROVED | IN_PROGRESS | DONE
> Design nguồn: `docs/superpowers/specs/<YYYY-MM-DD-topic>-design.md` (đã duyệt <ngày>)
> Task list: `docs/TASKS.md` | Tracker ngoài: <tên/link> | —
> Index cho người duyệt: đọc §1 → flow rủi ro cao → §13. Người thực thi chỉ mở file này khi brief trỏ tới một mục. Mỗi thông tin nằm một nơi; nơi khác ghi ID.
> Mục lõi luôn có; mục `(điều kiện)` chỉ có khi áp dụng, không thì bỏ hẳn (giữ số các mục còn lại). Chỉ ghi lý do một dòng khi bỏ mục mà trigger routing tương ứng có mặt.

## 1. Tóm tắt cho reviewer

Viết sau cùng. Chỉ trỏ ID, không chép nội dung.

**TL;DR:** <≤ 3 câu: làm gì; chạm contract / dữ liệu / auth hay không; số flow, task, task rủi ro cao.>
**Thay đổi phá vỡ:** không | <ID>

**Điểm cần duyệt** (mọi mục có quyết định trước khi APPROVED; không có → "Không có"):

| # | Loại | ID | Cần quyết gì | Agent đề xuất |
| --- | --- | --- | --- | --- |
| 1 | <đề xuất / GAP / DEC / rủi ro cao / CHƯA XÁC ĐỊNH / Q> | <ID> | <…> | <…> |

## 2. Mục tiêu

- **Hiện trạng:** <hành vi hôm nay + bằng chứng `path:line`>
- **Vấn đề:** <hậu quả cụ thể; ai bị ảnh hưởng>
- **Mục tiêu:** <1–3 câu, kết quả quan sát được; kiểm chứng ở §5>
- **Thuật ngữ** (điều kiện: có khái niệm mới hoặc dễ nhầm): `<thuật ngữ>` = <nghĩa> — code `<Symbol>` (`path:line`) — không dùng <từ khác>

## 3. Phạm vi

- **Được sửa** (ngoài danh sách = phải hỏi lại): `<glob hoặc path>`
- **Non-goals:** NG-01 <việc cố ý không làm>
- **Hành vi phải bảo toàn:** <hành vi> — bảo vệ bởi `<test hiện có | REQ-xxx>`

## 4. Ràng buộc (điều kiện: design có ràng buộc, hoặc trigger Input/identity/secret, API/HTTP, Query/index, Migration/contract)

MUST / MUST NOT, giá trị chính xác; ghi ID rule nếu đến từ rule owner. Loại cần xét: tương thích ngược, authz, dữ liệu nhạy cảm, hiệu năng, observability, giới hạn tài nguyên — chỉ ghi loại áp dụng.

| ID | Loại | Ràng buộc | Kiểm bằng |
| --- | --- | --- | --- |
| C-01 | <loại> | <MUST …> | <test / lệnh / review> |

## 5. Requirements

| ID | Requirement | Acceptance criteria (kiểm chứng được) | Flow |
| --- | --- | --- | --- |
| REQ-001 | <…> | <hành vi quan sát được / lệnh test> | F-01 |

## 6. Flows

| ID | Flow | Trigger | Actor / quyền | File | Rủi ro |
| --- | --- | --- | --- | --- | --- |
| F-01 | <tên> | <API/event/job> | <role> | [F-01-<slug>](flows/F-01-<slug>.md) \| gọn — [§6 F-01](#f-01-tên) | cao / thường |

Flow gọn viết ngay dưới đây, heading `### F-nn <tên>`: Bối cảnh (Actor, Trigger), Các bước, Nhánh lỗi / biên, Mã kết quả, Trường hợp không liệt kê — cấu trúc theo `flow.md`.

## 7. Baseline và thành phần

Chỉ điểm đã đọc thật (`path:line`):

- Entry point / pattern tái dùng: `<path:line>`
- Cấu trúc vùng thay đổi: `<dir>/` — <entry point, domain, persistence, adapter>
- Stack / integration: <tên theo bảng stack, integration> — theo `<manifest>`
- Convention error code: `<path:line>` | không có
- Doc hiện có: `<file>` — <bề mặt nó mô tả>

Diagram (điều kiện: ≥ 3 thành phần bị chạm hoặc tạo/đổi module, folder, dependency): `flowchart`, ≤ 15 node, nhãn node `mới / sửa / chỉ đọc`, nhãn cạnh `F-nn`.

## 8. Contract, dữ liệu, phụ thuộc ngoài (điều kiện: trigger Migration/contract, API/HTTP, Database write → bảng contract/schema; External call, external client, integration → bảng phụ thuộc)

Chỉ phần thay đổi; bảng con không áp dụng → bỏ. Hành vi runtime nằm trong flow.

| Bề mặt API / event | Thay đổi | Tương thích ngược | Flow / DEC |
| --- | --- | --- | --- |
| <…> | <…> | có / không: <client nào vỡ> | <ID> |

| Store | Thay đổi schema | Tương thích code cũ | Backfill | Rollback | Task |
| --- | --- | --- | --- | --- | --- |
| <…> | <…> | <…> | không / <cách> | <…> | <T-nn> |

| Phụ thuộc ngoài | Dùng ở | Phiên bản / contract | Chủ sở hữu | Mới? | Không sẵn sàng → |
| --- | --- | --- | --- | --- | --- |
| <…> | <F-nn.Sk> | <…> | <…> | có / không | <F-nn.Bk> |

## 9. Quyết định và rủi ro (điều kiện: có `DEC-*`, task rủi ro cao hoặc rủi ro đáng kể khác)

Quyết định ảnh hưởng contract, dữ liệu hoặc trade-off đáng kể (`GOV-DEC-001`); nguồn agent → có dòng ở §1.

| ID | Quyết định | Phương án đã loại | Đánh đổi | Nguồn |
| --- | --- | --- | --- | --- |
| DEC-001 | <…> | <…> | <…> | người dùng / agent |

| Rủi ro | Ảnh hưởng / khả năng | Giảm thiểu | ID |
| --- | --- | --- | --- |
| <…> | cao / vừa / thấp | <test, flag, thứ tự task> | <ID> |

## 10. Kế hoạch task

Index, không chép nội dung task. Phụ thuộc từ gốc lên; rủi ro cao sớm nhất có thể.

| Phase | Task | Slice (flow / nhánh) | Quy mô |
| --- | --- | --- | --- |
| 1 Nền | T-01 | <…> | XS / S / M |

## 11. Rollout / rollback (điều kiện: trigger Migration/contract/nhiều deployable, hoặc có feature flag)

- Thứ tự deploy: <…>
- Feature flag: `<tên>` — mặc định <…>; điều kiện bật
- Code cũ và mới chạy song song: <an toàn vì … | cần …>
- Rollback: <bước; dữ liệu đã ghi xử lý thế nào>
- Theo dõi sau deploy: <metric/log, ngưỡng>

## 12. Definition of Done

Lệnh thật của repo; không tìm thấy → `CHƯA XÁC ĐỊNH: <lý do>` + dòng ở §1. Checkpoint của task chép lệnh từ đây.

- Full test: `<lệnh>` → PASS
- Build / lint / type-check: `<lệnh>` → exit 0
- Cấp test dùng (chỉ khi > 1 cấp hoặc cần môi trường riêng): <unit | integration | e2e> — `<lệnh>` — <môi trường / fixture dùng chung>
- Ma trận truy vết trong `docs/TASKS.md` không ô trống, mọi test PASS; doc ở mọi `Docs:` đã cập nhật
- <Kiểm tra thêm: migration lên/xuống, load test C-xx> | —

## 13. Checklist duyệt

Người duyệt tick ở cổng 2; agent không tick.

- [ ] Non-goals và "Hành vi phải bảo toàn" đúng ý
- [ ] Giá trị ở §4 đúng (số, tên, quyền)
- [ ] Bảng nhánh và "Trường hợp không liệt kê" của flow rủi ro cao đúng nghiệp vụ
- [ ] Thay đổi ở §8 có tương thích ngược hoặc rollback chấp nhận được
- [ ] Task rủi ro cao đúng và đủ

## 14. Câu hỏi mở

Phải trống (hoặc đã trả lời hết) trước khi APPROVED.

- [ ] Q-01 <câu hỏi> — ảnh hưởng: <ID> — đề xuất: <…>

## 15. Lịch sử thay đổi

Không xóa nội dung cũ. Mỗi dòng: `<YYYY-MM-DD> [nhỏ|lớn] <ID> — Trước đây: <…>. Nay: <…>. Vì: <…>.`
