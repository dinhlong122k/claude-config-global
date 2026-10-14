# Giả định và quy ước mở rộng catalog

Tài liệu này là hợp đồng bảo toàn cấu trúc khi thêm hoặc sửa skill, rule, stack adapter, integration hay workflow trong `developer-production`. Đọc trước khi thiết kế phần mở rộng; nó không thay thế [cổng quyết định](decision-gate.md) khi xây dựng feature.

## Mục tiêu bất biến

Catalog tăng theo chiều sâu, không tăng bằng bản sao. Một feature đi từ entrypoint đến đúng rule owner, rồi chỉ đọc adapter hoặc integration cần thiết. Cùng một chính sách không được có hai nơi định nghĩa; mọi thay đổi phải giữ được link, trigger và bằng chứng có thể truy vết.

## GOV-CAT-001 — Giữ một entrypoint và disclosure tuần tự

**CRITICAL — khi thêm hoặc sửa catalog.** Chỉ `SKILL.md` là entrypoint của skill. Nội dung chung, ngắn và điều hướng đặt ở entrypoint; nội dung chỉ cần trong ngữ cảnh cụ thể đặt tại `references/`. Không tạo `SKILL.md` lồng nhau, một skill song song, README tổng hợp lặp lại hoặc tài liệu không có đường dẫn đến từ entrypoint/router.

## GOV-CAT-002 — Chọn đúng loại phần mở rộng

**CRITICAL — trước khi tạo file hoặc rule.** Phân loại nhu cầu trước khi đặt file:

| Nhu cầu | Vị trí owner | Không được sở hữu |
| --- | --- | --- |
| Quyết định, phê duyệt optional, ngoại lệ, evidence | `references/governance/` | Semantics công nghệ cụ thể |
| Module, dependency direction, public boundary, external folder | `references/architecture/` | Timeout/retry/error policy chi tiết |
| Chính sách đa stack về resilience, error, security, dữ liệu, observability, test, code quality | `references/controls/` | Cấu hình SDK/framework cụ thể |
| Code tham khảo để chứng minh một boundary/version mong manh | `references/` theo capability và stack, chỉ khi có consumer và điều kiện route rõ | Rule/policy chung hoặc production template mặc định |
| Semantics, contract, config, failure/disposition riêng của một service/broker/protocol | `references/integrations/` | Policy chung và folder architecture |
| Cách áp dụng rule vào một ngôn ngữ/framework | `references/stacks/` | Policy chung hoặc kiến trúc mới |
| Trình tự thực hiện/review một loại công việc | `references/workflow/` | Định nghĩa lại rule đã có owner |

Nếu nhu cầu không thuộc đúng một hàng, ghi phương án và chốt qua `GOV-DEC-001` trước khi tạo cấu trúc mới.

## GOV-CAT-003 — Mở rộng trước, tạo mới sau

**CRITICAL — trước khi thêm file.** Tìm rule owner hiện có theo `routing.md` và các README theo nhóm. Nếu cùng responsibility/boundary, mở rộng file owner đó. Chỉ tạo file mới khi responsibility độc lập, có trigger nhận diện được, có consumer hiện tại hoặc sắp có, và việc ghép vào owner cũ làm mờ trách nhiệm. Ghi lý do tạo mới trong quyết định `DEC-...`.

Không tách file chỉ vì file dài; tách theo boundary ổn định. Không tạo folder theo từng vendor nếu các vendor chỉ khác một cấu hình nhỏ của cùng protocol.

## GOV-CAT-004 — Một owner, nhiều tham chiếu

**CRITICAL — khi thêm rule.** Mỗi rule có ID ASCII ổn định và được định nghĩa tại đúng một owner. File khác chỉ nêu ID và link đến owner, không diễn đạt lại yêu cầu bằng lời khác. Đặt rule CRITICAL hoặc OPTIONAL ở owner; integration/adapter chỉ bổ sung phần riêng không trùng với control/architecture. Khi di chuyển rule, đổi owner và toàn bộ link/reference trong cùng thay đổi.

