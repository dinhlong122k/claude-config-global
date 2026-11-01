# Kafka

**Khi áp dụng:** publish hoặc consume Kafka. Nếu kết hợp DB write, đọc [tính nhất quán dữ liệu](../controls/data-consistency.md).

## CRITICAL

| ID | Bắt buộc |
| --- | --- |
| KAFKA-001 | Chốt topic owner, producer/consumer, schema/version, key/partitioning, ordering, retention, ACL và security protocol. |
| KAFKA-002 | Khi produce: request/delivery/metadata/block timeout và caller deadline; acks, idempotence, retry/backoff, max-in-flight theo guarantee đã chốt. Xử lý publish success/failure/unknown result. Unknown result (delivery timeout) coi là có thể đã ghi: retry giữ nguyên event ID, consumer dedupe. |
| KAFKA-003 | Khi consume: group ID, offset reset, poll/session/max-poll, concurrency và commit/ack strategy. Commit sau side effect hoặc disposition đã hoàn tất; xét crash/rebalance/duplicate/order. Concurrency hiệu dụng ≤ số partition. |
| KAFKA-004 | Phân biệt deserialize/schema error với transient processing. Mỗi invalid/poison message có bounded retry hoặc disposition được chốt (quarantine/DLT/stop), owner xử lý và đường replay/repair. Không skip/commit im lặng. |
| KAFKA-005 | Consumer side effect idempotent/deduplicate. DB write + event publish cần consistency pattern; producer idempotence không tạo DB/Kafka atomicity. |
| KAFKA-006 | Error taxonomy cho broker unavailable, timeout, auth, serialization, invalid schema, record too large, poison message, business reject; phân biệt retriable với non-retriable. Ghi topic/partition/offset/key đã redaction, correlation ID, lag/error/DLT metrics. |
| KAFKA-007 | Test với broker thật (container) cho produce/consume, schema error, broker unavailable, duplicate, retry exhausted, disposition, crash/commit window, rebalance giữa lúc xử lý, graceful shutdown, ordering khi liên quan và DB rollback nếu có. |
| KAFKA-008 | Topic durability: replication factor, `min.insync.replicas`, unclean leader election, cleanup policy, max message size và partition count chốt trước go-live, khớp với `acks`. Tăng partition làm đổi key → partition, phá ordering theo key: coi là thay đổi có kế hoạch. Không dựa vào auto-create topic ở production. |
| KAFKA-009 | Retention topic và retention offset của group phải dài hơn thời gian consumer có thể dừng tối đa cộng cửa sổ replay. Offset hết hạn/out-of-range kích hoạt `auto.offset.reset`: chốt giá trị có chủ đích và alert, không để mặc định `latest` âm thầm bỏ dữ liệu. |
| KAFKA-010 | Bảo mật: TLS + SASL/mTLS, không PLAINTEXT ngoài local; credential qua secret ref có rotate; ACL tối thiểu theo principal (producer: Write/Describe topic; consumer: Read topic + Read group; transactional: Write TransactionalId). DLT/quarantine chứa payload gốc nên ACL, retention và che PII ngang hoặc chặt hơn topic gốc. |
| KAFKA-011 | Message contract: event ID duy nhất (dùng để dedupe), event type, schema version, correlation/trace ID, thời điểm phát sinh trong header hoặc envelope. Chốt compatibility mode và thứ tự deploy producer/consumer; breaking change dùng topic/version mới, không đổi tại chỗ. |
| KAFKA-012 | Lifecycle: graceful shutdown có timeout — producer flush/close; consumer ngừng poll, xong in-flight, commit, close để rời group. Khi partition bị thu hồi lúc rebalance, commit phần đã xong hoặc bỏ phần dở; không commit offset vượt record chưa xử lý xong (nhất là khi xử lý async ngoài poll thread). |
| KAFKA-013 | Ordering khi retry: ordering theo key cần key ổn định, idempotence và max-in-flight ≤ 5. Blocking retry giữ thứ tự nhưng chặn partition; non-blocking retry/DLT phá thứ tự. Chốt chọn bên nào cho từng topic. |
| KAFKA-014 | Alert có ngưỡng và owner: consumer lag (record và thời gian) theo partition, tần suất rebalance, vượt max-poll-interval, producer error/retry rate, DLT rate, consumer dừng hẳn. Readiness/health phản ánh mất kết nối broker hoặc consumer ngừng chạy. |

### Cấu hình baseline — CRITICAL

Đặt **tường minh** dù trùng default: default đổi theo phiên bản và framework có thể ghi đè. Đặt tường minh `enable.idempotence=true` khiến cấu hình xung đột báo lỗi khi khởi động thay vì âm thầm tắt idempotence.

