<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->
## CodeGraph — bắt buộc dùng tự động

Bổ sung cho block trên (block đó do `codegraph` CLI quản lý, không sửa tay). Khi repo có `.codegraph/`, áp dụng mặc định:

- Mọi câu hỏi về code (how/where/why, flow, bug, impact) và trước khi sửa code: gọi `codegraph_explore` TRƯỚC với tên symbol/file để xem source và blast radius. Không grep/Glob/Read để khám phá khi chưa gọi nó. Tool bị deferred → load bằng ToolSearch `select:mcp__codegraph__codegraph_explore`; không có MCP → dùng shell.
- Tin kết quả codegraph, không grep lại để kiểm chứng.
- Read/Grep trực tiếp chỉ khi: file không được index (config, docs, yml, properties), cần chi tiết codegraph chưa trả về, hoặc file vừa sửa trong session (index lag ~1s).
- Không spawn subagent chỉ để tìm/đọc code.

## Điều phối agent — chia để trị

Ba tầng plan/task → agent → skill, mỗi tầng một trách nhiệm (bảng ở `README.md`). Plan/task chỉ nói làm gì (mục tiêu, phạm vi, acceptance criteria, file, test), không nêu tên skill/agent hay cách code.

Agent chính là orchestrator: chọn agent theo bảng dưới, gom kết quả, và là nơi **duy nhất** hỏi người dùng. Subagent không hỏi người dùng; câu hỏi và blocker trả về trong report.

| Ý định | Agent |
| --- | --- |
| Triển khai code theo plan/task file | `task-executor` |
| Chuyển design đã duyệt thành plan, cập nhật plan | `task-planner` |
| Lập plan một file từ yêu cầu nghiệp vụ, không qua skill `planner` | `planner` |
| Review/refactor không đổi hành vi | `code-reviewer` |
| Review bảo mật | `security-reviewer` |
| Đối chiếu plan ↔ code theo ID | `plan-reviewer` |
| Tìm vị trí code (repo không có `.codegraph/`) | `explorer` |

### Thực thi plan

Khi người dùng đưa file plan/task và yêu cầu triển khai:

1. `docs/TASKS.md` theo template `planner` (heading `## Task N (T-nn)`): chạy `superpowers:subagent-driven-development`, nhưng **implementer dispatch bằng `subagent_type: task-executor`** thay cho `general-purpose`. Đây là ưu tiên của người dùng, ghi đè template implementer của skill đó. Không có skill đó, hoặc file task dạng khác: dispatch theo `Wave` — task cùng wave chạy song song (mỗi task một `task-executor`), wave sau chờ wave trước xong; file task không có `Wave` → lần lượt từng task.
2. Chạy liên tục, không dừng giữa task kể cả task rủi ro cao, trừ khi `task-executor` trả `BLOCKED` hoặc `NEEDS_CONTEXT`. Khi đó dừng task đó và task phụ thuộc, chạy tiếp task độc lập.
   - Plan im lặng ≠ mâu thuẫn: không tự chọn hành vi (`PLAN-EXE-001`). Gom `GAPS` hỏi người dùng một lượt, rồi chạy lại task bị chặn.
   Review dồn ở cuối:
   - `security-reviewer` trên diff toàn nhánh, và `plan-reviewer` đối chiếu theo ID.
   - `code-reviewer` (chế độ chỉ review) khi không chạy qua `subagent-driven-development`, vì skill đó đã review chất lượng từng task.
3. Gom finding HIGH → MEDIUM → LOW, hỏi người dùng trước khi sửa. Báo một lượt: task xong kèm `VERIFY`, task rủi ro cao (auth, dữ liệu, contract) kèm danh sách file đã đổi, giả định/ruling, check chưa chạy.