Quy ước ID: `GOV-*` cho governance, `ARC-*` architecture, nhóm controls đang có, prefix integration theo service (`KAFKA-*`, `SFTP-*`...) và prefix adapter theo stack (`JAVA-*`, `TS-*`, `PY-*`, `GO-*`). Không tái sử dụng ID đã xoá cho ý nghĩa khác.

## GOV-CAT-005 — CRITICAL và OPTIONAL có ý nghĩa thực thi

**CRITICAL — cho mọi module mới hoặc sửa.** Một module được kích hoạt phải có phần `CRITICAL` và `OPTIONAL` rõ ràng. CRITICAL áp dụng khi trigger đúng; OPTIONAL là khả năng tạo thêm phạm vi, dependency, chi phí, rủi ro hoặc vận hành và chỉ được triển khai khi người dùng đồng ý rõ theo `GOV-OPT-001`. Không gán mặc định một optional vào feature, cũng không hạ yêu cầu an toàn bắt buộc thành optional để tránh hỏi.

## GOV-CAT-006 — Liên kết và điều hướng là một phần của thay đổi

**CRITICAL — khi thêm, xoá hoặc di chuyển tài liệu.** Mỗi tài liệu reference phải được điều hướng từ `SKILL.md`, `routing.md` hoặc README của nhóm với điều kiện đọc rõ. Router chỉ quyết định nơi cần đọc, không làm owner của rule. Cập nhật link ngược khi thay đổi phân nhóm. Không để link ra ngoài package hoặc link hỏng.

## GOV-CAT-007 — Boundary cho tích hợp và external code

**CRITICAL — khi thêm integration.** Integration mới phải kích hoạt architecture external boundary và có adapter code nằm trong `external/` hoặc `infrastructure/external/` theo convention repository. Tài liệu integration phải nêu trigger, contract/config, timeout/deadline, failure mapping/disposition, observability, security và test evidence bằng cách tham chiếu controls owner khi đó là chính sách chung. Không để vendor SDK đi xuyên vào domain/application.

## GOV-CAT-008 — Adapter chỉ ánh xạ, không áp đặt

**CRITICAL — khi thêm stack/framework adapter.** Adapter mới dùng rule ID của governance/architecture/controls/integration và chỉ chỉ ra idiom, library boundary hoặc property cần kiểm tra theo version. Adapter không được yêu cầu đổi framework, SDK, architecture hay tạo policy thứ hai. Nếu một framework cần policy riêng thật sự, owner vẫn nằm ở control/architecture và adapter link đến đó.

## GOV-CAT-009 — Thay đổi catalog theo gói nguyên tử

**CRITICAL — khi sửa catalog.** Một thay đổi mở rộng hoàn chỉnh gồm: owner content, phân loại CRITICAL/OPTIONAL, routing/README cần thiết, link, rule ID và validation. Không commit trạng thái một nửa như thêm integration nhưng chưa có route, hay thêm adapter không chỉ ra owner. Giữ thay đổi theo một boundary; không refactor hàng loạt tài liệu không liên quan.

## GOV-CAT-010 — Code reference là bằng chứng có điều kiện, không phải policy

**CRITICAL — khi thêm, sửa hoặc route tới code ví dụ/reference implementation.** Rule mô tả điều phải đúng; adapter chỉ ánh xạ rule sang idiom/version; code production được xây từ codebase hiện hành. Chỉ tạo code reference khi có một rủi ro không thể làm rõ bằng contract: API SDK dễ sai theo version, semantics protocol/failure path phức tạp, hoặc cần chứng minh interoperability.

Không tạo snippet cho cú pháp thông thường, không dùng ví dụ để ép framework/SDK, và không sao chép timeout, retry, TTL, quota, credential, endpoint hay delivery guarantee vào feature. Trước khi route, áp dụng `GOV-DEC-001` để chốt vấn đề, capability/stack/version, owner và lý do không dùng pattern đã kiểm chứng của repository.

## GOV-CAT-011 — Chuẩn sống còn của reference implementation

**CRITICAL — khi reference implementation được giữ trong catalog.** Reference tách khỏi file rule owner, có phạm vi nhỏ và nhãn rõ *không phải production default*. Nó phải ghi dependency/version hoặc cách resolve version, prerequisite, lệnh kiểm tra, expected outcome, ít nhất một failure path, owner, thời điểm đã kiểm chứng và tiêu chí xóa/thay thế.