**Producer**

| Config | Giá trị production | Lý do |
| --- | --- | --- |
| `acks` | `all` | Không mất record khi leader chết; cần đi cùng `min.insync.replicas`. |
| `enable.idempotence` | `true` | Không duplicate/đảo thứ tự do retry trong một partition. |
| `max.in.flight.requests.per.connection` | ≤ 5 | Lớn hơn làm mất bảo đảm idempotence/ordering. |
| `retries` | để default (rất lớn) | Giới hạn retry bằng `delivery.timeout.ms`, không bằng số lần. |
| `delivery.timeout.ms` | theo SLA, ≥ `linger.ms` + `request.timeout.ms` | Tổng thời gian tối đa một record chờ ack; hết thì là unknown result. |
| `request.timeout.ms` | chốt theo latency broker | Timeout mỗi request. |
| `max.block.ms` | < caller deadline | `send()` có thể block khi chờ metadata hoặc buffer đầy. |
| `max.request.size` | ≤ `max.message.bytes` của topic | Vượt là lỗi non-retriable (record too large). |
| `client.id` | tên service + instance | Truy vết metrics, quota và log broker. |

**Consumer**

| Config | Giá trị production | Lý do |
| --- | --- | --- |
| `group.id` | cố định theo service + mục đích | Đổi group ID là đọc lại hoặc bỏ dữ liệu theo offset reset. |
| `enable.auto.commit` | `false` khi commit sau side effect | Auto commit có thể commit trước khi xử lý xong. Framework quản lý commit (vd. Spring container) thì theo ack mode của framework. |
| `auto.offset.reset` | chốt `earliest` / `none` / `latest` có chủ đích | Default `latest` bỏ dữ liệu khi group mới hoặc offset hết hạn. |
| `max.poll.records` | theo thời gian xử lý | Batch nhỏ giảm rủi ro vượt poll interval. |
| `max.poll.interval.ms` | > `max.poll.records` × p99 thời gian xử lý, có margin | Vượt là bị đá khỏi group → rebalance → duplicate. |
| `session.timeout.ms`, `heartbeat.interval.ms` | heartbeat ≤ 1/3 session | Classic group protocol. Với `group.protocol=consumer` (Kafka 4.x) hai giá trị này do broker quản lý. |
| `isolation.level` | `read_committed` khi producer dùng transaction | Default `read_uncommitted` đọc cả record của transaction bị abort. |
| key/value deserializer | bọc lớp bắt lỗi deserialize | Lỗi deserialize không làm consumer lặp vô hạn trên cùng offset (KAFKA-004). |

**Topic / broker**

| Config | Giá trị production | Lý do |
| --- | --- | --- |
| `replication.factor` | ≥ 3 | Chịu được mất một broker mà vẫn ghi được. |
| `min.insync.replicas` | 2 (với RF = 3) | Cùng `acks=all` mới có ý nghĩa durability. |
| `unclean.leader.election.enable` | `false` | Bật có thể mất record đã ack. |
| `cleanup.policy` | `delete` hoặc `compact` theo ngữ nghĩa | Compact chỉ giữ bản mới nhất mỗi key; cần tombstone khi xoá. |
| `retention.ms` / `retention.bytes` | theo KAFKA-009 | Ngắn hơn thời gian sự cố là mất dữ liệu chưa đọc. |
| `max.message.bytes` | khớp producer | Xem `max.request.size`. |
| `auto.create.topics.enable` (broker) | `false` | Topic sai partition/RF do gõ nhầm tên. |
| `offsets.retention.minutes` (broker) | > thời gian group có thể ngừng | Hết hạn thì mất committed offset (KAFKA-009). |

### Message error disposition

| Lỗi | Hành động phải chốt |
| --- | --- |
| Deserialize/schema invalid | Không vào business handler; quarantine/DLT hoặc stop có tín hiệu và owner sửa dữ liệu. |
| Dependency transient trong handler | Bounded retry/backoff; commit sau success hoặc disposition hoàn tất. |
| Business reject/permanent | Không retry vô hạn; chuyển trạng thái lỗi theo contract nghiệp vụ. |
| Publish DLT/quarantine cũng lỗi | Không coi message đã xử lý; bảo vệ offset/ack và phát metric/alert. |
| Side effect xong nhưng commit offset lỗi | Chấp nhận khả năng nhận lại; handler idempotent/deduplicate. |
| Record too large / serialization lỗi khi produce | Non-retriable: không retry; trả lỗi cho caller hoặc đánh dấu outbox lỗi có alert. |
| Auth/authorization lỗi | Không retry vô hạn; fail rõ và alert, thường là lỗi cấu hình/credential. |
| Rebalance giữa lúc xử lý | Partition mới có thể nhận lại record chưa commit; idempotent theo KAFKA-005. |

