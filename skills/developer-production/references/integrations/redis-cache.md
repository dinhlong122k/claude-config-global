# Redis cache

**Khi áp dụng:** Redis lưu cache dữ liệu ứng dụng. Redis chỉ dùng cho rate limit không kích hoạt file này.

## CRITICAL

| ID | Bắt buộc |
| --- | --- |
| REDIS-001 | Chốt authoritative store, datum được cache, stale budget, key namespace/version và tenant/user scope. Không cache secret/token hoặc datum có freshness không phù hợp. |
| REDIS-002 | Cấu hình endpoint/TLS/auth, connect/command/pool timeout, operation deadline, pool/memory/key/value limit. |
| REDIS-003 | TTL dựa trên stale budget; invalidation/update sau committed write. Chốt serialization/schema compatibility, miss, negative caching nếu có và key collision. |
| REDIS-004 | Chốt Redis timeout/unavailable/eviction và stale-data behavior. Source vẫn authoritative; không ghi cache trước DB commit rồi expose dữ liệu chưa commit. |
| REDIS-005 | Phân loại connect/auth/timeout/serialization/command/memory lỗi; map lỗi và đo hit/miss/error/latency. Tránh retry cache liên tục trên request path. |
| REDIS-006 | Test hit/miss/TTL, invalidation sau commit/rollback, serialization version, outage, tenant isolation và concurrent miss khi có stampede risk. |

## OPTIONAL — cân nhắc theo nhu cầu

| ID | Quyết định |
| --- | --- |
| REDIS-O01 | TTL jitter/single-flight/stampede lock: traffic/expiry có tạo tải đột biến? |
| REDIS-O02 | Cache warming: cold start ảnh hưởng SLO? |
| REDIS-O03 | Stale-while-revalidate: nghiệp vụ chấp nhận stale interval lớn hơn? |
| REDIS-O04 | Pub/sub invalidation: có cache local đa instance cần đồng bộ? |
| REDIS-O05 | Cluster/Sentinel/read replica: yêu cầu availability/scale? |

**Cấu hình cần ghi:** endpoint, TLS/auth, timeout/pool/deadline, key format, TTL/stale budget, invalidation, serializer/version, outage mode, metrics.