Không chứa secret, endpoint/dữ liệu production hoặc giá trị cấu hình bị hiểu nhầm là mặc định. Reference không chạy được chỉ được giữ dưới dạng sơ đồ/pseudocode có nhãn rõ, không giả là sample production-ready. Khi SDK/version thay đổi, ưu tiên docs chính thức và test lại thay vì sửa snippet bằng suy đoán.

## GOV-CAT-012 — Đầu tư fixture/reference dùng chung là optional

**OPTIONAL — khi đề xuất container fixture, integration harness hoặc template/package dùng chung.** Hỏi người dùng trước vì các lựa chọn này tăng dependency, thời gian CI và chi phí duy trì. Chỉ thêm khi mock không chứng minh được boundary cần thiết hoặc đã có consumer, versioning, compatibility, owner và lifecycle rõ. Fixture phải độc lập, dọn dữ liệu và không ảnh hưởng môi trường bên ngoài.

## Trình tự thêm một năng lực mới

1. Kiểm kê catalog và feature use case sẽ dùng năng lực đó.
2. Áp dụng `GOV-DEC-001` cho bất định về boundary, scope, contract hoặc reference.
3. Phân loại theo `GOV-CAT-002`; quyết định extend hay create theo `GOV-CAT-003`.
4. Viết owner trước; thêm CRITICAL/OPTIONAL và các link đến owner liên quan.
5. Nếu có reference implementation, áp dụng `GOV-CAT-010` đến `GOV-CAT-012`; xác định nó là evidence có điều kiện, không phải default.
6. Cập nhật router/README có điều kiện đọc cụ thể; cập nhật `SKILL.md` chỉ khi khả năng mới cần được discover ở entrypoint.
7. Rà unique ID, owner, link, trigger và chạy validator. Ghi evidence hoặc giới hạn chưa kiểm chứng.

## Checklist chấp nhận

- [ ] Boundary của năng lực mới đã được chốt và có `DEC-...` nếu trước đó chưa rõ.
- [ ] Có đúng một owner cho từng rule mới; không trùng policy với tài liệu cũ.
- [ ] CRITICAL và OPTIONAL đã được tách; optional không được bật ngầm định.
- [ ] Khi là integration: có external boundary, contract/config, timeout, error/disposition, security, observability và test routing.
- [ ] Khi là adapter: chỉ ánh xạ vào rule owner, không thêm architecture/policy trùng.
- [ ] Code reference (nếu có) có lý do kỹ thuật đã chốt, version/prerequisite, test + failure path, owner và lifecycle; không chứa production default hoặc secret.
- [ ] Fixture/harness/template dùng chung đã có chấp thuận rõ ràng khi nó tăng dependency hay chi phí CI.
- [ ] Tài liệu mới được điều hướng theo ngữ cảnh và không tạo nhánh skill độc lập.
- [ ] Validator pass; các thay đổi chưa thể kiểm tra đã được ghi rõ.

## Anti-pattern cần từ chối

| Dấu hiệu | Cách sửa |
| --- | --- |
| Thêm một `SKILL.md` cho mỗi stack hoặc integration | Giữ một entrypoint; thêm reference/adapter/integration dưới package. |
| Copy timeout, retry, error handling vào mọi integration | Owner là controls; integration chỉ link và nêu semantics đặc thù. |
| Stack adapter ép dự án dùng framework/SDK mới | Chỉ hướng dẫn idiom cho stack đã có; nêu lựa chọn để chốt nếu cần đổi dependency. |
| Tạo optional nhưng tự bật vì “best practice” | Hỏi và chờ đồng ý rõ theo `GOV-OPT-001`. |
| Thêm vendor mà chưa biết protocol/boundary | Brainstorm, chốt `DEC-...`, sau đó mới chọn reference và folder. |
| Đặt snippet SDK vào rule và để agent copy số timeout/retry/TTL | Giữ rule là contract; chỉ tạo reference có version/test khi nó chứng minh được rủi ro kỹ thuật cụ thể. |
| Gọi fixture/template dùng chung là “best practice” rồi tự thêm | Xem là OPTIONAL; chốt consumer, owner, lifecycle và sự đồng ý trước. |
