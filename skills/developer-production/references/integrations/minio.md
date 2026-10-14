# MinIO

**Khi áp dụng:** MinIO object storage. Dùng external adapter và quy tắc chung.

## CRITICAL

| ID | Bắt buộc |
| --- | --- |
| MINIO-001 | Chốt endpoint/TLS, bucket, region nếu có, credential scope, quyền tối thiểu và bucket owner. |
| MINIO-002 | Cấu hình connect/write/read/pool timeout, operation deadline, retry của SDK, max object size, stream và connection limit; đóng response stream. |
| MINIO-003 | Object key có namespace/tenant/version; validate size, content type và metadata. Chốt overwrite/version/delete; không tin filename client. |
| MINIO-004 | Phân loại bucket/object not-found, denied, invalid credential, precondition/conflict, checksum mismatch, timeout, 5xx và upload có kết quả không rõ. Kiểm tra object state trước khi retry side effect. |
| MINIO-005 | Nếu DB lưu metadata, chốt authoritative store và failure window; có cleanup/reconciliation cho orphan object hoặc metadata. |
| MINIO-006 | Test put/get/delete, stream close, denied, timeout, partial/unknown upload, missing object, unavailable và tenant isolation. |

## OPTIONAL — cân nhắc theo nhu cầu

| ID | Quyết định |
| --- | --- |
| MINIO-O01 | Presigned URL: quyền truy cập trực tiếp, TTL, method, scope và revocation? |
| MINIO-O02 | Multipart/resumable upload: kích thước file có biện minh complexity? |
| MINIO-O03 | Versioning/retention/legal hold: yêu cầu audit/khôi phục? |
| MINIO-O04 | Encryption bổ sung: key ownership/rotation? |
| MINIO-O05 | Event notification/lifecycle: consumer và retention policy đã chốt? |

**Cấu hình cần ghi:** endpoint, TLS, bucket, credential ref, timeout/deadline, SDK retry, max size, key/metadata, overwrite/delete, reconciliation, error map.

**Đối chiếu API theo phiên bản:** [MinIO Java Client](https://minio-java.min.io/io/minio/MinioClient.html).
