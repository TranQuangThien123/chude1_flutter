# REALTIME CRYPTO MARKET TRACKER (CHUYÊN ĐỀ 02)
> **Môn học**: Lập trình đa nền tảng (Dart & Flutter)  
> **Trường**: Đại học Bách Khoa - Đại học Đà Nẵng  
> **Giảng viên hướng dẫn**: TS. Nguyễn Duy Nhật Viễn  
> **Thành viên thực hiện**:
> - Trần Quang Thiên
> - Nguyễn Đình Hoàn

---

## 1. Yêu cầu hệ thống (Prerequisites)

Trước khi khởi chạy dự án, máy tính cần được cài đặt sẵn:
- **Git**: [Tải Git](https://git-scm.com/downloads) (bản mới nhất).
- **Flutter SDK**: Phiên bản `≥ 3.5.0` (kèm Dart SDK `≥ 3.13.0`) - [Tải Flutter SDK](https://docs.flutter.dev/get-started/install).
- **IDE**: Visual Studio Code (khuyên dùng, cài thêm Extension *Flutter* & *Dart*) hoặc Android Studio.
- **Công cụ build nền tảng**:
  - *Chạy trên Windows Desktop*: Visual Studio 2022 (chọn component **Desktop development with C++**).
  - *Chạy trên Web*: Trình duyệt Google Chrome.
  - *Chạy trên Android*: Android Studio và Android SDK.

---

## 2. Hướng dẫn cấu hình biến môi trường (Environment Variables)

### 2.1. Cấu hình trên hệ điều hành Windows

#### Bước 1: Thêm Flutter SDK vào biến `PATH`
1. Nhấn phím `Windows`, tìm kiếm và mở **Edit the system environment variables** (Chỉnh sửa biến môi trường hệ thống).
2. Nhấn nút **Environment Variables...** (Biến môi trường) ở góc dưới bên phải.
3. Trong mục **User variables** (Biến người dùng) hoặc **System variables** (Biến hệ thống), chọn dòng `Path` và nhấn **Edit...**.
4. Nhấn **New**, dán đường dẫn tới thư mục `bin` của Flutter SDK đã giải nén trên máy của bạn (Ví dụ: `C:\src\flutter\bin` hoặc `D:\flutter\bin`).
5. Nhấn **OK** để lưu lại.

#### Bước 2: Cấu hình Android SDK và Java (Nếu chạy trên Android / Máy ảo)
Trong mục **System variables**, nhấn **New...** để tạo các biến sau:
- **`ANDROID_HOME`**: Đường dẫn tới thư mục Android SDK.
  - Giá trị mẫu: `C:\Users\<Tên_User>\AppData\Local\Android\Sdk`
- **`JAVA_HOME`**: Đường dẫn tới thư mục JDK hoặc JBR của Android Studio.
  - Giá trị mẫu: `C:\Program Files\Android\Android Studio\jbr`

Thêm các đường dẫn công cụ Android vào biến `Path`:
- `%ANDROID_HOME%\platform-tools`
- `%ANDROID_HOME%\cmdline-tools\latest\bin`

---

### 2.2. Cấu hình trên macOS / Linux (Nếu sử dụng macOS/Linux)

Mở terminal và thêm các dòng sau vào file cấu hình shell (`~/.zshrc` hoặc `~/.bashrc`):

```bash
# Đường dẫn Flutter SDK
export PATH="$PATH:/Users/<username>/flutter/bin"

# Android SDK & Java (nếu phát triển Android)
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
```
Sau đó chạy lệnh cập nhật:
```bash
source ~/.zshrc   # Hoặc source ~/.bashrc
```

---

### 2.3. Kiểm tra tính hợp lệ của môi trường

Mở một cửa sổ Terminal / PowerShell mới và chạy lệnh:

```bash
flutter doctor -v
```

Kiểm tra kết quả:
- `[✓] Flutter`: Đã nhận diện đúng phiên bản SDK.
- `[✓] Windows Version / Chrome`: Đã sẵn sàng thiết bị chạy.
- Nếu thiếu giấy phép Android, chạy lệnh sau và nhấn `y` để chấp nhận:
  ```bash
  flutter doctor --android-licenses
  ```

---

## 3. Hướng dẫn cài đặt & Khởi chạy dự án

### Bước 1: Clone mã nguồn từ GitHub
```bash
git clone https://github.com/TranQuangThien123/chude1_flutter.git
cd chude1_flutter
```

### Bước 2: Tải các thư viện phụ thuộc (Dependencies)
```bash
flutter pub get
```

### Bước 3: Kiểm tra tĩnh mã nguồn (Code Analysis)
```bash
flutter analyze
```

### Bước 4: Chạy bộ kiểm thử tự động (Unit Test & Widget Test)
```bash
flutter test
```

### Bước 5: Khởi chạy ứng dụng

- **Khởi chạy trên Windows Desktop**:
  ```bash
  flutter run -d windows
  ```

- **Khởi chạy trên Web (Google Chrome)**:
  ```bash
  flutter run -d chrome
  ```

- **Khởi chạy trên Android (Thiết bị thật hoặc Máy ảo)**:
  ```bash
  flutter run -d android
  ```




