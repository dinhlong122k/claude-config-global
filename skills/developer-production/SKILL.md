---
name: developer-production
description: Triển khai hoặc sửa feature production trong codebase hiện có, nhất là API, dữ liệu, bảo mật và tích hợp. Dùng khi cần chọn các kiểm soát kỹ thuật theo rủi ro và kiểm chứng thay đổi; không dùng cho review thuần túy hoặc tác vụ tài liệu đơn giản.
---

# Phát triển feature production

Đọc code, test, cấu hình và convention liên quan trước khi thiết kế. Xác định hành vi cần đạt, contract công khai, dữ liệu và failure path. Giữ phạm vi theo yêu cầu; ưu tiên cấu trúc và công cụ đã có trong repository.

Hook `PreToolUse`/`PostToolUse`/`Stop` của skill này được khai báo **duy nhất** ở `.claude/settings.json` (project-level) — không lặp lại trong frontmatter ở đây, để tránh chạy trùng hai lần trên mỗi tool call. Sửa lệnh hook hoặc path script tại `settings.json`.

## Cách dùng

1. Trước khi sửa logic, đọc `docs/IMPLEMENTATION_PLAN.md` ở gốc dự án. Nếu chưa có, tạo file này từ mục tiêu và flow đã thống nhất. Chỉ triển khai các bước nằm trong plan; khi flow thực tế cần đổi, cập nhật plan trước khi tiếp tục sửa code. Sau một nhóm thay đổi logic và trước khi kết thúc, giao `plan-reviewer` đối chiếu plan với code; agent chính cập nhật plan theo bằng chứng, không thêm bước ngoài phạm vi chỉ để hoàn thiện plan. Ngay sau khi Plan Mode kết thúc, hoặc khi plan cần cập nhật giữa quá trình code, dùng [plan-execution](references/workflow/plan-execution.md) cùng agent `task-planner` và `task-executor`.
2. Áp dụng [decision-gate](references/governance/decision-gate.md): tự giải quyết lựa chọn triển khai thường ngày từ code và yêu cầu; hỏi khi thiếu một quyết định nghiệp vụ hoặc rủi ro cao mà không thể suy ra an toàn. Tiếp tục phần độc lập trong khi chờ.
3. Dùng [routing](references/routing.md) để đọc đúng reference cho thay đổi thực tế. Các mục `CRITICAL` chỉ áp dụng khi trigger của chúng có mặt. `OPTIONAL` là phương án cân nhắc, không phải danh sách việc phải làm hay cổng xin phép mặc định.
4. Triển khai thay đổi nhỏ nhất đáp ứng contract. Với tích hợp hoặc nhiều boundary, dùng [feature-review](references/workflow/feature-review.md) như checklist làm việc; chỉ ghi những quyết định, cấu hình và bằng chứng thực sự liên quan.
5. Sau mỗi thay đổi logic, giao `security-reviewer` kiểm tra code đã đổi và luồng dữ liệu liên quan. Agent chính tổng hợp phát hiện theo HIGH → MEDIUM → LOW, nêu bằng chứng và đề xuất rồi hỏi người dùng trước khi sửa lỗi bảo mật. Chạy kiểm tra phù hợp với rủi ro và convention repo. Khi sửa code, áp dụng [CQ-001](references/controls/code-quality.md) và rà soát cuối cùng trên các file đã đổi: kiểm tra định dạng, loại bỏ phần thừa, refactor trong phạm vi được phép, rồi kiểm tra lại. Trước khi kết thúc, cập nhật `docs/IMPLEMENTATION_PLAN.md` theo flow đã triển khai và đánh dấu rõ phần chưa làm. Báo lệnh đã chạy, kết quả và phần chưa kiểm chứng; không nhận đã test khi chưa chạy. Nếu không dùng được custom agent hoặc model đã chọn, agent chính tự thực hiện lượt rà soát tương ứng và báo rõ điều đó.

## Tài liệu theo nhu cầu

- [Plan → task và đồng bộ khi đổi](references/workflow/plan-execution.md): dùng ngay sau Plan Mode để chốt plan/tasks, và mỗi khi plan cần cập nhật giữa quá trình code.
- [Quy ước mở rộng catalog](references/governance/skill-extension-assumptions.md): dùng khi thêm hoặc tổ chức lại skill, module, integration hay adapter.
- [Architecture](references/architecture/README.md): module, dependency và external boundary khi thay đổi cấu trúc hoặc tích hợp.
- [Controls](references/controls/README.md): lỗi, timeout, bảo mật, dữ liệu, observability, test và code quality theo trigger.
- [Integrations](references/integrations/README.md): SFTP, MinIO, Keycloak, Redis cache, rate limit và Kafka khi feature thực sự dùng chúng.
- [Stack adapters](references/stacks/README.md): chỉ đọc adapter của stack đang dùng.

Một rule có một owner; nơi khác chỉ tham chiếu ID. Kiểm tra API/config thực tế theo phiên bản dependency đang dùng. Nếu convention repo có cách tương đương và đã được kiểm chứng, dùng cách đó. Không mở rộng kiến trúc hoặc hạ tầng ngoài yêu cầu chỉ để thỏa một ví dụ trong catalog.
