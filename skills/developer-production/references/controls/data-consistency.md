# Tính nhất quán dữ liệu

## DATA-001 — Store có thẩm quyền

**CRITICAL khi DB write, cache, object storage hoặc event phối hợp.** Chốt authoritative store, transaction boundary, DB constraint, isolation/concurrency và recovery. Redis/MinIO/Kafka không mặc nhiên thuộc DB transaction.

## DATA-002 — Side effect qua commit

**CRITICAL khi một write kéo theo cache invalidation, file upload hoặc event publish.** Chọn pattern có failure window rõ: post-commit action, outbox, saga/compensation hoặc reconciliation idempotent. Test rollback, duplicate và retry. Migration phải có tương thích triển khai và rollback/forward fix.

## DATA-O01 — Transactional outbox

**OPTIONAL về công nghệ.** Chọn outbox khi cần đảm bảo chuyển trạng thái DB thành event bền vững và chi phí bảng/worker/retry phù hợp. Nghĩa vụ consistency của `DATA-002` vẫn critical; nếu chưa xác định được guarantee nghiệp vụ, áp dụng `GOV-DEC-001`.

## DATA-O02 — Distributed lock

**OPTIONAL.** Cân nhắc; chỉ dùng khi DB constraint/optimistic locking/idempotency không đủ.

**Bằng chứng:** test constraint/transaction/migration và mô tả khoảng rủi ro lỗi.
