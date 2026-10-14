# SFTP

**Khi áp dụng:** upload/download/poll/move/delete qua SFTP. Dùng external adapter theo `ARC-STR-002` và `ARC-EXT-001`.

## CRITICAL

| ID | Bắt buộc |
| --- | --- |
| SFTP-001 | Chốt chiều truyền, host/port, auth bằng key/password, remote root, quyền read/write/delete, trust source và rotation. Xác minh host key; host key đổi là lỗi cần xử lý có kiểm soát. |
| SFTP-002 | Ghi cấu hình connect/auth/handshake, read/write/idle, operation deadline, session/pool limit, max file size theo `REL-001`; stream file lớn và đóng session/stream trên mọi nhánh. |
| SFTP-003 | Chuẩn hóa path dưới root allow-list; chống traversal, tên file sai, trùng tên và truy cập chéo tenant. |
| SFTP-004 | Chốt trạng thái file hoàn tất: temp upload + rename khi server hỗ trợ, hoặc marker/manifest đã thỏa thuận. Xử lý partial transfer và kiểm tra size/checksum theo contract. |
| SFTP-005 | Phân loại auth/host-key/path/permission/not-found/connection/timeout/partial-transfer; retry chỉ khi có idempotency hoặc xác định được remote state. Timeout sau gửi có thể cho kết quả không rõ. |
| SFTP-006 | Test success, host-key sai, thiếu quyền, partial, timeout, unavailable, duplicate và cleanup; map lỗi an toàn cho caller. |

## OPTIONAL — cân nhắc theo nhu cầu

| ID | Quyết định |
| --- | --- |
| SFTP-O01 | Session pooling/cache: throughput có biện minh xử lý stale session không? |
| SFTP-O02 | Resume/chunking: file lớn và server có hỗ trợ tiếp tục an toàn không? |
| SFTP-O03 | PGP/file-level encryption: đối tác có yêu cầu vượt SSH transport không? |
| SFTP-O04 | Polling scheduler/remote archive: lịch và retention đã chốt chưa? |
| SFTP-O05 | Quarantine/virus scanning: dữ liệu nhận có cần kiểm tra bổ sung không? |

**Cấu hình cần ghi:** endpoint, remote root, credential ref, known-host source, timeout/deadline, pool, max size, retry, temp/rename mode, checksum, retention, error map.
