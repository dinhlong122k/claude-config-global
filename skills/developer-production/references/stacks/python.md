# Adapter Python

**Khi áp dụng:** repository dùng Python. Đây là checklist theo stack; không phải thư viện code mẫu đã kiểm chứng.

## CRITICAL

| ID | Cách áp dụng |
| --- | --- |
| PY-001 | Runtime validation tại API/worker; type hint không tự bảo vệ input. |
| PY-002 | Client sync/async phù hợp execution model; truyền connect/read/write/pool timeout và deadline; đóng session/stream, xử lý cancellation. |
| PY-003 | Test retry, worker ack/commit, serialization error, timeout và context propagation theo thư viện thực tế. |

## OPTIONAL — cân nhắc theo nhu cầu

| ID | Quyết định |
| --- | --- |
| PY-O01 | Thêm validation/schema library khi repo đã có chuẩn khác? |

Tách domain/application khỏi FastAPI/Django/worker/SDK; external adapter ở vị trí đã chốt. Không chọn thư viện mới chỉ vì adapter này nêu ví dụ.
Đổi concurrency model thuộc `DAL-O02`; tách deployment thuộc `ARC-STR-O01`.
