# Phụ thuộc và hợp đồng

## ARC-DEP-001 — Chiều phụ thuộc

**CRITICAL khi thêm/đổi dependency.** Application/domain không import HTTP framework, persistence entity, SFTP/MinIO/Redis/Kafka client hoặc DTO của bên ngoài. Adapter phụ thuộc vào port do consumer sở hữu. Chỉ tạo abstraction có consumer thật.

## ARC-DEP-002 — Contract có owner

**CRITICAL khi đổi API, event, schema hoặc shared package.** Xác định producer/owner, consumer, compatibility, migration và rollback/forward fix. Không thay shared contract của feature khác một cách ngầm định.

## ARC-DEP-003 — Dependency tái lập

**CRITICAL khi thêm/nâng thư viện.** Dùng BOM/lockfile/convention của repo, version được quản lý tập trung và build tái lập; kiểm tra license/vulnerability theo pipeline hiện có.

## ARC-DEP-O01 — Architecture test

**OPTIONAL.** Cân nhắc khi thêm ArchUnit hoặc rule import/module trong CI; áp dụng khi có nhiều module hoặc vi phạm lặp lại.

**Bằng chứng:** diff dependency, contract tests và ghi chú migration.
