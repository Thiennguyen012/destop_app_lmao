# Hướng Dẫn Cài Đặt Flutter & Chạy Ứng Dụng - Từ Con Số 0

## 📋 Yêu Cầu Hệ Thống

- **OS**: Windows 10/11
- **Disk**: Tối thiểu 5GB trống
- **RAM**: Tối thiểu 4GB (8GB khuyên cáo)
- **Git** (tùy chọn nhưng khuyên dùng)

## 🚀 Bước 1: Cài Đặt Git (Tùy Chọn Nhưng Khuyên Dùng)

1. Truy cập https://git-scm.com/download/win
2. Tải xuống Git for Windows
3. Chạy file cài đặt và làm theo hướng dẫn (nhấn "Next" liên tục)

## 🔧 Bước 2: Cài Đặt Android Studio (Bắt Buộc)

### Tại Sao Cần Android Studio?

- Cung cấp Android SDK (bắt buộc cho Flutter)
- Cung cấp các công cụ phát triển

### Cài Đặt:

1. **Tải Android Studio**

   - Truy cập https://developer.android.com/studio
   - Nhấn "Download Android Studio"
   - Tải xuống phiên bản Windows

2. **Cài Đặt**

   - Chạy file `.exe`
   - Chọn "Next" cho các bước mặc định
   - Khi được hỏi, chọn "Standard" installation
   - Chờ cài đặt Android SDK (có thể mất 5-10 phút)

3. **Hoàn Thành Setup**
   - Khi mở Android Studio lần đầu, chọn "Don't Import Settings"
   - Chờ nó tải component (có thể mất lâu)

## 🔥 Bước 3: Cài Đặt Flutter SDK

### Tải Flutter:

1. Truy cập https://flutter.dev/docs/get-started/install/windows
2. Nhấn nút "Windows" để tải Flutter SDK zip file
3. Hoặc tải trực tiếp: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip

### Giải Nén:

1. Tạo folder `flutter` ở ổ C:

   ```
   C:\flutter
   ```

2. Giải nén file zip vừa tải xuống vào folder này

3. Sau khi giải nén, đường dẫn sẽ là:
   ```
   C:\flutter\bin\flutter.bat
   ```

### Thêm Flutter Vào System PATH:

1. **Mở Environment Variables:**

   - Nhấn `Windows + X`
   - Chọn "System"
   - Nhấn "Advanced system settings"
   - Nhấn "Environment Variables" (phía dưới)

2. **Thêm PATH:**

   - Phần "System variables" → Tìm biến "Path"
   - Nhấn "Edit"
   - Nhấn "New"
   - Thêm: `C:\flutter\bin`
   - Nhấn OK, OK, OK

3. **Khởi động lại Terminal:**
   - Đóng tất cả Terminal/PowerShell
   - Mở PowerShell mới để lấy PATH cập nhật

## ✅ Bước 4: Kiểm Tra Cài Đặt

Mở **PowerShell** (hoặc Command Prompt) và chạy:

```powershell
flutter doctor
```

### Kết Quả Mong Đợi:

```
[✓] Flutter (Channel stable, 3.16.0, on Microsoft Windows [Version 10.0.xxxx])
[✓] Android toolchain
[✓] Windows (developer tools are available)
```

Nếu có dấu `[!]` hoặc `[✗]`, hãy làm theo hướng dẫn để khắc phục.

### Chấp Nhận Licenses:

```powershell
flutter doctor --android-licenses
```

Gõ `y` để chấp nhận tất cả licenses.

## 📂 Bước 5: Chuẩn Bị Dự Án

Dự án đã được tạo sẵn tại: `D:\flutter\QLNV`

### Tải Dependencies:

```powershell
cd D:\flutter\QLNV
flutter pub get
```

Chờ khoảng 1-2 phút để tải hết tất cả packages.

## 🎮 Bước 6: Chạy Ứng Dụng

### Option A: Trên Android Emulator

1. **Mở Android Studio**
2. Nhấn "Device Manager" (bên phải)
3. Nhấn "Create device" nếu chưa có
4. Chọn "Pixel 4" hoặc device nào cũng được
5. Nhấn Play để khởi động emulator
6. Chờ emulator khởi động (có thể mất 2-3 phút)

