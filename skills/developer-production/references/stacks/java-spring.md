# Adapter Java/Spring

**Khi áp dụng:** repository dùng Java/Spring. Đọc quy tắc chung và integration đang dùng trước file này.

## CRITICAL

| ID | Cách áp dụng |
| --- | --- |
| JAVA-001 | `RUN-001`: bind endpoint, credential reference, timeout/deadline, pool, topic/bucket/key namespace vào `@ConfigurationProperties` + `@Validated`; dùng `Duration`/`DataSize` cho đơn vị. Chỉ những property có trigger mới bắt buộc ở startup; config theo profile/environment và không hard-code secret. |
| JAVA-002 | `RUN-002`/`RUN-003`: `server.shutdown=graceful` + `spring.lifecycle.timeout-per-shutdown-phase`; client/bean/listener/stream có lifecycle (`SmartLifecycle`/`@PreDestroy`); Actuator liveness/readiness group, không đưa DB vào liveness. Test property binding, negative path và resource close. |
| JAVA-003 | `@Transactional` chỉ bao resource do transaction manager quản lý; xác nhận commit/rollback và side effect order. |
| JAVA-004 | Nếu dùng Spring Kafka, kiểm tra deserialization error xảy ra trước listener và error handler/DLT disposition phù hợp version. |
| JAVA-005 | `EXC-001`–`EXC-005`: mỗi client có package riêng gồm DTO request/response/error (record), mapper thuần (tay viết hoặc MapStruct với `unmappedTargetPolicy = ERROR`), enum bảng map lỗi. `RestClient`: `defaultStatusHandler`/`onStatus` riêng từng client, đọc error body an toàn (giới hạn size, bắt lỗi parse) rồi kiểm tra cả body của response 2xx; `WebClient`: `onStatus` + `ExchangeFilterFunction`. Bọc `ResourceAccessException`/`WebClientRequestException`/`SocketTimeoutException` thành exception typed của client, giữ `cause`. `@RestControllerAdvice` map exception typed theo internal code, lấy custom message qua `MessageSource`; field message gốc chỉ vào log/MDC. |

## OPTIONAL — cân nhắc theo nhu cầu

| ID | Quyết định |
| --- | --- |
| JAVA-O01 | Thêm Spring Integration cho SFTP hoặc integration framework mới: dependency và vận hành có cần? |
| JAVA-O02 | Tạo auto-configuration/shared starter: có nhiều consumer và owner/version rõ? |

## Ánh xạ theo trigger

| Trigger | Điểm cấu hình/test |
| --- | --- |
| HTTP | Spring MVC/WebFlux và `RestClient`/`WebClient` theo repo; cấu hình underlying transport timeout/pool, map status và I/O error tại adapter. |
| Security/Keycloak | Spring Security OAuth2 resource server/client theo flow; issuer/JWK/audience, role converter, resource authorization; Admin API là external adapter riêng. |
| Redis | Spring Data Redis/Lettuce theo repo; command/connect/pool timeout, key prefix, TTL, serializer và invalidation sau commit. |
| MinIO | MinIO Java SDK/S3 client theo repo; connect/write/read timeout, retry SDK, stream close và error map. |
| SFTP | SSH/Spring Integration client theo repo; known hosts, session timeout, stream, temp/rename và error channel. |
| Kafka | Spring Kafka producer/consumer; delivery/request timeout, listener ack/commit, error deserializer, error handler, DLT. |
| Test | JUnit và test framework sẵn có; container/real dependency khi mock che lỗi transaction, schema, config hoặc serialization. |

Ghi tên property thực tế, đơn vị, giá trị đã chốt, owner và test trong [phiếu rà soát](../workflow/feature-review.md). Không dùng một file cấu hình cố định cho mọi Spring version.
Đổi MVC/WebFlux hoặc virtual threads thuộc `DAL-O02`; không tạo optional trùng ở adapter này.
