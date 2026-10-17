# Adapter theo ngôn ngữ và framework

Chỉ đọc một adapter tương ứng với repository. Adapter ánh xạ rule chung sang idiom/cấu hình của stack; không định nghĩa lại policy hoặc bắt dự án đổi framework.

Nhận diện stack từ manifest ở root (hoặc module đang sửa trong monorepo). Nhiều manifest khớp → chọn theo file sắp sửa.

| Stack | Manifest nhận diện | Reference |
| --- | --- | --- |
| Java/Spring | `pom.xml`, `build.gradle`, `build.gradle.kts` | [java-spring.md](java-spring.md) |
| TypeScript/Node | `package.json` (kèm `tsconfig.json` nếu TypeScript) | [typescript-node.md](typescript-node.md) |
| Python | `pyproject.toml`, `setup.py`, `requirements*.txt` | [python.md](python.md) |
| Go | `go.mod` | [go.md](go.md) |

Stack không có adapter → áp dụng rule chung và convention của repo, ghi rõ trong report là không có adapter.

Với thư viện/SDK cụ thể, kiểm tra API và property name theo version đang được pin trong repository. Các giá trị timeout, retry, pool, TTL và quota được chốt từ SLO và contract feature, không sao chép từ ví dụ.