7. **Chạy ứng dụng trong PowerShell:**

```powershell
cd D:\flutter\QLNV
flutter run
```

### Option B: Trên Desktop (Windows)

```powershell
cd D:\flutter\QLNV
flutter run -d windows
```

**Lưu ý:** Lần đầu sẽ mất thời gian compile (~2-3 phút)

### Option C: Trên Web (Chrome)

```powershell
cd D:\flutter\QLNV
flutter run -d chrome
```

## 🛠️ Xử Lý Sự Cố Thường Gặp

### "Flutter is not recognized"

**Nguyên nhân:** PATH chưa được cập nhật

**Giải pháp:**

1. Đóng tất cả PowerShell
2. Mở PowerShell mới
3. Thử lại `flutter doctor`

### "No Android licenses"

**Giải pháp:**

```powershell
flutter doctor --android-licenses
```

Gõ `y` cho tất cả

### "No emulator/device found"

**Giải pháp 1:** Khởi động emulator

- Mở Android Studio → Device Manager → Chọn device → Nhấn Play

**Giải pháp 2:** Kết nối điện thoại Android

- Bật USB Debugging trên điện thoại
- Kết nối qua USB
- Gõ: `flutter devices` để kiểm tra

### "Gradle build failed"

**Giải pháp:**

```powershell
cd D:\flutter\QLNV
flutter clean
flutter pub get
flutter run
```

### Lỗi "Permission denied" trên Windows

**Giải pháp:**

1. Mở PowerShell **As Administrator**
2. Chạy lại các lệnh flutter

## 📝 Các Lệnh Hữu Ích

```powershell
# Kiểm tra setup
flutter doctor

# Xem danh sách device
flutter devices

# Tải dependencies
flutter pub get

# Clean project
flutter clean

# Chạy app
flutter run

# Chạy với debug chi tiết
flutter run -v

# Chạy trên platform cụ thể
flutter run -d windows
flutter run -d chrome
```

## 🎯 Bước 7: Sử Dụng Ứng Dụng

Khi ứng dụng chạy:

1. **Trang Chủ**: Xem tổng thu nhập, chi tiêu, số dư
2. **Danh Sách Giao Dịch**: Xem tất cả giao dịch
3. **Báo Cáo**: Xem báo cáo theo tháng
4. **Thêm Giao Dịch**: Nhấn nút "+" để thêm giao dịch mới

## 🎨 Desktop vs Mobile

**Trên Desktop (Windows):**

- Sidebar bên trái để chuyển đổi màn hình
- Nút "Thêm Giao Dịch" trong sidebar

**Trên Mobile (Android):**

- Bottom navigation bar
- Nút "+" floating action button

## 🔄 Hot Reload (Rất Tiện Lợi!)

Khi chạy `flutter run`, bạn có thể:

- Gõ `r` để hot reload (cập nhật code mà không khởi động lại app)
- Gõ `R` để hot restart (khởi động lại app)
- Gõ `q` để thoát

## 💡 Tips & Tricks

1. **Nhanh nhất:** Chạy trên Windows desktop

   ```
   flutter run -d windows
   ```

2. **Tương thích nhất:** Chạy trên Chrome

   ```
   flutter run -d chrome
   ```

3. **Giống thiệt:** Chạy trên Android emulator
   ```
   flutter run
   ```

## 🐛 Nếu Vẫn Có Lỗi

1. Chạy lại `flutter doctor -v` để xem chi tiết
2. Google search error message
3. Xem FAQ trên https://flutter.dev/docs/resources/faq

## ✨ Hoàn Thành!

Sau khi theo hết các bước này, bạn sẽ có:
✅ Flutter SDK cài đặt
✅ Android Studio cài đặt
✅ Dự án sẵn sàng chạy
✅ Ứng dụng quản lý tài chính hoạt động

## 📞 Hỗ Trợ

Nếu gặp vấn đề:

1. Kiểm tra `flutter doctor` output
2. Tìm kiếm lỗi trên Google hoặc StackOverflow
3. Xem Flutter Documentation: https://flutter.dev/docs
