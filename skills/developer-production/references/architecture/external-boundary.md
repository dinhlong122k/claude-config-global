# Ranh giới tích hợp bên ngoài

## ARC-EXT-001 — Boundary có owner rõ

**CRITICAL khi gọi hệ thống ngoài.** Đặt client lifecycle, config, mapping dữ liệu và lỗi kỹ thuật ở boundary theo `ARC-STR-002`. Logic nghiệp vụ dùng operation có nghĩa nghiệp vụ; tránh wrapper trùng trách nhiệm và SDK request/response rò vào domain. Giữ cách tổ chức đã có nếu boundary tương đương.

## ARC-EXT-002 — Contract operation

**CRITICAL khi gửi/nhận request, file hoặc message.** Ghi input/output, side effect, idempotency, timeout/deadline, trạng thái kết quả không rõ, error mapping và dữ liệu được phép log. Message handler phải nêu ack/commit, invalid payload, duplicate và poison message.

## ARC-EXT-O01 — Client wrapper dùng chung

**OPTIONAL.** Cân nhắc khi thêm package wrapper cho nhiều service; cần owner, version và consumer rõ.

**Bằng chứng:** đường import và test adapter cho thành công, timeout, lỗi cố định và dependency unavailable.
