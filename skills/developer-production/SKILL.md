---
name: developer-production
description: Triển khai code production trong repo hiện có đúng theo plan/task đã chốt (API, DB, bảo mật, tích hợp Kafka/Redis/SFTP/MinIO/Keycloak, rate limit). Chọn rule kỹ thuật theo trigger của thay đổi và kiểm chứng bằng lệnh thực chạy. Dùng khi implement hoặc sửa code theo plan; không dùng để lập plan, review thuần hoặc viết tài liệu.
---

# Phát triển production theo plan

Plan/task là nguồn phạm vi duy nhất. Skill này chỉ quy định cách làm đúng và gọn trong phạm vi đó.

## Nguyên tắc

1. **Theo plan 100%.** Plan/task do người dùng đưa là hợp đồng: làm đủ và đúng, không bớt, không thêm. Mỗi thay đổi truy được về một bước, acceptance criteria hoặc file của task. Không tự thêm endpoint, field, config, bảng, cache, retry, log, test hay class mà plan không yêu cầu. Thấy việc đáng làm ngoài plan → ghi vào report, không code.
2. **Không bao giờ tự tạo hay sửa plan.** Cấm tạo `docs/IMPLEMENTATION_PLAN.md`, flow hay `docs/TASKS.md`; chỉ được tick step và ghi dòng `Kiểm chứng` của task đang làm. Plan thiếu, mâu thuẫn hoặc lệch thực tế → dừng phần phụ thuộc, báo trong report (hoặc hỏi nếu là agent chính) theo [decision-gate](references/governance/decision-gate.md). Không tự bù.
3. **Rule theo trigger, không theo catalog.** Chỉ đọc reference có trigger trong thay đổi (qua [routing](references/routing.md)). Rule `CRITICAL` ràng buộc cách làm phần việc đã có trong plan; nó không phải lý do thêm tính năng. `OPTIONAL` không làm trừ khi plan yêu cầu.
4. **Đơn giản nhất chạy đúng.** Dùng util, module, pattern sẵn có của repo trước khi viết mới. Chỉ trừu tượng hóa khi plan có ít nhất hai biến thể thật.
5. **Ít class, ít file.** Ưu tiên hàm trong module hiện có. Chỉ tạo class/interface/file mới khi plan liệt kê nó, hoặc nó có từ hai nơi dùng/hai implementation thật. Không tạo wrapper, factory, manager, helper, DTO trung gian, interface một implementation.
6. **Code sạch, tên nói rõ ý định.** Hàm ngắn, một việc, ít tham số; không nesting sâu, không magic number/string, không lặp logic, không nuốt lỗi. Comment chỉ giải thích "tại sao".
7. **Refactor trong phạm vi.** Sau khi test pass, dọn code do chính mình viết/sửa trong file của task (trùng lặp, tên, nesting, phần thừa), giữ nguyên hành vi, rồi chạy lại test. Không refactor code task không chạm tới.
8. **Sửa phẫu thuật.** Chỉ chạm file trong task; không đổi tên, format, cấu trúc code không liên quan.
9. **Không báo pass khi chưa chạy.** Lệnh formatter/lint/build/test lấy từ repo, không bịa.

## Quy trình

1. Đọc task, các flow nó tham chiếu và code liên quan. Xác định acceptance criteria, contract công khai và failure path. Không có plan/task cho thay đổi này → dừng và báo thiếu.
2. Chọn reference theo nguyên tắc 3. Kiểm tra API/config theo version dependency đang pin; nếu repo đã có cách tương đương, dùng cách đó.
3. Viết test cho acceptance criteria, implement, chạy test.
4. Refactor theo nguyên tắc 7, rồi rà diff theo [CQ-001](references/controls/code-quality.md):
   - Mỗi hunk truy được về plan; xóa hunk không truy được.
   - Class/interface/hàm mới chỉ có một nơi dùng và plan không liệt kê → inline vào nơi dùng.
   - Chạy lại kiểm tra.
5. Báo cáo: lệnh đã chạy kèm kết quả, `CHƯA CHẠY` kèm lý do, giả định đã dùng, việc ngoài plan phát hiện được.

Subagent không hỏi người dùng và không dispatch reviewer: câu hỏi, blocker và danh sách file logic đã đổi đi vào report. Điều phối và review thuộc `CLAUDE.md`.

## Tài liệu

- [Routing](references/routing.md): trigger → reference cần đọc.
- [Feature review](references/workflow/feature-review.md): checklist cho tích hợp hoặc nhiều boundary; chỉ ghi mục có trigger.
- [Xử lý khi lệch plan](references/workflow/plan-execution.md): phân loại mức độ lệch để báo trong report, không dùng để sửa plan.
- [Quy ước mở rộng catalog](references/governance/skill-extension-assumptions.md): chỉ đọc khi sửa chính skill này.
