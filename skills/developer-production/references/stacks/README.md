# Adapter theo ngôn ngữ và framework

Chỉ đọc một adapter tương ứng với repository. Adapter ánh xạ rule chung sang idiom/cấu hình của stack; không định nghĩa lại policy hoặc bắt dự án đổi framework.

| Stack | Reference |
| --- | --- |
| Java/Spring | [java-spring.md](java-spring.md) |
| TypeScript/Node | [typescript-node.md](typescript-node.md) |
| Python | [python.md](python.md) |
| Go | [go.md](go.md) |

Với thư viện/SDK cụ thể, kiểm tra API và property name theo version đang được pin trong repository. Các giá trị timeout, retry, pool, TTL và quota được chốt từ SLO và contract feature, không sao chép từ ví dụ.
