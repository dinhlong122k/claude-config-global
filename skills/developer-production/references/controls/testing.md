# Kiểm thử và bàn giao

## TST-001 — Test theo hành vi

**CRITICAL khi đổi behavior có rủi ro.** Map acceptance criteria tới test có giá trị quan sát. Bao phủ success và failure path liên quan đến thay đổi: validation/auth, timeout, duplicate/retry, serialization hoặc rollback khi có trigger. Unit test cho logic; integration/contract test khi mock có thể che lỗi config, schema, transaction hoặc serialization. Không thêm test chỉ để lặp lại implementation; coverage percentage không thay evidence failure path.

## TST-002 — Kiểm tra thực tế

**CRITICAL khi đổi code.** Chạy kiểm tra phù hợp với thay đổi và cổng của repository. Mở rộng sang build hoặc test diện rộng khi đổi shared contract, config, security hoặc dữ liệu có rủi ro lan truyền. Kiểm tra diff, secret, generated file và phạm vi. Báo check thực chạy và check chưa chạy.

## TST-O01 — Load/soak test mới

**OPTIONAL.** Cân nhắc khi thêm test tải, môi trường, dữ liệu và ngưỡng mới.

## TST-O02 — Chaos automation

**OPTIONAL.** Cân nhắc khi thêm hạ tầng fault injection thường xuyên; failure path có liên quan vẫn phải test ở mức phù hợp.

**Bằng chứng:** lệnh và kết quả kiểm tra.
