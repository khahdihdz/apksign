# apksign

**apksign** là công cụ quản lý chữ ký ứng dụng Android chạy trực tiếp trên **Termux**.

Công cụ được thiết kế để tạo và quản lý **một Android release keystore dùng chung** cho các dự án Android, đặc biệt phù hợp với hệ thống GitHub Actions của `khahdihdz`.

## ✨ Tính năng

- 🔐 Tạo Android release keystore RSA-4096
- 🔑 Quản lý alias và mật khẩu signing key
- 🔎 Xem thông tin certificate
- 🧾 Xem fingerprint SHA-256
- 📦 Xuất keystore sang Base64 để dùng với GitHub Actions
- ✅ Kiểm tra chữ ký APK bằng `apksigner`
- 💾 Sao lưu keystore
- 🛡️ Không ghi đè keystore đang tồn tại
- ⚙️ Chuẩn hóa 4 GitHub Secrets dùng chung cho các Android repository

## 📱 Yêu cầu

Cài **Termux** và có kết nối Internet.

Script có thể tự cài OpenJDK 17 và Coreutils. Nếu muốn kiểm tra APK bằng `apksigner`, cần Android SDK Build Tools và đưa `apksigner` vào `PATH`.

## 🚀 Cài đặt nhanh trên Termux

Chạy một lệnh để cài đặt hoặc cập nhật:

```sh
curl -fsSL https://raw.githubusercontent.com/khahdihdz/apksign/main/install.sh | sh
```

Sau đó mở menu ở bất kỳ thư mục nào bằng:

```sh
apksign
```

Không cần `cd ~/apksign`, `chmod` hoặc tự chạy `bash apksign`. Installer tạo lệnh trong Termux PATH và stash thay đổi cục bộ trước khi cập nhật repository.


## 🧭 Menu

```text
1. Cài JDK / công cụ
2. Tạo signing keystore
3. Ký APK bất kỳ
4. Xem certificate + SHA-256
5. Xuất keystore Base64
6. Kiểm tra APK đã ký
7. GitHub Secrets
8. Sao lưu keystore
0. Thoát
```

### Tạo signing keystore

Keystore mặc định:

```text
RSA 4096-bit
Alias: khahdihdz-release
Validity: 10000 ngày
~/.apksign/khahdihdz-release.jks
```

**Không xóa hoặc tạo lại keystore nếu đang dùng để phát hành ứng dụng.**

### Xuất Base64

Tạo file:

```text
~/.apksign/keystore.base64
```

Nội dung file dùng cho GitHub Secret `ANDROID_SIGNING_KEYSTORE_BASE64`.

### Kiểm tra APK

```bash
apksigner verify --verbose --print-certs app-release.apk
```

### Sao lưu

Bản sao được tạo tại:

```text
~/android-signing-backups/
```

Nên giữ ít nhất **2 bản sao lưu ở những nơi an toàn khác nhau**.

## 🔐 GitHub Actions

Trong mỗi Android repository, tạo 4 Repository Secrets:

| Secret | Giá trị |
|---|---|
| `ANDROID_SIGNING_KEYSTORE_BASE64` | Nội dung `keystore.base64` |
| `ANDROID_SIGNING_STORE_PASSWORD` | Mật khẩu keystore |
| `ANDROID_SIGNING_KEY_ALIAS` | `khahdihdz-release` |
| `ANDROID_SIGNING_KEY_PASSWORD` | Mật khẩu signing key |

### ⚠️ Bảo mật

**Không commit private keystore hoặc Base64 của nó vào repository public.**

Không commit:

```text
*.jks
*.keystore
*.p12
*.pfx
*.pem
*.key
*.base64
keystore.properties
release.jks
```

Private signing key bị lộ có thể cho phép người khác ký ứng dụng giả mạo bằng cùng certificate.

## 🔄 Cập nhật ứng dụng Android

Để APK/AAB mới cập nhật được ứng dụng đã cài, phải giữ nguyên:

1. **Application ID**
2. **Release signing key**

Ví dụ nếu ứng dụng đã dùng:

```text
com.example.app
```

thì các bản cập nhật phải tiếp tục dùng application ID đó và đúng private signing key cũ.

> **Không tạo keystore mới cho mỗi phiên bản của ứng dụng đã phát hành.**

## 📂 Dữ liệu cục bộ

```text
~/.apksign/
├── khahdihdz-release.jks
└── keystore.base64
```

Các file private key nằm ngoài repository.

## 🛠️ Dự án sử dụng

Bộ signing Secret này có thể dùng cho các Android project của **khahdihdz**, ví dụ:

