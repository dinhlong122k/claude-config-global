# Adapter TypeScript/Node

**Khi áp dụng:** repository dùng TypeScript/Node. Đây là checklist theo stack; không phải thư viện code mẫu đã kiểm chứng.

## CRITICAL

| ID | Cách áp dụng |
| --- | --- |
| TS-001 | Validate JSON/request/message tại runtime; TypeScript type không xác minh input ngoài tiến trình. |
| TS-002 | Truyền deadline/cancellation qua Promise, stream và worker; đóng client/socket khi shutdown; kiểm tra SDK retry. |
| TS-003 | Test rejected Promise, serialize/deserialize failure, timeout và correlation propagation qua request/worker. |

## OPTIONAL — cân nhắc theo nhu cầu

| ID | Quyết định |
| --- | --- |
| TS-O01 | Thêm validation/DI/queue framework mới? |
| TS-O02 | Đổi HTTP client, module system hoặc runtime để dùng một integration? |

Port/interface do consumer sở hữu; SFTP/S3/OIDC/Redis/Kafka SDK ở external adapter. Chọn package theo repo và test version/API đang dùng.
Wrapper dùng chung thuộc `ARC-EXT-O01`.
