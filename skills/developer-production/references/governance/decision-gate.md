# Cổng quyết định

## GOV-DEC-001 — Phân biệt thiếu thông tin với lựa chọn triển khai

**CRITICAL khi quyết định ảnh hưởng contract hoặc rủi ro.** Trước hết tìm bằng chứng trong yêu cầu, code, test, cấu hình và convention. Agent tự chọn cách triển khai thường ngày khi lựa chọn có thể đảo ngược, nằm trong phạm vi và có thể kiểm chứng. Nêu giả định quan trọng trong bàn giao.

Hỏi người dùng khi các phương án dẫn tới hành vi quan sát được, quyền truy cập, mất dữ liệu, nghĩa vụ vận hành hoặc chi phí đáng kể khác nhau, và không có cơ sở đáng tin để chọn. Nêu câu hỏi cụ thể, phương án, hệ quả và khuyến nghị. Chỉ tạm dừng phần phụ thuộc quyết định đó; tiếp tục khảo sát hoặc công việc độc lập. Không dùng việc chọn reference hay folder name đơn thuần làm lý do dừng.

Ghi quyết định quan trọng bằng `DEC-...` khi nó giúp người khác hiểu contract hoặc trade-off; không lập biên bản cho mọi lựa chọn nhỏ. Nếu bằng chứng mới làm thay đổi tiền đề, xét lại quyết định.

## GOV-OPT-001 — Optional theo nhu cầu

**CRITICAL khi xét một phương án OPTIONAL.** `OPTIONAL` không mặc nhiên là yêu cầu và không tạo nghĩa vụ hỏi người dùng. Chỉ thêm khi cần cho hành vi được yêu cầu, có bằng chứng rủi ro, hoặc đã có convention tương ứng. Nếu phương án làm tăng đáng kể phạm vi, chi phí, quyền truy cập hoặc nghĩa vụ vận hành, áp dụng `GOV-DEC-001`. Không triển khai toàn bộ optional chỉ vì đã đọc một module.

## GOV-OWN-001 — Một owner cho mỗi rule

**CRITICAL khi tạo hoặc sửa skill/rule.** Quy tắc chung được định nghĩa ở architecture hoặc controls; integration bổ sung semantics riêng; stack adapter chỉ ra cách áp dụng bằng công nghệ cụ thể; routing không lặp nội dung rule. Khi chuyển owner, cập nhật link trong cùng thay đổi.

## GOV-EVD-001 — Kết luận dựa trên evidence

**CRITICAL trước khi bàn giao feature.** Các control áp dụng cho đường thay đổi cần có bằng chứng phù hợp: test, cấu hình, contract hoặc kiểm tra trực tiếp. Ghi rõ phần chưa chạy hoặc chưa kiểm chứng và rủi ro còn lại. Không ghi pass cho check chưa chạy; không cần lập bảng cho rule không có trigger.

## GOV-EXC-001 — Ngoại lệ có chủ sở hữu

**CRITICAL khi muốn bỏ qua yêu cầu bảo mật, dữ liệu hoặc contract đang áp dụng.** Nêu phạm vi, rủi ro, biện pháp bù trừ và owner. Nếu thay đổi làm lệch yêu cầu rõ ràng của người dùng hoặc chính sách repository, cần người có thẩm quyền chấp thuận trước phần phụ thuộc. Agent không tự coi sự im lặng là chấp thuận.
