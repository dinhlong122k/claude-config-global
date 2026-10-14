# Rate limit

**Khi áp dụng:** giới hạn request, login attempt, job hoặc quota. Backend có thể là gateway, local, Redis hay dịch vụ khác.

## CRITICAL

| ID | Bắt buộc |
| --- | --- |
| RL-001 | Chốt operation, key scope (IP/user/API key/tenant), quota/window/burst, exemption và policy owner. Chống giả mạo identity/header; xét NAT và nhiều instance. |
| RL-002 | Chọn algorithm/store có atomic decision dưới concurrency; key có namespace/expiry. Nếu dùng Redis, kiểm tra lệnh/script atomic và version compatibility. |
| RL-003 | Chốt latency budget, connect/command/deadline và fail-open/fail-closed cho từng operation; security endpoint có thể khác endpoint thường. |
| RL-004 | Vượt quota trả error contract rõ: HTTP 429 và Retry-After nếu dùng HTTP; phân biệt quota exceeded với backend error. Không leak identity/key. |
| RL-005 | Đo blocked count, backend error, latency với label cardinality thấp. |
| RL-006 | Test ranh giới quota, request concurrent, tenant/key isolation, window reset, backend timeout/unavailable và response. |

## OPTIONAL — cân nhắc theo nhu cầu

| ID | Quyết định |
| --- | --- |
| RL-O01 | Token bucket/sliding window thay fixed window: cần fairness/burst chính xác hơn? |
| RL-O02 | Global quota đa region: consistency/latency/cost? |
| RL-O03 | Dynamic quota theo plan/tenant: source of truth và update? |
| RL-O04 | Header remaining/reset: API có muốn công khai thông tin? |
| RL-O05 | Adaptive throttling/load shedding: SLO và load signal đáng tin? |

**Cấu hình cần ghi:** scope, quota/window/burst, algorithm, backend, atomic operation, timeout/deadline, unavailable mode, 429 body/headers, metrics.

**Đối chiếu nếu dùng Redis:** [Redis rate limiting](https://redis.io/docs/latest/develop/use-cases/rate-limiter/).
