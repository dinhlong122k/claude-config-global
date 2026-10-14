# Kafka

**Khi áp dụng:** publish hoặc consume Kafka. Nếu kết hợp DB write, đọc [tính nhất quán dữ liệu](../controls/data-consistency.md).

## CRITICAL

| ID | Bắt buộc |
| --- | --- |
| KAFKA-001 | Chốt topic owner, producer/consumer, schema/version, key/partitioning, ordering, retention, ACL và security protocol. |
| KAFKA-002 | Khi produce: request/delivery/metadata/block timeout và caller deadline; acks, idempotence, retry/backoff, max-in-flight theo guarantee đã chốt. Xử lý publish success/failure/unknown result. |
| KAFKA-003 | Khi consume: group ID, offset reset, poll/session/max-poll, concurrency và commit/ack strategy. Commit sau side effect hoặc disposition đã hoàn tất; xét crash/rebalance/duplicate/order. |
| KAFKA-004 | Phân biệt deserialize/schema error với transient processing. Mỗi invalid/poison message có bounded retry hoặc disposition được chốt (quarantine/DLT/stop), owner xử lý và đường replay/repair. Không skip/commit im lặng. |
| KAFKA-005 | Consumer side effect idempotent/deduplicate. DB write + event publish cần consistency pattern; producer idempotence không tạo DB/Kafka atomicity. |
| KAFKA-006 | Error taxonomy cho broker unavailable, timeout, auth, serialization, invalid schema, poison message, business reject. Ghi topic/partition/offset/key đã redaction, correlation ID, lag/error/DLT metrics. |
| KAFKA-007 | Test produce/consume, schema error, broker unavailable, duplicate, retry exhausted, disposition, crash/commit window, ordering khi liên quan và DB rollback nếu có. |

### Message error disposition

| Lỗi | Hành động phải chốt |
| --- | --- |
| Deserialize/schema invalid | Không vào business handler; quarantine/DLT hoặc stop có tín hiệu và owner sửa dữ liệu. |
| Dependency transient trong handler | Bounded retry/backoff; commit sau success hoặc disposition hoàn tất. |
| Business reject/permanent | Không retry vô hạn; chuyển trạng thái lỗi theo contract nghiệp vụ. |
| Publish DLT/quarantine cũng lỗi | Không coi message đã xử lý; bảo vệ offset/ack và phát metric/alert. |
| Side effect xong nhưng commit offset lỗi | Chấp nhận khả năng nhận lại; handler idempotent/deduplicate. |

## OPTIONAL — cân nhắc theo nhu cầu

| ID | Quyết định |
| --- | --- |
| KAFKA-O01 | Retry topic nhiều tầng: có cần tách retry dài khỏi consumer chính? |
| KAFKA-O02 | Kafka transactional producer: cần transaction giữa các Kafka record? Không thay DB outbox. |
| KAFKA-O03 | Schema Registry/Avro/Protobuf: nhiều consumer và schema lifecycle tập trung? |
| KAFKA-O04 | Replay/backfill tool tự động: tần suất xử lý DLT biện minh? |
| KAFKA-O05 | Autoscaling theo lag: throughput và partition count hỗ trợ? |
| KAFKA-O06 | Multi-cluster/multi-region replication: DR/latency/cost? |

**Cấu hình cần ghi:** bootstrap/security, topic/group, key/schema, producer timeout/acks/retry/idempotence, consumer poll/session/commit, disposition/DLT owner, retry budget, observability, consistency pattern.

**Đối chiếu theo phiên bản:** [Kafka producer config](https://kafka.apache.org/42/configuration/producer-configs/), [consumer config](https://kafka.apache.org/42/configuration/consumer-configs/), [Spring Kafka deserialize/error handling](https://docs.spring.io/spring-kafka/reference/kafka/serdes.html).
