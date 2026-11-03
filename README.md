# apksign

**apksign** là công cụ quản lý chữ ký phát hành Android chạy trực tiếp trên **Termux**. Công cụ giúp duy trì một release keystore dùng chung cho các dự án Android, đồng bộ GitHub Actions Secrets và sao lưu bộ signing được mã hóa lên Google Drive.

## ✨ Tính năng

- 🔐 Tạo Android release keystore RSA-4096.
- 🔑 Quản lý alias và mật khẩu signing key.
- 🔎 Xem thông tin certificate và fingerprint SHA-256.
- 📦 Xuất keystore Base64 cho GitHub Actions.
- ✅ Kiểm tra chữ ký APK bằng `apksigner`.
- 💾 Sao lưu keystore cục bộ.
- 🔄 Đồng bộ và xác minh 4 GitHub Actions Secrets.
- ☁️ Sao lưu/khôi phục bộ signing qua Google Drive bằng rclone.
- 🔒 Mã hóa archive AES-256-CBC, PBKDF2 300.000 vòng trước khi tải lên Drive.
- 🛡️ Không ghi đè keystore đang tồn tại khi tạo mới; không tự động ghi GitHub Secrets khi restore.

## 📱 Yêu cầu

- Android có cài **Termux** và kết nối Internet.
- OpenJDK 17/Coreutils (có thể cài từ menu).
- GitHub CLI (`gh`) và đăng nhập GitHub nếu sử dụng mục 9.
- `rclone`, `openssl`, `tar` nếu sử dụng Google Drive Backup.
- Termux:API là tùy chọn nếu muốn nhận thông báo Android ngoài terminal.

Cài Termux và Termux:API từ cùng một nguồn phát hành để tránh lỗi tương thích plugin.

## 🚀 Cài đặt nhanh trên Termux

Cài đặt hoặc cập nhật bằng một lệnh:

```sh
curl -fsSL https://raw.githubusercontent.com/khahdihdz/apksign/main/install.sh | sh
```

Mở menu từ bất kỳ thư mục nào:

```sh
apksign
```

Cập nhật:

```sh
apksign --update
```

Installer tạo lệnh trong Termux PATH và giữ dữ liệu signing trong `~/.apksign/` khi cập nhật.

## 🧭 Menu chính

```text
1. Cài JDK / công cụ
2. Tạo signing keystore
3. Ký APK bất kỳ
4. Xem certificate + SHA-256
5. Xuất keystore Base64
6. Kiểm tra APK đã ký
7. GitHub Secrets
8. Sao lưu keystore cục bộ
9. Đồng bộ 4 GitHub Secrets
10. Đồng bộ bộ signing đã xác minh lên Google Drive
0. Thoát
```

### Signing keystore

Thông tin mặc định:

| Thuộc tính | Giá trị |
|---|---|
| Thuật toán | RSA 4096-bit |
| Alias | `khahdihdz-release` |
| Validity | 10.000 ngày |
| Keystore | `~/.apksign/khahdihdz-release.jks` |

**Quan trọng:** Không tạo keystore mới cho ứng dụng đã phát hành. Các bản cập nhật Android phải giữ nguyên Application ID và release signing key cũ.

### GitHub Actions Secrets

Mục 9 xác minh keystore/password/alias rồi đồng bộ 4 secrets:

| Secret | Giá trị |
|---|---|
| `ANDROID_SIGNING_KEYSTORE_BASE64` | Nội dung `~/.apksign/keystore.base64` |
| `ANDROID_SIGNING_STORE_PASSWORD` | Signing store password |
| `ANDROID_SIGNING_KEY_ALIAS` | Alias của key |
| `ANDROID_SIGNING_KEY_PASSWORD` | Signing key password |

Mục 9 là nguồn chuẩn để xác minh bộ signing cục bộ. GitHub không cho đọc ngược giá trị Actions Secrets.

## ☁️ Google Drive Backup (mục 10)

Mục 10 hỗ trợ **sao lưu lên Drive** và **khôi phục từ Drive**. Đây là luồng đồng bộ một chiều; restore không tự cập nhật GitHub Secrets.

### 1. Chuẩn bị bộ signing

1. Tạo hoặc giữ nguyên keystore đang sử dụng để phát hành ứng dụng.
2. Mở `apksign` → chọn **9. Đồng bộ 4 GitHub Secrets**.
3. Nhập đúng store password và key password.
4. Chờ mục 9 xác minh thành công và lưu credentials riêng tư tại `~/.apksign/credentials/`.

Mục 10 cần bộ signing đã được xác minh ở mục 9. Nếu chưa chạy mục 9, backup sẽ dừng và yêu cầu thực hiện trước.

### 2. Cấu hình rclone và Google Drive (chỉ làm một lần)

Cài công cụ:

```sh
pkg update -y
pkg install rclone openssl tar -y
```

Tạo remote:

```sh
rclone config
```

Trong trình cấu hình:

1. Chọn tạo remote mới, đặt tên chính xác là `gdrive`.
2. Chọn backend **Google Drive**.
3. Nếu dùng OAuth Client riêng, tạo OAuth Client ID loại **Desktop app** trong Google Cloud Console; bật **Google Drive API**.
4. Nhập Client ID và Client Secret (có thể để trống để dùng thông tin mặc định của rclone, nếu phù hợp).
5. Chọn scope `drive` để công cụ có thể tạo và quản lý thư mục/file backup.
6. `service_account_file`: để trống, nhấn Enter. Không nhập tên file giả hoặc chuỗi dấu nháy.
7. Advanced config: `n`.
8. Shared Drive: chọn `n` nếu dùng My Drive thông thường.
9. Khi được hỏi dùng trình duyệt để xác thực, chọn `y`, đăng nhập Google và cấp quyền.
10. Lưu cấu hình.

