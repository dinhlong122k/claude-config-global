# <Tên feature> — Tasks

> File này chỉ mô tả **làm gì**. Cách thực thi (agent nào, nạp rule nào, review khi nào) do mục "Thực thi plan" trong `CLAUDE.md` quyết định; không ghi tên skill hay agent trong task. Steps dùng checkbox (`- [ ]`).

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
- Chỉ sửa file nằm trong "Files" của task đang làm. Không sửa code mà task khác tạo; dùng qua `Consumes`.

## Ma trận truy vết

Mỗi REQ, mỗi nhánh `B`, mỗi invariant `I` xuất hiện ít nhất một lần. Ô trống = lỗ hổng plan, xử lý trước khi duyệt.

| ID | Test | Task |
| --- | --- | --- |
| REQ-001 | `F01_S_happy_path_<…>` | T-01 |
| F-01.B1 | `F01_B1_<…>` | T-01 |
| F-01.I1 | `F01_I1_<…>` | T-02 |

---

## Task 1 (T-01): <Tên — một deliverable kiểm chứng được, không chứa "và">

**Mục tiêu:** <một câu: sau task này quan sát được gì>
**Quy mô:** XS | S | M — L trở lên (> 5 file) phải tách
**Rủi ro:** cao (auth / dữ liệu / API–contract công khai) | thường
**Phase:** <1 Nền | 2 … >
**Boundary:** <stack> · <từng trigger> · <từng integration> — tên nguyên văn theo bảng routing/stack/integration, ví dụ `Java/Spring · API/HTTP · Database write, nhiều store · Kafka`
**Flow / nhánh:** F-01.S1–S3, F-01.B1 — đọc `docs/flows/F-01-<slug>.md`: Bối cảnh, Concurrency & retry, Observability và các dòng này
**Requirements:** REQ-001
**Phụ thuộc:** — | Task N

**Acceptance criteria** (≤ 3, mỗi dòng gắn ID, giá trị chính xác từ flow):
- [ ] F-01.S3: <điều kiện quan sát được, ví dụ "POST /orders trả 201 và một bản ghi status=NEW">
- [ ] F-01.B1: <…>

**Files** (mỗi file thuộc đúng một task):
- Create: `exact/path/new_file.ext`
- Modify: `exact/path/existing.ext:120-145`
- Modify: `exact/path/routes.ext` — chia sẻ với T-02, chỉ `<symbol>` (chỉ khi không tránh được; phải có `Phụ thuộc`)
- Test: `tests/exact/path/test_file.ext`
- Docs: `README.md#<mục>` / `docs/api/openapi.yaml` / `CHANGELOG.md` (entry riêng) — <nội dung phải đổi> | — (không đổi bề mặt: <lý do>)

**Interfaces:**
- Consumes: <tên + chữ ký chính xác từ task trước, ví dụ `OrderRepository.findForUpdate(id: OrderId): Order | null` (Task 1)> | —
- Produces: <tên + chữ ký chính xác task sau sẽ dùng> | —

**Tái dùng:** `<symbol>` (`path:line`) — <validate / map lỗi / auth …> | —
**Không làm:** <việc dễ tiện tay làm khi chạm các file này, vd không đổi response endpoint cũ; nhánh F-01.B4 thuộc T-04> | —

**Verification** (task chỉ xong khi mọi dòng đạt; lệnh thật của repo):
- Test: `<lệnh chạy test của task>` → PASS
- Lint/build: `<lệnh>` → PASS | CHƯA XÁC ĐỊNH: <lý do>
- Docs: `<file#mục>` khớp <chữ ký / giá trị / lệnh cụ thể>; lệnh lint doc nếu repo có | —
- Manual: <việc kiểm bằng tay, nếu có> | —

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

- [ ] **Step 5: Cập nhật Docs (bỏ nếu `Docs: —`)**

<file#mục — nội dung chính xác cần thêm/sửa, lấy từ chữ ký và giá trị của task>

- [ ] **Step 6: Commit** (code + test + doc cùng commit)

```bash
git add <files>
git commit -m "<type>: <mô tả> (T-01, F-01.B1)"
```

- [ ] **Step 7: Checkpoint phase <tên> (chỉ task cuối phase — bỏ step này ở task khác)**

Run: `<lệnh full test của repo>` và `<lệnh build>`
Expected: PASS — mọi flow của phase chạy end-to-end

<!-- Lặp lại khối "## Task N (T-nn)" cho mỗi task. Task là một slice dọc theo flow/nhánh (đủ các lớp nó đi qua),
     là đơn vị nhỏ nhất có chu trình test riêng và đáng để reviewer chấp nhận/từ chối độc lập. Không đặt gì sau task cuối. -->
