# Tasks — <Tên feature>

> Plan: [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md)
> Thực thi tuần tự theo thứ tự dưới đây, không nhảy cóc (agent `task-executor`).
> Khi làm một task: chỉ nạp plan index + các flow ghi ở dòng "Flow" của task đó.

## T-01 <Tên task — một deliverable kiểm chứng được>

- **Status:** TODO | IN_PROGRESS | DONE | BLOCKED
- **Rủi ro:** cao (auth / dữ liệu / API–contract công khai → dừng xin xác nhận sau task) | thường
- **Flow / nhánh:** F-01.S1–S3, F-01.B1
- **Requirements:** REQ-001
- **Phụ thuộc:** — | T-xx
- **File được sửa:** `<path>` (ngoài danh sách này phải hỏi lại)
- **Test viết trước (TDD):**
  - `F01_B1_<…>`
- **Done khi:** <hành vi quan sát được>; `<lệnh verify>` pass
- **Bằng chứng:** <lệnh đã chạy + kết quả thực tế; hoặc "CHƯA CHẠY: <lý do>">

<!-- Lặp lại khối trên cho mỗi task. Task đủ nhỏ để review riêng; không gộp thay đổi không liên quan. -->

## Ma trận truy vết

Mỗi REQ, mỗi nhánh `B`, mỗi invariant `I` phải xuất hiện ít nhất một lần. Ô trống = lỗ hổng plan, phải xử lý trước khi duyệt.

| ID | Test | Task |
| --- | --- | --- |
| REQ-001 | `F01_S_happy_path_<…>` | T-01 |
| F-01.B1 | `F01_B1_<…>` | T-01 |
| F-01.I1 | `F01_I1_<…>` | T-02 |
