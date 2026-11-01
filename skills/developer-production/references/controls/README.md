# Quy tắc chung (controls)

Chính sách đa stack. Chọn file theo trigger trong [routing](../routing.md); bảng dưới chỉ là mục lục prefix → file, không phải nguồn trigger.

| Prefix | File | Phạm vi |
| --- | --- | --- |
| `ERR` | [error.md](error.md) | Error catalog, public error, final handler, cancellation |
| `REL` | [resilience.md](resilience.md) | Timeout, retry, dependency hỏng |
| `SEC` | [security.md](security.md) | Input, quyền, secret, PII, injection, file, audit |
| `OBS` | [observability.md](observability.md) | Correlation, metric, log |
| `API` | [http-api.md](http-api.md) | HTTP inbound/outbound, webhook, header |
| `EXC` | [external-client.md](external-client.md) | Response/error model riêng mỗi client, mapping model ⇄ external, bảng map lỗi, custom message và message gốc |
| `DATA` | [data-consistency.md](data-consistency.md) | Store có thẩm quyền, side effect, idempotent consumer, reconciliation |
| `DAL` | [data-access.md](data-access.md) | Query, pool, concurrent write, khối lượng |
| `DLV` | [delivery.md](delivery.md) | Migration, tương thích contract, thứ tự deploy, rollout |
| `RUN` | [runtime.md](runtime.md) | Config, shutdown, health, job, giới hạn tài nguyên |
| `TST` | [testing.md](testing.md) | Test hành vi, kiểm tra thực tế, tất định |
| `CQ` | [code-quality.md](code-quality.md) | Convention, comment, code tạm |

Mỗi file có phần **CRITICAL** (bắt buộc khi trigger đúng), **OPTIONAL** (mở rộng, theo `GOV-OPT-001`) và **OPTIONAL — financial domain** (bật theo `GOV-OPT-002`). Integration chỉ bổ sung semantics và config riêng; không sao chép các control này.
