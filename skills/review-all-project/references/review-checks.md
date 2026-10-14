# Review checks

`CRITICAL` = luôn xem trong review tổng thể nếu có bằng chứng phù hợp. `OPTIONAL` = chỉ xem khi người dùng chọn hoặc project có tín hiệu liên quan; khi đó vẫn phải báo rõ lý do. Mỗi check hỗ trợ bốn trạng thái: `pass`, `finding`, `unknown`, `not_applicable`. Mức ưu tiên của check không phải mức độ nghiêm trọng của finding.

| ID | Check | Mặc định | Câu hỏi trọng tâm |
| --- | --- | --- | --- |
| AR-01 | `check_functional_completeness()` | CRITICAL | Luồng chính, lỗi, test và yêu cầu đã khai báo có khoảng trống nào? |
| AR-02 | `check_security()` | CRITICAL | Trust boundary, authn/authz, input/output và quản lý secret có điểm yếu đã chứng minh? |
| AR-03 | `check_scalability()` | OPTIONAL | Có bottleneck khi tải/dữ liệu tăng, giới hạn scale-out và capacity plan? |
| AR-04 | `check_availability()` | CRITICAL | Điểm lỗi đơn, health/readiness và phụ thuộc gây downtime? |
| AR-05 | `check_resilience()` | CRITICAL | Timeout, retry, circuit breaker, backpressure và hành vi khi dependency lỗi? |
| AR-06 | `check_consistency()` | CRITICAL | Quy tắc nhất quán dữ liệu, transaction và xử lý concurrent update? |
| AR-07 | `check_performance()` | OPTIONAL | Đường nóng, query/IO/caching và bằng chứng đo đạc? |
| AR-08 | `check_observability()` | CRITICAL | Log/metric/trace đủ phát hiện, định vị sự cố mà không lộ dữ liệu? |
| AR-09 | `check_auditability()` | OPTIONAL | Sự kiện quan trọng có audit trail, tính toàn vẹn và truy xuất? |
| AR-10 | `check_data_integrity()` | CRITICAL | Validation, constraint, migration và đường ghi/xóa bảo toàn dữ liệu? |
| AR-11 | `check_idempotency()` | OPTIONAL | Retry/replay và thao tác lặp có gây side effect sai? |
| AR-12 | `check_disaster_recovery()` | OPTIONAL | Backup/restore, RPO/RTO và bằng chứng diễn tập? |
| AR-13 | `check_compliance()` | OPTIONAL | Chỉ đánh giá framework/điều khoản người dùng chỉ định; không tự tuyên bố đạt chuẩn pháp lý. |
| AR-14 | `check_operability()` | CRITICAL | Deploy/rollback, config, runbook và thao tác vận hành có rõ, an toàn? |

Người dùng có thể đổi mức `CRITICAL`/`OPTIONAL` cho từng check trước khi chạy. Nếu không có yêu cầu, dùng mặc định trên. Một check `OPTIONAL` có thể trở thành cần thiết theo ngữ cảnh, ví dụ hệ thống thanh toán cần idempotency, hệ thống chịu tải cao cần scalability/performance, hoặc hệ thống lưu dữ liệu quan trọng cần disaster recovery; nói rõ lý do và xin chấp thuận phạm vi nếu phát sinh công việc đáng kể.
