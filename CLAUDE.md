<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->

## CodeGraph — bắt buộc dùng tự động

Nếu repo có `.codegraph/`, các quy tắc sau áp dụng MẶC ĐỊNH, không cần user nhắc:

- Mọi câu hỏi về code (how/where/why, flow, bug, impact) → gọi `codegraph_explore` TRƯỚC. Không grep/Glob/Read để khám phá khi chưa gọi nó.
- Trước khi sửa code → gọi `codegraph_explore` với tên symbol/file sắp sửa để xem source + blast radius, rồi mới Edit.
- Tin kết quả codegraph, không grep lại để kiểm chứng.
- Chỉ Read/Grep trực tiếp khi: file không được index (config, docs, yml, properties), hoặc cần chi tiết codegraph chưa trả về, hoặc file vừa sửa trong session này (index lag ~1s).
- Tool bị deferred → load bằng ToolSearch `select:mcp__codegraph__codegraph_explore` rồi gọi, không bỏ qua.
- Không spawn subagent chỉ để tìm/đọc code — codegraph đã làm việc đó.