DLT record giữ payload gốc nguyên vẹn và header: topic/partition/offset gốc, loại lỗi, số lần thử, thời điểm. Thiếu các header này thì không replay hay điều tra được.

## OPTIONAL — cân nhắc theo nhu cầu

| ID | Quyết định |
| --- | --- |
| KAFKA-O01 | Retry topic nhiều tầng: có cần tách retry dài khỏi consumer chính? Chấp nhận mất ordering (KAFKA-013)? |
| KAFKA-O02 | Kafka transactional producer: cần transaction giữa các Kafka record (consume-transform-produce)? Không thay DB outbox. Bật thì consumer phía sau cần `read_committed`. |
| KAFKA-O03 | Schema Registry/Avro/Protobuf: nhiều consumer và schema lifecycle tập trung? |
| KAFKA-O04 | Replay/backfill tool tự động: tần suất xử lý DLT biện minh? |
| KAFKA-O05 | Autoscaling theo lag: throughput và partition count hỗ trợ? Số instance vượt partition thì instance dư ngồi không. |
| KAFKA-O06 | Multi-cluster/multi-region replication: DR/latency/cost? Offset khác nhau giữa cluster: cần cơ chế dịch offset khi failover. |
| KAFKA-O07 | Static membership (`group.instance.id`): rolling deploy gây rebalance quá nhiều? |
| KAFKA-O08 | Consumer group protocol mới (`group.protocol=consumer`, Kafka 4.x): broker và client đều hỗ trợ? Giảm stop-the-world rebalance. |
| KAFKA-O09 | Tuning throughput: `linger.ms`, `batch.size`, `compression.type` (lz4/zstd), `fetch.min.bytes`/`fetch.max.wait.ms`: có số đo throughput/latency biện minh? |
| KAFKA-O10 | Xử lý song song trong một partition (theo key): cần throughput vượt số partition mà vẫn giữ ordering theo key? |
| KAFKA-O11 | Payload lớn: claim-check (lưu object store, gửi reference) thay vì nâng `max.message.bytes`? |
| KAFKA-O12 | Quota theo client/user: cluster dùng chung, cần chặn một service chiếm băng thông? |
| KAFKA-O13 | Rack awareness (`client.rack`, đọc từ follower cùng zone): chi phí cross-AZ đáng kể? |
| KAFKA-O14 | Compacted topic cho state/snapshot: consumer cần dựng lại trạng thái mới nhất theo key? |

### Cấu hình tuning — OPTIONAL

| Config | Khi nào chỉnh |
| --- | --- |
| `linger.ms`, `batch.size` | Tăng throughput, chấp nhận thêm latency. Default `linger.ms` đổi theo phiên bản (Kafka 4.x là 5 ms). |
| `compression.type` | Payload lớn/lặp; đo CPU so với băng thông. |
| `buffer.memory` | Burst lớn làm `send()` block tới `max.block.ms`. |
| `partition.assignment.strategy` | Classic protocol: `CooperativeStickyAssignor` giảm gián đoạn khi rebalance. |
| `fetch.min.bytes`, `fetch.max.wait.ms`, `max.partition.fetch.bytes` | Cân bằng throughput và latency phía consumer. |
| `retry.backoff.ms`, `retry.backoff.max.ms`, `reconnect.backoff.max.ms` | Broker chập chờn; tránh dồn request khi broker phục hồi. |
| `group.instance.id` | Đi cùng KAFKA-O07. |
| `transactional.id`, `transaction.timeout.ms` | Đi cùng KAFKA-O02; transactional ID ổn định theo instance. |

**Cấu hình cần ghi:** bootstrap/security/secret ref, topic (partition, RF, `min.insync.replicas`, retention, cleanup policy, max size)/group, key/schema/compatibility, producer timeout/acks/retry/idempotence, consumer poll/session/commit/offset reset/isolation, disposition/DLT owner, retry budget, shutdown timeout, alert threshold, consistency pattern.

**Đối chiếu theo phiên bản:** [Kafka producer config](https://kafka.apache.org/42/configuration/producer-configs/), [consumer config](https://kafka.apache.org/42/configuration/consumer-configs/), [topic config](https://kafka.apache.org/42/configuration/topic-configs/), [Spring Kafka deserialize/error handling](https://docs.spring.io/spring-kafka/reference/kafka/serdes.html).
