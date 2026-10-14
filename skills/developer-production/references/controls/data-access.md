# Truy cập dữ liệu và hiệu năng

## DAL-001 — Query và index theo access pattern

**CRITICAL khi thêm query/schema ảnh hưởng đường nóng.** Kiểm tra N+1, số round trip, paging/result limit, index theo filter/sort/join và chi phí write. Dùng query plan/evidence khi có rủi ro; không thêm index tùy tiện.

## DAL-002 — Pool và tài nguyên

**CRITICAL khi thêm DB/cache/HTTP client hoặc worker đồng thời.** Chốt pool size, acquisition timeout, idle/lifetime và concurrency theo downstream capacity. Đóng transaction/cursor/stream; tránh giữ DB transaction trong external call chậm.

## DAL-003 — Concurrent write

**CRITICAL khi ghi đồng thời có thể phá invariant.** Chọn constraint, optimistic version, row lock hoặc pattern phù hợp; test race/conflict. Cache/distributed lock không thay DB invariant.

## DAL-O01 — Cache mới

**OPTIONAL.** Cân nhắc khi thêm cache tối ưu query; nếu dùng Redis, đọc catalog Redis cache.

## DAL-O02 — Đổi concurrency model

**OPTIONAL.** Cân nhắc khi đổi sang virtual threads/reactive hoặc tương đương; cần benchmark và rà blocking client.

**Bằng chứng:** query plan/benchmark khi liên quan, concurrency test và cấu hình pool.
