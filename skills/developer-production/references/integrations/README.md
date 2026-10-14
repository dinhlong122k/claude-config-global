# Tích hợp

Đọc module khi feature thực sự dùng integration. Áp dụng các mục CRITICAL có trigger; cân nhắc OPTIONAL khi có nhu cầu cụ thể, theo [cổng quyết định](../governance/decision-gate.md). Các control [resilience](../controls/resilience.md), [error](../controls/error.md), [security](../controls/security.md), [observability](../controls/observability.md) và [testing](../controls/testing.md) sở hữu quy tắc chung.

| Integration | Reference |
| --- | --- |
| SFTP | [sftp.md](sftp.md) |
| MinIO | [minio.md](minio.md) |
| Keycloak | [keycloak.md](keycloak.md) |
| Redis cache | [redis-cache.md](redis-cache.md) |
| Rate limit | [rate-limit.md](rate-limit.md) |
| Kafka | [kafka.md](kafka.md) |

Redis làm backend rate limit không kích hoạt Redis cache. Với DB write kết hợp MinIO/Kafka/cache, đọc [data consistency](../controls/data-consistency.md).
