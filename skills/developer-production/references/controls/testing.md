# Kiểm thử và bàn giao

## TST-001 — Test theo hành vi

**CRITICAL khi đổi behavior có rủi ro.** Map acceptance criteria tới test có giá trị quan sát. Bao phủ success và failure path liên quan đến thay đổi: validation/auth, timeout, duplicate/retry, serialization hoặc rollback khi có trigger. Unit test cho logic; integration/contract test khi mock có thể che lỗi config, schema, transaction hoặc serialization. Không thêm test chỉ để lặp lại implementation; coverage percentage không thay evidence failure path.

## TST-002 — Kiểm tra thực tế

**CRITICAL khi đổi code.** Chạy kiểm tra phù hợp với thay đổi và cổng của repository. Mở rộng sang build hoặc test diện rộng khi đổi shared contract, config, security hoặc dữ liệu có rủi ro lan truyền. Kiểm tra diff, secret, generated file và phạm vi. Báo check thực chạy và check chưa chạy.

## TST-003 — Test tất định và cô lập

**CRITICAL khi thêm hoặc sửa test.** Test cho cùng kết quả ở mọi lần chạy và mọi thứ tự: inject clock, random/ID generator và timezone thay vì đọc giờ hệ thống; không `sleep` để chờ async mà dùng chờ theo điều kiện có timeout; mỗi test tự tạo và dọn dữ liệu, không phụ thuộc test khác hay dữ liệu môi trường dùng chung; không gọi dịch vụ bên ngoài thật ngoài container/sandbox do test quản lý. Test flaky phải sửa hoặc báo, không retry cho qua và không tắt mà không ghi lý do.

## TST-004 — Test cho lỗi và bug fix

**CRITICAL khi sửa bug.** Viết test tái hiện bug, xác nhận nó fail trước khi sửa và pass sau khi sửa. Test assert hành vi quan sát được (response, trạng thái lưu, event phát ra), không assert chi tiết nội bộ dễ đổi.

## TST-O01 — Load/soak test mới

**OPTIONAL.** Cân nhắc khi thêm test tải, môi trường, dữ liệu và ngưỡng mới.

## TST-O02 — Chaos automation

**OPTIONAL.** Cân nhắc khi thêm hạ tầng fault injection thường xuyên; failure path có liên quan vẫn phải test ở mức phù hợp.

## TST-O03 — Contract test giữa service

**OPTIONAL.** Cân nhắc consumer-driven contract (Pact hoặc tương đương) hoặc schema registry check trong CI khi nhiều team cùng dùng một API/event; cần broker/pipeline và owner. Nghĩa vụ tương thích của `DLV-002` vẫn critical.

## TST-O04 — Mutation/property-based test

**OPTIONAL.** Cân nhắc cho logic tính toán phức tạp (giá, phí, lịch, state machine) khi test ví dụ không đủ phủ biên.

## TST-O05 — Kiểm thử số liệu tài chính

**OPTIONAL — financial domain theo `GOV-OPT-002`, khi đổi logic tính tiền, phí, lãi hoặc đối soát.** Bộ test có bảng giá trị chuẩn được nghiệp vụ duyệt (golden dataset) gồm biên làm tròn, ngày lễ/cut-off và đổi múi giờ; kiểm tra tổng cân bằng (debit = credit) sau mỗi kịch bản.

**Bằng chứng:** lệnh và kết quả kiểm tra; test bug fix fail trước khi sửa.
