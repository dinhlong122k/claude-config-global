# Tính nhất quán dữ liệu

## DATA-001 — Store có thẩm quyền

**CRITICAL khi DB write, cache, object storage hoặc event phối hợp.** Chốt authoritative store, transaction boundary, DB constraint, isolation/concurrency và recovery. Redis/MinIO/Kafka không mặc nhiên thuộc DB transaction.

## DATA-002 — Side effect qua commit

**CRITICAL khi một write kéo theo cache invalidation, file upload hoặc event publish.** Chọn pattern có failure window rõ: post-commit action, outbox, saga/compensation hoặc reconciliation idempotent. Test rollback, duplicate và retry. Migration và tương thích khi triển khai thuộc `DLV-001`.

## DATA-003 — Consumer idempotent

**CRITICAL khi xử lý message, callback, job hoặc request có thể đến lặp.** Coi mọi delivery là at-least-once. Dedupe bằng khóa nghiệp vụ hoặc message ID có unique constraint, lưu cùng transaction với thay đổi; hoặc thiết kế thao tác tự idempotent (set trạng thái, upsert theo khóa). Message đến sai thứ tự được xử lý theo state machine/version, không ghi đè trạng thái mới bằng trạng thái cũ.

## DATA-004 — Reconciliation cho trạng thái phân tán

**CRITICAL khi kết quả phụ thuộc hệ thống ngoài mà có thể rơi vào trạng thái không rõ (`ERR-001` unknown outcome).** Lưu trạng thái trung gian (pending) với tham chiếu bên ngoài; có cơ chế đối soát (job tra trạng thái hoặc so sánh định kỳ) đưa bản ghi pending quá hạn về trạng thái cuối, và phát hiện được bản ghi kẹt.

## DATA-O01 — Transactional outbox

**OPTIONAL về công nghệ.** Chọn outbox khi cần đảm bảo chuyển trạng thái DB thành event bền vững và chi phí bảng/worker/retry phù hợp. Nghĩa vụ consistency của `DATA-002` vẫn critical; nếu chưa xác định được guarantee nghiệp vụ, áp dụng `GOV-DEC-001`.

## DATA-O02 — Distributed lock

**OPTIONAL.** Cân nhắc; chỉ dùng khi DB constraint/optimistic locking/idempotency không đủ.

## DATA-O03 — Event sourcing/CQRS

**OPTIONAL.** Cân nhắc khi cần lịch sử đầy đủ hoặc read model riêng; tăng đáng kể độ phức tạp, áp dụng `GOV-DEC-001`.

## DATA-O04 — Sổ cái kép

**OPTIONAL — financial domain theo `GOV-OPT-002`, khi feature ghi nhận biến động số dư.** Mỗi giao dịch sinh bút toán kép cân bằng (tổng debit = tổng credit) trong một transaction; ledger append-only, sửa sai bằng bút toán đảo; số dư tính từ ledger hoặc snapshot đối chiếu được với ledger; chặn số dư âm bằng constraint/lock theo `DAL-003`; đối soát định kỳ với partner theo `DATA-004`.

**Bằng chứng:** test constraint/transaction, duplicate/out-of-order message, bản ghi pending được đối soát và mô tả khoảng rủi ro lỗi.