- NRSuite-Android
- espflash
- Các Android project mới trong tương lai

Mỗi ứng dụng vẫn phải giữ **applicationId riêng**; việc dùng chung signing key là lựa chọn của hệ thống phát hành.


## 🤖 Tự động áp dụng cho Android repository

apksign hiện có cơ chế trung tâm tại `.github/workflows/sync-android-signing.yml`. Workflow định kỳ quét các repository thuộc tài khoản `khahdihdz`, nhận diện dự án có Gradle Wrapper Android, đồng bộ 4 signing secrets và thêm workflow signing dùng chung nếu repository chưa có workflow đó.

Cơ chế này dùng reusable workflow theo chuẩn GitHub Actions, giúp tránh phải sao chép logic signing giữa các repository. GitHub hỗ trợ reusable workflows và truyền secrets cho workflow được gọi.

### Thiết lập một lần

Trong repository `khahdihdz/apksign`, tạo 5 Actions Secrets:

- `APKSIGN_SYNC_TOKEN`: GitHub token có quyền đọc danh sách repository và ghi contents + Actions secrets vào các repository cần đồng bộ.
- `ANDROID_SIGNING_KEYSTORE_BASE64`
- `ANDROID_SIGNING_STORE_PASSWORD`
- `ANDROID_SIGNING_KEY_ALIAS`
- `ANDROID_SIGNING_KEY_PASSWORD`

Sau đó chạy **Actions → Sync Android signing to all repositories → Run workflow** một lần. Các lần sau workflow tự chạy theo lịch và có thể chạy thủ công. GitHub CLI hỗ trợ đặt repository secret từ workflow/token bằng `gh secret set`.

> Với tài khoản cá nhân, GitHub không có organization-level secret dùng chung cho toàn bộ repository. Cơ chế của apksign vì vậy đồng bộ secret vào từng Android repository; repository Android mới sẽ được nhận diện ở lần đồng bộ kế tiếp.

### Lưu ý quan trọng

Cơ chế tự động **không ghi đè workflow release Android hiện có**. NRSuite-Android và espflash đang có cấu hình release signing riêng nên được giữ nguyên; hệ thống chỉ bổ sung/cấu hình repository Android mới chưa có workflow signing trung tâm.

### Phạm vi

- Android repository hiện tại: tự đồng bộ khi chạy workflow.
- Android repository tương lai: tự phát hiện ở lần chạy lịch tiếp theo.
- APK release: ký bằng cùng certificate đã cấu hình.
- Không đưa private keystore vào Git.
- Không fallback release sang debug signing.

## 🌐 Landing Page

Trang giới thiệu tính năng và tải xuống:

**https://khahdihdz.github.io/apksign/**

- ⬇️ Tải mã nguồn dạng ZIP
- 🔗 Truy cập repository GitHub
- 📦 Truy cập Releases
- 📱 Giới thiệu tính năng và hướng dẫn cài đặt nhanh

## 📄 Giấy phép

Phát hành theo giấy phép **MIT**.

## 👤 Tác giả

**khahdihdz**

Website: https://khahdihdz.github.io/

[Repository apksign](https://github.com/khahdihdz/apksign)


## ☁️ Sao lưu Google Drive

Menu **9 → 10** là luồng đồng bộ một chiều:

1. Chọn **9**: xác minh keystore và mật khẩu, cập nhật 4 GitHub Secrets. Khi thành công, công cụ lưu chính bộ signing vừa xác minh trong `~/.apksign/credentials/` với quyền truy cập riêng tư.
2. Chọn **10 → 1**: tự lấy đúng keystore và 4 secrets từ bước 9, mã hóa archive bằng AES-256-CBC + PBKDF2 (300.000 vòng), rồi tải lên Google Drive. Không cần nhập lại từng secret.
3. Chọn **10 → 2**: khôi phục archive. Việc khôi phục không tự ghi đè GitHub Secrets.

Cấu hình remote Google Drive tên `gdrive` một lần bằng `rclone config` (cần cài `rclone`, `openssl`, `tar`). Mục 10 không còn lựa chọn cài đặt/cấu hình; nó kiểm tra remote rồi đồng bộ trực tiếp.

**Bảo mật:** GitHub không cho đọc ngược Actions Secrets; mục 9 là nguồn dữ liệu chuẩn. Mật khẩu signing được lưu cục bộ dạng tệp riêng tư (quyền 600) để mục 10 dùng lại. Signing store password cũng được dùng để mã hóa archive. Bảo vệ thiết bị và thư mục `~/.apksign/credentials/`.
