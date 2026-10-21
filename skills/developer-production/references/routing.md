# Điều hướng tài liệu

Đọc [GOV-DEC-001](governance/decision-gate.md) khi có quyết định quan trọng chưa rõ. Chọn các dòng có trigger thật trong thay đổi; đọc reference khi cần quyết định hoặc kiểm chứng liên quan. Không nạp toàn bộ catalog.

| Trigger | Rule owner cần đọc |
| --- | --- |
| Mọi feature production | [governance](governance/decision-gate.md), [error](controls/error.md), [observability](controls/observability.md), [testing](controls/testing.md), [code quality](controls/code-quality.md) |
| Flow thực tế lệch plan, plan không nói gì về trường hợp code phải xử lý, hoặc plan cần cập nhật giữa quá trình | [plan-execution](workflow/plan-execution.md) |
| Tạo/đổi module, folder hoặc dependency | [structure](architecture/structure.md), [dependencies](architecture/dependencies.md) |
| External call, file transfer, broker/cache | [external boundary](architecture/external-boundary.md), [resilience](controls/resilience.md) |
| API/HTTP | [HTTP/API](controls/http-api.md), [security](controls/security.md) |
| Input, identity, secret, dữ liệu nhạy cảm | [security](controls/security.md) |
| Database write, nhiều store | [data consistency](controls/data-consistency.md) |
| Query, index, pool hoặc ghi đồng thời | [data access](controls/data-access.md) |
| SFTP, MinIO, Keycloak, Redis cache, rate limit, Kafka | [integration tương ứng](integrations/README.md) |
| Java/Spring, TypeScript/Node, Python, Go | [stack adapter tương ứng](stacks/README.md) |

Rate limit dùng Redis không đồng nghĩa với Redis cache; chỉ đọc cache khi thật sự cache dữ liệu. Khi feature vừa ghi DB vừa publish Kafka hoặc ghi MinIO, đọc data-consistency. Đọc [phiếu rà soát](workflow/feature-review.md) cho integration hoặc luồng nhiều boundary.
