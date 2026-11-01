# Chất lượng mã

## CQ-001 — Convention có thể chạy

**CRITICAL khi đổi code.** Theo formatter/lint/static analysis và naming convention của repository. Suppression cần lý do hẹp và control bù trừ. Comment giải thích quyết định khó hiểu; không chép rule ID vào mọi dòng code.

Sau lần sửa code cuối cùng của tác vụ, rà diff của các file đã đổi. Chạy formatter ở chế độ kiểm tra hoặc so sánh kết quả, lint/static analysis và test phù hợp với repository. Xem lại tên, cấu trúc, lặp logic, import/comment/code không còn dùng; chỉ refactor trong phạm vi đã được phép và giữ nguyên hành vi ngoài yêu cầu. Nếu cần sửa, thực hiện theo quyền đã có rồi chạy lại kiểm tra liên quan. Khi chưa có quyền sửa file, chỉ báo đường dẫn và đề xuất thay đổi để người dùng duyệt. Hook tự động chỉ phát hiện và phản hồi, không ghi lại mã nguồn.

## CQ-002 — Comment đúng chỗ, luôn khớp code

**CRITICAL khi thêm hoặc sửa function/method.** Public API (export, endpoint handler, interface dùng chung) có doc comment nếu convention repo yêu cầu. Function có logic không hiển nhiên (quy tắc nghiệp vụ, thứ tự bắt buộc, workaround, lý do chọn giá trị) có comment ngắn giải thích *vì sao*. Function tên đã nói rõ ý nghĩa thì không cần comment. Comment cũ không còn đúng với code phải sửa hoặc xóa trong cùng thay đổi; không mô tả lại từng dòng.

## CQ-003 — Không để lại code tạm

**CRITICAL khi đổi code.** Diff không chứa code debug (print, log tạm, breakpoint), code comment-out, TODO không có ticket/owner, giá trị hard-code thay config, hay test bị skip không lý do.

## CQ-O01 — Scanner hoặc pre-commit mới

**OPTIONAL.** Cân nhắc khi thêm công cụ/rule set vào CI; xét false positive và thời gian build.

## CQ-O02 — Refactor ngoài phạm vi

**OPTIONAL.** Cân nhắc khi chỉnh code không liên quan feature để làm sạch style/structure.

**Bằng chứng:** formatter/linter/static analysis liên quan đã chạy; nếu thêm package, xem `ARC-DEP-003`.
