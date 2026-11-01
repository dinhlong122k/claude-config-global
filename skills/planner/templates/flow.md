# F-nn <Tên flow>

> Requirements: REQ-xxx | Ràng buộc: C-xx | Rủi ro: cao / thường
> Nguồn sự thật cho hành vi; thuật ngữ theo §2 plan. Mục lõi luôn có; mục `(điều kiện)` chỉ có khi áp dụng, không thì bỏ hẳn. Chỉ ghi lý do một dòng khi bỏ mục mà trigger routing tương ứng có mặt. Giá trị đến từ rule owner ghi kèm ID rule (vd `REL-001`).

## Bối cảnh

- Actor: <user / service / job>
- Trigger: <METHOD /path | topic | schedule>
- Precondition: <trạng thái bắt buộc; vi phạm → nhánh `B`>
- Transaction boundary: <vd S2–S4>

## Quyền truy cập (điều kiện: trigger có caller — API/HTTP, webhook/callback, hành động admin)

- Được gọi: <role/scope/điều kiện sở hữu>
- Kiểm ở: <cơ chế hiện có, `path:line`>
- Không đủ quyền: <nhánh `B`>; che giấu tài nguyên có tồn tại: có / không

## Validate input (điều kiện: trigger có input)

Kiểm ở biên, trước mọi ghi; mỗi rule sai trỏ đúng một `B`.

| Field | Kiểu / bắt buộc | Rule | Sai → |
| --- | --- | --- | --- |
| `<field>` | <…> | <…> | B1 |

Field thừa: <bỏ qua | nhánh `B` | theo validator `path:line`>

## Các bước

Mọi điều kiện rẽ nhánh có dòng `B`. Nhánh agent tự thêm ghi `(đề xuất)`; chưa rõ ghi `TODO` + Câu hỏi mở.

| # | Bước | Điều kiện rẽ nhánh → nhánh | Kết quả / side effect |
| --- | --- | --- | --- |
| S1 | <…> | <…> → B1 | <…> |

## Diagram (điều kiện: ≥ 3 participant hoặc ≥ 3 nhánh `B`)

`sequenceDiagram`: actor → entry point → service → store/integration; happy path đủ bước; mỗi `B` là một `alt`/`else` nhãn `Bk` kèm mã trả về.

## Mã kết quả

Mỗi `S` kết thúc và mỗi `B` đúng một dòng. Không phải HTTP → status/event tương ứng.

| Mã | HTTP/status | Bước/nhánh | Body/payload |
| --- | --- | --- | --- |
| `<CODE>` | <…> | S<n> / B<n> | <…> |

## Nhánh lỗi / biên

| # | Khi nào | Hành vi | Dữ liệu sau đó | Mã |
| --- | --- | --- | --- | --- |
| B1 | <…> | <…> | không đổi / <…> | <mã> |

## Trường hợp không liệt kê

Mặc định cho input/lỗi ngoài bảng nhánh: <dùng `<handler/validator, path:line>` | giữ hành vi hiện có | GAP (đã có trong Câu hỏi mở)>

## Ví dụ happy path (điều kiện: contract API/event client ngoài dùng)

Một cặp request/response (hoặc message vào + dữ liệu trước/sau) với giá trị thật, khớp dòng happy của "Mã kết quả".

## Thay đổi dữ liệu (điều kiện: có ghi, đọc có khóa hoặc ghi đồng thời)

Schema nằm ở §8 plan.

| Store | Thao tác | Field / điều kiện | Bước | Trong transaction |
| --- | --- | --- | --- | --- |
| `<store>` | <insert / update / select for update> | <…> | S<n> | có / không |

## Side effect và event (điều kiện: event, mail, webhook, cache, Kafka/MinIO)

| Tên (topic / event / key) | Bước | Payload / giá trị | Thời điểm so với commit | Phát thất bại → |
| --- | --- | --- | --- | --- |
| `<name>` | S<n> | <…> | <trước / sau commit, outbox — DATA-002> | <…> |

## Gọi ngoài (điều kiện: gọi hệ thống ngoài process)

Danh mục phụ thuộc ở §8 plan.

| Hệ thống / endpoint | Bước | Timeout | Retry (lần, backoff, điều kiện) | Lỗi / hết retry → |
| --- | --- | --- | --- | --- |
| `<system op>` | S<n> | <…> | <…> | B<n> |

## Trạng thái (điều kiện: có lifecycle)

`stateDiagram-v2` với nhãn chuyển là bước/nhánh. Chuyển bị cấm: <…>. Terminal: <…>.

## Invariants

- I1 <điều luôn đúng>

## Idempotency và concurrency (điều kiện: nhận lặp, ghi đồng thời, retry từ phía gọi)

Chỉ ghi dòng áp dụng.

- Idempotency: <key — lần lặp trả gì — lưu bao lâu>
- Đồng thời: <hai request cùng tài nguyên → kết quả mỗi bên, nhánh `B`>
- Khóa: <optimistic `version` | `select for update` | unique `<tên>`>
- Retry từ phía gọi: <an toàn vì … | không → nhánh `B`>

## Observability (điều kiện: log/metric/span mới ngoài mặc định `OBS-*`)

Không log dữ liệu thuộc `C-*` bảo mật. Dùng logger/metric hiện có (`path:line`).

| Bước / nhánh | Log (level, field) | Metric (tên, tag) | Span |
| --- | --- | --- | --- |
| S<n> / B<n> | <…> | <…> | <…> |
