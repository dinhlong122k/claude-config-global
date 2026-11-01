# <Tên feature> — Tasks

> Steps dùng checkbox (`- [ ]`).

**Spec:** `docs/superpowers/specs/<YYYY-MM-DD-topic>-design.md` + [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) + flow (`docs/flows/` hoặc §6 plan). Flow là nguồn sự thật; task mâu thuẫn với flow → flow thắng.

**Goal:** <một câu: kết quả quan sát được khi mọi task xong>

<!--
Định dạng (script tách brief đọc trực tiếp file này):
- Heading task khớp `## Task <N> (T-nn): ...`, N liên tục 1, 2, 3…
- Mọi dòng từ heading Task N tới heading kế tiếp là brief của task đó → KHÔNG đặt gì sau task cuối;
  Checkpoint phase là một step trong task cuối phase.
- Brief không chứa phần đầu file: lệnh, chữ ký, giá trị ràng buộc, input/mã phải nằm trong khối task.
- Task là slice dọc theo flow/nhánh, đủ các lớp nó đi qua.
- Trường lõi: Goal, Wave, Rủi ro, Boundary, Flow / nhánh, Requirements, Phụ thuộc, Cases, Files, Done khi, Steps.
  Trường khác bỏ hẳn dòng khi không áp dụng.
- Steps mặc định TDD; task không hợp TDD (migration, config, doc) dùng step theo bản chất task, mỗi step có lệnh + kết quả mong đợi.
-->

## Global Constraints

Chép nguyên văn `C-*`, `NG-*` từ plan, mỗi dòng một mục. Cho orchestrator và reviewer; brief không chứa mục này.

- C-01 MUST <…>
- NG-01 Không <…>

## Ma trận truy vết

Mỗi REQ, `B`, `I` có ít nhất một dòng; ô trống = lỗ hổng plan.

| ID | Test | Task |
| --- | --- | --- |
| REQ-001 | `F01_S_happy_<…>` | T-01 |
| F-01.B1 | `F01_B1_<…>` | T-01 |

---

## Task 1 (T-01): <Tên — một deliverable kiểm chứng được, không chứa "và">

**Goal:** <kết quả quan sát được khi task xong>
**Wave:** <n>
**Rủi ro:** cao (auth / dữ liệu / contract công khai) | thường
**Boundary:** <stack> · <từng trigger> · <từng integration> — tên nguyên văn theo bảng routing/stack/integration
**Flow / nhánh:** F-01.S1–S3, F-01.B1 — đọc `docs/flows/F-01-<slug>.md` | `docs/IMPLEMENTATION_PLAN.md#f-01-<tên>`: <các mục cần đọc>
**Requirements:** REQ-001
**Ràng buộc:** <C-* chạm task, giá trị nguyên văn>
**Phụ thuộc:** — | Task N

**Trạng thái trước / sau** (ngoài chữ ký code):
- Tiền điều kiện: <trạng thái phải có + task tạo ra hoặc `path:line` baseline>
- Hậu điều kiện: <trạng thái task sau giả định>

**Cases** (≤ 5 dòng; dòng đầu happy; mã từ "Mã kết quả" của flow):

| ID | Loại | Input | Output (mã + trạng thái dữ liệu) | Test |
| --- | --- | --- | --- | --- |
| F-01.S3 | happy | <giá trị chính xác> | <mã; dữ liệu sau> | `F01_S_happy_<…>` |
| F-01.B1 | fail | <…> | <…> | `F01_B1_<…>` |

**Dữ liệu test:** <fixture path + giá trị chính xác> | dùng lại `<path:line>`

**Files** (mỗi file thuộc đúng một task):
- Create: `<path>`
- Modify: `<path:lines>` (dùng chung không tránh được: `— chia sẻ với T-xx, chỉ <symbol>` + `Phụ thuộc`)
- Test: `<path>`
- Docs: `<path#mục>`

**Interfaces:**
- Consumes: <chữ ký chính xác> (Task N)
- Produces: <chữ ký chính xác task sau dùng>

**Tái dùng:** `<symbol>` (`path:line`) — <mục đích>
**Không làm:** <việc dễ tiện tay làm khi chạm các file này>

**Done khi** (lệnh thật của repo):
- Test: `<lệnh>` → PASS
- Lint/build: `<lệnh>` → exit 0 | CHƯA XÁC ĐỊNH: <lý do>
- Hoàn tác (task rủi ro cao đổi schema/dữ liệu/config): <cách>; `<lệnh>` → exit 0
- Docs: `<file#mục>` khớp <chữ ký / giá trị / lệnh>
- Manual: <kiểm bằng tay>

- [ ] **Step 1: Viết test fail cho mọi dòng Cases** — tên test chứa ID; assert mã + trạng thái dữ liệu từ Cases.
- [ ] **Step 2: Chạy test, xác nhận fail** — Run: `<lệnh>` · Expected: FAIL — <thông điệp>
- [ ] **Step 3: Implement `<chữ ký>` trong `<file>`** — <một dòng khi chữ ký + test còn để ngỏ lựa chọn>
- [ ] **Step 4: Chạy test, xác nhận pass** — Run: `<lệnh>` · Expected: PASS
- [ ] **Step 5: Cập nhật Docs** (khi có `Docs:`) — <file#mục: nội dung chính xác>
- [ ] **Step 6: Checkpoint phase <tên>** (chỉ task cuối phase) — Run: `<full test>` và `<build>` (từ §12 plan) · Expected: PASS
