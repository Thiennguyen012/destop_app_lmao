# Hướng Dẫn Chi Tiết Cài Đặt Flutter Trên Windows

## 📝 Mục Lục

1. [Yêu Cầu Hệ Thống](#yêu-cầu-hệ-thống)
2. [Cài Đặt Flutter](#cài-đặt-flutter)
3. [Cài Đặt Android Studio](#cài-đặt-android-studio)
4. [Xử Lý Sự Cố](#xử-lý-sự-cố)
5. [Chạy Ứng Dụng](#chạy-ứng-dụng)

---

## Yêu Cầu Hệ Thống

```
OS: Windows 7 SP1 hoặc mới hơn
Disk: 5GB trống (khuyên 10GB)
RAM: 4GB tối thiểu (8GB khuyên)
CPU: 64-bit processor
```

---

## Cài Đặt Flutter

### Cách 1: Tự động bằng PowerShell (Khuyên dùng)

Mở **PowerShell** và chạy:

```powershell
# 1. Tạo thư mục
mkdir "C:\flutter"
cd "C:\flutter"

# 2. Tải Flutter
Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip" `
  -OutFile "flutter.zip" `
  -UseBasicParsing

# 3. Giải nén
Expand-Archive "flutter.zip" -DestinationPath "." -Force

# 4. Xóa file zip
Remove-Item "flutter.zip"

# 5. Thêm vào PATH
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\flutter\bin", "User")

# 6. Khởi động lại PowerShell
Write-Host "Vui lòng khởi động lại PowerShell" -ForegroundColor Green
```

### Cách 2: Thủ công

1. **Tải Flutter**

   - Truy cập: https://flutter.dev/docs/get-started/install/windows
   - Tải file ZIP

2. **Giải nén**

   - Tạo thư mục `C:\flutter`
   - Giải nén file ZIP vào đó

3. **Thêm vào PATH**

   - Nhấn `Windows + X` → "System"
   - "Advanced system settings"
   - "Environment Variables"
   - Biến "Path" → "Edit"
   - "New" → Thêm `C:\flutter\bin`

4. **Khởi động lại Terminal**

---

## Cài Đặt Android Studio

### Tải Android Studio

1. Truy cập: https://developer.android.com/studio
2. Tải file `.exe` (phiên bản Windows)
3. Chạy file `.exe`

### Cài Đặt

1. **Chọn components:**

   ```
   [✓] Android Studio
   [✓] Android SDK
   [✓] Android Virtual Device
   ```

2. **Cấu hình SDK:**

   - Chọn đường dẫn install (mặc định OK)
   - Chọn "Standard" (includes needed components)
   - Nhấn "Next" cho hết

3. **Chờ cài đặt**

   - Có thể mất 5-10 phút
   - Cần Internet tốt

4. **Hoàn thành Setup**
   - Mở Android Studio
   - Chờ tải components lần đầu
   - Đóng khi done

### Tạo Virtual Device (Emulator)

1. **Mở Android Studio**
2. Nhấn "Device Manager" (bên phải)
3. Nhấn "Create device"
4. Chọn device (Pixel 4, Pixel 5, v.v.)
5. Chọn API level (API 31+ khuyên)
6. Nhấn "Finish"

### Khởi Động Emulator

- Mở Device Manager
- Tìm device
- Nhấn nút Play (▶️)
- Chờ emulator khởi động

---

## Chuẩn Bị Dự Án

### 1. Kiểm Tra Cài Đặt

```powershell
flutter doctor
```

**Kết quả mong đợi:**

```
✓ Flutter
✓ Android toolchain
✓ Android Studio
✓ VS Code
✓ Devices (hoặc emulator)
```

Có thể có `[!]` cho VS Code, không sao.

### 2. Chấp Nhận Licenses

```powershell
flutter doctor --android-licenses
```

Gõ `y` để chấp nhận tất cả.

### 3. Tải Dependencies

```powershell
cd D:\flutter\QLNV
flutter pub get
```

Chờ tải xong (1-2 phút).

---

## Chạy Ứng Dụng

### Option 1: Windows Desktop (Nhanh nhất ⚡)

```powershell
cd D:\flutter\QLNV
flutter run -d windows
```

**Lợi:**

- Nhanh
- Không cần emulator
- Gần giống desktop app thật

**Nhược:**

- Chỉ chạy trên Windows

### Option 2: Android Emulator

```powershell
cd D:\flutter\QLNV
flutter run
```

**Chuẩn bị:**

1. Mở Android Studio
2. Device Manager → Khởi động emulator
3. Chờ emulator khởi động

**Lợi:**

- Giống thiệt
- Cross-platform

**Nhược:**

- Chậm hơn
- Cần emulator chạy

### Option 3: Android Physical Device

```powershell
cd D:\flutter\QLNV
flutter run
```

**Chuẩn bị:**

1. Bật "USB Debugging" trên điện thoại
2. Kết nối qua USB
3. Chạy lệnh

**Lợi:**

- Thật nhất
- Nhanh

**Nhược:**

- Cần điện thoại Android

### Option 4: Web (Chrome)

```powershell
cd D:\flutter\QLNV
flutter run -d chrome
```

**Lợi:**

- Dễ

**Nhược:**

- Không giống app mobile

---

## Xử Lý Sự Cố

### ❌ "Flutter is not recognized"

**Nguyên nhân:** PATH chưa được cập nhật

**Giải pháp:**

```powershell
# Khởi động lại PowerShell (rất quan trọng!)
# Kiểm tra PATH
echo $env:Path

# Nếu vẫn không có, thêm thủ công:
$env:Path = "$env:Path;C:\flutter\bin"
flutter --version
```

### ❌ "Android SDK not found"

**Nguyên nhân:** Android Studio chưa cài hoặc chưa cấu hình

**Giải pháp:**

```powershell
# Chạy doctor để xem chi tiết
flutter doctor -v

# Cài đặt Android Studio
# https://developer.android.com/studio
```

### ❌ "No Android licenses"

**Giải pháp:**

```powershell
flutter doctor --android-licenses
# Gõ 'y' cho tất cả
```

### ❌ "Gradle build failed"

**Giải pháp:**

```powershell
cd D:\flutter\QLNV
flutter clean
flutter pub get
flutter run
```

### ❌ "No emulator found"

**Giải pháp:**

1. Mở Android Studio
2. Tools → Device Manager
3. Create Virtual Device
4. Chạy emulator

### ❌ "Permission denied"

**Giải pháp:**

1. Mở PowerShell **As Administrator**
2. Chạy lại lệnh

### ❌ "Out of memory"

**Giải pháp:**

- Tăng RAM cho emulator
- Dùng physical device thay vì emulator
- Dùng Windows desktop build

---

## Sử Dụng Hot Reload

Khi chạy `flutter run`, có thể:

```
r - Hot reload (cập nhật code mà không restart)
R - Hot restart (restart toàn app)
h - Hiển thị help
q - Quit/Thoát
```

**Hot Reload rất hữu ích cho phát triển!**

---

## Những Lệnh Hữu Ích

```powershell
# Kiểm tra cài đặt
flutter doctor -v

# Xem device/emulator
flutter devices

# Tải dependencies
flutter pub get

# Cập nhật dependencies
flutter pub upgrade

# Chạy app
flutter run

# Chạy trên platform cụ thể
flutter run -d windows      # Windows
flutter run -d chrome       # Web
flutter run                 # Android

# Xây dựng APK (Android)
flutter build apk

# Xây dựng EXE (Windows)
flutter build windows

# Dọn dẹp
flutter clean

# Format code
flutter format lib/

# Analyz code
flutter analyze
```

---

## Cấu Hình Thêm

### VS Code (Tùy chọn)

1. Tải: https://code.visualstudio.com
2. Cài đặt extensions:
   - Flutter
   - Dart

### Git (Tùy chọn)

1. Tải: https://git-scm.com/download/win
2. Dùng cho version control

---

## 🎉 Hoàn Thành!

Khi ứng dụng chạy, bạn sẽ thấy:

- Trang Chủ: Hiển thị tổng thu/chi
- Danh Sách Giao Dịch
- Báo Cáo Tháng
- Nút Thêm Giao Dịch

**Enjoy!** 🚀

---

## 📞 Hỗ Trợ

- Flutter Docs: https://flutter.dev/docs
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter
- GitHub Issues: https://github.com/flutter/flutter/issues
