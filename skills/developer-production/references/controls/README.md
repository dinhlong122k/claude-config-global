# Quy tắc chung

| Trigger | Reference |
| --- | --- |
| Outbound I/O, cache, broker, file transfer | [resilience.md](resilience.md) |
| Mọi failure path | [error.md](error.md) |
| Input, identity, secret, dữ liệu nhạy cảm | [security.md](security.md) |
| Production request/job/message | [observability.md](observability.md) |
| HTTP inbound/outbound | [http-api.md](http-api.md) |
| DB write hoặc multi-store | [data-consistency.md](data-consistency.md) |
| Query/index/pool/concurrent write | [data-access.md](data-access.md) |
| Đổi hành vi/code | [testing.md](testing.md), [code-quality.md](code-quality.md) |

Integration chỉ bổ sung semantics và config riêng; không sao chép các control này.
