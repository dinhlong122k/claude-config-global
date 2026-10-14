# Execution Contract — Planner ↔ Developer

## 1. Mục đích

Contract này quy định cách Planner bàn giao kế hoạch và cách Developer thực hiện kế hoạch trong `IMPLEMENTATION_PLAN.md`.

Kế hoạch phải đủ rõ để Developer triển khai và kiểm chứng mà không phụ thuộc vào trí nhớ của cuộc trò chuyện trước.

Các nhãn được hiểu như sau:

- **CRITICAL:** bắt buộc tuân thủ trong phạm vi công việc.
- **OPTIONAL:** áp dụng khi giúp thực hiện công việc tốt hơn; không tự mở rộng scope.

## 2. Trách nhiệm của Planner — CRITICAL

Planner chịu trách nhiệm xác định:

1. Vấn đề cần giải quyết và kết quả mong đợi.
2. Scope, non-goals và hành vi hiện có phải bảo toàn.
3. Context của repository và baseline dùng để lập plan.
4. Requirements có ID và acceptance criteria có thể kiểm chứng.
5. Thiết kế đích, contracts, invariants và quyết định đã chốt.
6. Tasks, dependencies và kết quả mong đợi của từng milestone.
7. Verification cần thực hiện và điều kiện nghiệm thu.
8. Ass