# <Tên feature> — Tasks

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development (mặc định) hoặc superpowers:executing-plans. Chạy liên tục, review dồn ở cuối. Steps dùng checkbox (`- [ ]`).

**Spec:** `docs/superpowers/specs/<YYYY-MM-DD-topic>-design.md` + [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) + các flow trong `docs/flows/`. Flow là nguồn sự thật cho hành vi; khi task mâu thuẫn với flow, flow thắng.

**Goal:** <một câu>

<!--
Ràng buộc định dạng (do script task-brief của subagent-driven-development):
- Heading task phải khớp `## Task <N> (T-nn): ...`, N đánh số liên tục 1, 2, 3…
- Mọi dòng từ heading Task N tới heading Task kế tiếp thuộc brief của task đó,
  nên KHÔNG đặt nội dung chung nào sau task cuối cùng.
-->

## Global Constraints

Chép nguyên văn từ `C-*` và `NG-*` của plan, giá trị chính xác, mỗi dòng một mục. Mọi task ngầm bao gồm mục này.

- C-01 MUST <…>
- NG-01 Không <…>
- Chỉ sửa file nằm trong "Files" của task đang làm.

## Ma trận truy vết

Mỗi REQ, mỗi nhánh `B`, mỗi invariant `I` xuất hiện ít nhất một lần. Ô trống = lỗ hổng plan, xử lý trước khi duyệt.

| ID | Test | Task |
| --- | --- | --- |
| REQ-001 | `F01_S_happy_path_<…>` | T-01 |
| F-01.B1 | `F01_B1_<…>` | T-01 |
| F-01.I1 | `F01_I1_<…>` | T-02 |

---

## Task 1 (T-01): <Tên — một deliverable kiểm chứng được>

**Rủi ro:** cao (auth / dữ liệu / API–contract công khai) | thường
**Flow / nhánh:** F-01.S1–S3, F-01.B1 — đọc `docs/flows/F-01-<slug>.md`, chỉ các dòng này
**Requirements:** REQ-001
**Phụ thuộc:** — | Task N

**Files:**
- Create: `exact/path/new_file.ext`
- Modify: `exact/path/existing.ext:120-145`
- Test: `tests/exact/path/test_file.ext`

**Interfaces:**
- Consumes: <tên + chữ ký chính xác từ task trước, ví dụ `OrderRepository.findForUpdate(id: OrderId): Order | null` (Task 1)> | —
- Produces: <tên + chữ ký chính xác task sau sẽ dùng> | —

- [ ] **Step 1: Viết test fail cho F-01.B1**

```<lang>
// tên test chứa ID; assertion với giá trị chính xác từ flow
test("F01_B1_<…>", () => { … })
```

- [ ] **Step 2: Chạy test, xác nhận fail**

Run: `<lệnh chạy đúng test này>`
Expected: FAIL — <thông điệp mong đợi, ví dụ "function not defined">

- [ ] **Step 3: Implement `<chữ ký chính xác>` trong `<file>`**

<Một dòng về cách làm khi chữ ký và test còn để ngỏ lựa chọn. Chỉ viết thân hàm khi đó là thuật toán mà chữ ký + test không quyết định được.>

- [ ] **Step 4: Chạy test, xác nhận pass**

Run: `<lệnh>`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add <files>
git commit -m "<type>: <mô tả> (T-01, F-01.B1)"
```

<!-- Lặp lại khối "## Task N (T-nn)" cho mỗi task. Task là đơn vị nhỏ nhất có chu trình test riêng
     và đáng để reviewer chấp nhận/từ chối độc lập. Không đặt gì sau task cuối. -->
