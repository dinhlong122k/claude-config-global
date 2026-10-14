# Kiến trúc

| Khi nào | Reference |
| --- | --- |
| Tạo hoặc đổi module/folder | [structure.md](structure.md) |
| Đổi chiều phụ thuộc, public contract hoặc dependency | [dependencies.md](dependencies.md) |
| Thêm SFTP, MinIO, Keycloak Admin API, Redis, Kafka hoặc external HTTP | [external-boundary.md](external-boundary.md) |

Architecture sở hữu ranh giới chung. Integration không định nghĩa lại folder structure; stack adapter không tạo architecture policy mới.
