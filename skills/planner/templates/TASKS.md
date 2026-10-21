# <Tên feature> — Tasks

> Steps dùng checkbox (`- [ ]`).

**Spec:** `docs/superpowers/specs/<YYYY-MM-DD-topic>-design.md` + [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) + các flow trong `docs/flows/`. Flow là nguồn sự thật cho hành vi; khi task mâu thuẫn với flow, flow thắng.

**Goal:** <một câu: kết quả quan sát được khi mọi task xong>

<!--
Ràng buộc định dạng (do script task-brief của subagent-driven-development):
- Heading task phải khớp `## Task <N> (T-nn): ...`, N đánh số liên tục 1, 2, 3…
- Mọi dòng từ heading Task N tới heading Task kế tiếp thuộc brief của task đó,
  nên KHÔNG đặt nội dung chung nào sau task cuối cùng. Checkpoint phase là một step trong task cuối phase.
-->

## Global Constraints

Chép nguyên văn từ `C-*` và `NG-*` của plan, giá trị chính xác, mỗi dòng một mục. Mọi task ngầm bao gồm mục này.

- C-01 MUST <…>
- NG-01 Không <…>

## Ma trận truy vết

Mỗi REQ, mỗi nhánh `B`, mỗi invariant `I` xuất hiện ít nhất một lần. Ô trống = lỗ hổng plan, xử lý trước khi duyệt.

| ID | Test | Task |
| --- | --- | --- |
| REQ-001 | `F01_S_happy_path_<…>` | T-01 |
| F-01.B1 | `F01_B1_<…>` | T-01 |
| F-01.I1 | `F01_I1_<…>` | T-02 |

---

## Task 1 (T-01): <Tên — một deliverable kiểm chứng được, không chứa "và">

**Goal:** <một câu: kết quả quan sát được khi task này xong>
**Wave:** <n>
**Rủi ro:** cao (auth / dữ liệu / API–contract công khai) | thường
**Boundary:** <stack> · <từng trigger> · <từng integration> — tên nguyên văn theo bảng routing/stack/integration, ví dụ `Java/Spring · API/HTTP · Database write, nhiều store · Kafka`
**Flow / nhánh:** F-01.S1–S3, F-01.B1 — đọc `docs/flows/F-01-<slug>.md`: Bối cảnh, Concurrency & retry, Observability và các dòng này
**Requirements:** REQ-001
**Phụ thuộc:** — | Task N

**Cases** (≤ 5 dòng, nhiều hơn → tách task; Loại: happy | fail | invariant; dòng đầu là happy; mã lấy từ "Mã kết quả" của flow).

| ID | Loại | Input | Output (mã + trạng thái dữ liệu) | Test |
| --- | --- | --- | --- | --- |
| F-01.S3 | happy | `{sku:"A1",qty:2}` | `201 ORDER_CREATED`; 1 bản ghi status=NEW | `F01_S_happy_path_<…>` |
| F-01.B1 | fail | `{sku:"A1",qty:0}` | `400 INVALID_QTY`; không bản ghi nào | `F01_B1_<…>` |

**Files** (mỗi file thuộc đúng một task):
- Create: `exact/path/new_file.ext`
- Modify: `exact/path/existing.ext:120-145`
- Modify: `exact/path/routes.ext` — chia sẻ với T-02, chỉ `<symbol>` (chỉ khi không tránh được; phải có `Phụ thuộc`)
- Test: `tests/exact/path/test_file.ext`
- Docs: `<path#mục>` | — (không đổi bề mặt: <lý do>)

**Interfaces:**
- Consumes: <tên + chữ ký chính xác từ task trước, ví dụ `OrderRepository.findForUpdate(id: OrderId): Order | null` (Task 1)> | —
- Produces: <tên + chữ ký chính xác task sau sẽ dùng> | —

**Tái dùng:** `<symbol>` (`path:line`) — <validate / map lỗi / auth …> | —
**Không làm:** <việc dễ tiện tay làm khi chạm các file này, vd không đổi response endpoint cũ; nhánh F-01.B4 thuộc T-04> | —

**Done khi** (mọi dòng đạt; lệnh thật của repo):
- Test (mọi test trong Cases): `<lệnh>` → PASS
- Lint/build: `<lệnh>` → exit 0 | CHƯA XÁC ĐỊNH: <lý do>
- Docs: `<file#mục>` khớp <chữ ký / giá trị / lệnh cụ thể>; lệnh lint doc nếu repo có | —
- Manual: <việc kiểm bằng tay, nếu có> | —

- [ ] **Step 1: Viết test fail cho mọi dòng trong Cases**

```<lang>
// tên test chứa ID; assertion với mã + trạng thái dữ liệu chính xác từ Cases
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

- [ ] **Step 5: Cập nhật Docs (bỏ nếu `Docs: —`)**

<file#mục — nội dung chính xác cần thêm/sửa, lấy từ chữ ký và giá trị của task>

- [ ] **Step 6: Checkpoint phase <tên> (chỉ task cuối phase — bỏ step này ở task khác)**

Run: `<lệnh full test của repo>` và `<lệnh build>`
Expected: PASS — mọi flow của phase chạy end-to-end

<!-- Lặp lại khối "## Task N (T-nn)" cho mỗi task. Task là một slice dọc theo flow/nhánh (đủ các lớp nó đi qua),
     là đơn vị nhỏ nhất có chu trình test riêng và đáng để reviewer chấp nhận/từ chối độc lập. Không đặt gì sau task cuối. -->
