# Truy cập dữ liệu và hiệu năng

## DAL-001 — Query và index theo access pattern

**CRITICAL khi thêm query/schema ảnh hưởng đường nóng.** Kiểm tra N+1, số round trip, paging/result limit, index theo filter/sort/join và chi phí write. Dùng query plan/evidence khi có rủi ro; không thêm index tùy tiện.

## DAL-002 — Pool và tài nguyên

**CRITICAL khi thêm DB/cache/HTTP client hoặc worker đồng thời.** Chốt pool size, acquisition timeout, idle/lifetime và concurrency theo downstream capacity. Đóng transaction/cursor/stream; tránh giữ DB transaction trong external call chậm.

## DAL-003 — Concurrent write

**CRITICAL khi ghi đồng thời có thể phá invariant.** Chọn constraint, optimistic version, row lock hoặc pattern phù hợp; test race/conflict. Cache/distributed lock không thay DB invariant.

## DAL-004 — Query giới hạn thời gian và khối lượng

**CRITICAL khi thêm query hoặc thao tác dữ liệu hàng loạt.** Mọi query có statement/query timeout phù hợp deadline `REL-001`. Update/delete hàng loạt chạy theo batch có giới hạn, commit từng batch, không khóa bảng lâu. Không `SELECT *` khi chỉ cần vài cột trên bảng lớn; đọc kết quả lớn bằng cursor/stream hoặc keyset paging theo `RUN-005`. Transaction ngắn, không chờ input hay external call bên trong.

## DAL-O01 — Cache mới

**OPTIONAL.** Cân nhắc khi thêm cache tối ưu query; nếu dùng Redis, đọc catalog Redis cache.

## DAL-O02 — Đổi concurrency model

**OPTIONAL.** Cân nhắc khi đổi sang virtual threads/reactive hoặc tương đương; cần benchmark và rà blocking client.

## DAL-O03 — Read replica

**OPTIONAL.** Cân nhắc khi tải đọc vượt primary; phải chấp nhận replication lag, không đọc replica ngay sau khi ghi (read-your-writes) và không dùng replica cho kiểm tra invariant.

## DAL-O04 — Partition/archive dữ liệu

**OPTIONAL.** Cân nhắc khi bảng tăng không giới hạn (log, event, giao dịch); chốt khóa partition, chính sách archive/xóa theo retention `SEC-003` và ảnh hưởng tới query hiện có.

**Bằng chứng:** query plan/benchmark khi liên quan, concurrency test và cấu hình pool.