Kiểm tra kết nối:

```sh
rclone lsd gdrive:
```

Nếu rclone báo cổng xác thực `127.0.0.1:53682` đang được sử dụng, kiểm tra các phiên Termux/tmux khác và dừng phiên rclone xác thực bị treo trước khi chạy lại:

```sh
rclone config reconnect gdrive:
```

Nếu trang Google báo `redirect_uri_mismatch`, kiểm tra OAuth Client là **Desktop app** và cấu hình redirect URI theo thông báo của rclone (mặc định `http://127.0.0.1:53682/`).

### 3. Sao lưu lên Google Drive

1. Chạy `apksign`.
2. Chọn **10. Đồng bộ bộ signing đã xác minh lên Google Drive**.
3. Chọn **1. Đồng bộ bộ signing hiện tại lên Google Drive**.
4. Chờ thông báo hoàn tất.

File được tải lên thư mục:

```text
gdrive:apksign-backups/
```

Tên file có dạng:

```text
apksign-backup-YYYYMMDD-HHMMSS.tar.gz.enc
```

Archive chứa:
- Release keystore (`.jks`).
- Keystore Base64.
- File chứa 4 GitHub signing secrets.

Archive được mã hóa bằng **AES-256-CBC + PBKDF2 (300.000 vòng, SHA-256)**. Mật khẩu mã hóa là **signing store password** của keystore, không phải mật khẩu Google hoặc mật khẩu cấu hình rclone.

### 4. Khôi phục từ Google Drive

1. Đảm bảo remote `gdrive` hoạt động.
2. Chạy `apksign` → mục **10**.
3. Chọn **2. Khôi phục bản backup từ Google Drive**.
4. Chọn đúng tên file backup.
5. Nhập signing store password dùng khi tạo archive.
6. Chờ giải mã và kiểm tra.

Nếu đã có keystore tại máy, script tạo bản sao dự phòng trước khi thay thế. Keystore và Base64 được khôi phục vào `~/.apksign/`; file secrets được lưu riêng tại `~/.apksign/backup-secrets.env`. **Restore không tự ghi các secrets lên GitHub** để tránh ghi đè nhầm. Chỉ dùng file secrets khi thực sự cần và không chia sẻ nội dung file này.

### Thông báo tác vụ

- Hiển thị trạng thái kiểm tra kết nối, mã hóa, tải lên, tải xuống, giải mã và khôi phục.
- Giữ kết quả tác vụ trên màn hình đến khi nhấn Enter.
- Có thể cài `termux-api` và ứng dụng Termux:API để nhận thông báo Android; nếu không cài, trạng thái vẫn hiển thị trong terminal.

## 🔐 Bảo mật

Không commit hoặc chia sẻ công khai:
- `*.jks`, `*.keystore`, `*.p12`, `*.pfx`, `*.pem`, `*.key`.
- `*.base64`, `keystore.properties`.
- `~/.apksign/credentials/`, `backup-secrets.env`, archive backup và mật khẩu.

Thư mục credentials được giới hạn quyền truy cập trên thiết bị. Signing store password cũng là mật khẩu giải mã archive; nếu mất mật khẩu này, không thể giải mã bản backup. Nên giữ thêm một bản backup ngoại tuyến ở nơi an toàn.

## 🤖 Tự động áp dụng cho Android repository

Workflow trung tâm tại `.github/workflows/sync-android-signing.yml` định kỳ quét repository thuộc tài khoản `khahdihdz`, nhận diện dự án Android có Gradle Wrapper, đồng bộ 4 signing secrets và bổ sung workflow signing dùng chung khi phù hợp.

Trong repository `khahdihdz/apksign`, cấu hình Actions Secrets:

- `APKSIGN_SYNC_TOKEN`: GitHub token có quyền cần thiết để đọc repository và cập nhật Contents/Actions secrets ở các repository mục tiêu.
- `ANDROID_SIGNING_KEYSTORE_BASE64`
- `ANDROID_SIGNING_STORE_PASSWORD`
- `ANDROID_SIGNING_KEY_ALIAS`
- `ANDROID_SIGNING_KEY_PASSWORD`

Chạy **Actions → Sync Android signing to all repositories → Run workflow** để đồng bộ thủ công; workflow cũng hỗ trợ chạy theo lịch. Cơ chế không ghi đè workflow release Android hiện có.

## 📂 Dữ liệu cục bộ

```text
~/.apksign/
├── khahdihdz-release.jks
├── keystore.base64
├── credentials/
│   ├── store-password
│   ├── key-password
│   └── key-alias
└── backup-secrets.env       (chỉ xuất hiện sau restore)
```

## 🌐 Landing Page

**https://khahdihdz.github.io/apksign/**

Trang giới thiệu, hướng dẫn cài đặt, GitHub Actions và Google Drive Backup.

## 📄 Giấy phép

Phát hành theo giấy phép **MIT**.

## 👤 Tác giả

**khahdihdz** · [GitHub Repository](https://github.com/khahdihdz/apksign)
