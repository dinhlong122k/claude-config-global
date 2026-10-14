# Cấu trúc dự án

## ARC-STR-001 — Module có một trách nhiệm

**CRITICAL khi tạo hoặc đổi module.** Chốt owner của behavior, API và dữ liệu. Tổ chức theo feature/domain hiện có; trong module tách entry point, application/domain, persistence và external adapter khi các trách nhiệm đó thực sự tồn tại. Không tạo folder rỗng cho đủ sơ đồ hoặc đặt business rule ở controller/client SDK.

## ARC-STR-002 — Vị trí external

**CRITICAL khi thêm external dependency.** Đặt implementation kết nối theo convention hiện có và giữ SDK/transport DTO/config bên ngoài logic nghiệp vụ. Nếu chưa có convention, chọn vị trí gần mã liên quan với trách nhiệm rõ ràng; `external/` hoặc `infrastructure/external/` chỉ là ví dụ. Chỉ thêm port/interface khi có consumer cần tách khỏi SDK. Ghi lý do nếu thay đổi boundary công khai.

## ARC-STR-003 — Tên theo nghiệp vụ

**CRITICAL khi thêm public type/module/operation.** Tên nhất quán với domain và contract. Tránh package `common`, `helper`, `util` đa trách nhiệm. Đổi tên public contract cần đánh giá tương thích.

## ARC-STR-O01 — Tách deployment/module build

**OPTIONAL.** Cân nhắc khi tách feature thành service, artifact hoặc module build riêng; cần lý do về ownership, release hoặc scale.

## ARC-STR-O02 — Migration package layout

**OPTIONAL.** Cân nhắc khi chuyển project đang package-by-layer sang package-by-feature; giới hạn scope và kế hoạch tương thích.

**Bằng chứng:** cây thư mục vùng thay đổi và kiểm tra chiều import.
