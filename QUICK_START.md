# Quick Start - Bắt Đầu Nhanh Trong 5 Phút

## 🎯 Mục Tiêu

Cài đặt Flutter và chạy ứng dụng quản lý tài chính.

## 📋 Danh Sách Kiểm Tra

### Có sẵn?

- [ ] Windows 10/11
- [ ] 5GB dung lượng trống
- [ ] Internet connection

## ⚡ Cách Nhanh Nhất (3 Bước)

### Bước 1: Cài Đặt Flutter (5 phút)

```powershell
# Mở PowerShell
# Dán các lệnh dưới đây:

# Tạo thư mục
mkdir "C:\flutter"

# Chuyển vào thư mục
cd "C:\flutter"

# Tải Flutter (thay link nếu có phiên bản mới hơn)
Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip" -OutFile "flutter.zip"

# Giải nén
Expand-Archive "flutter.zip" -DestinationPath "." -Force

# Xóa file zip
Remove-Item "flutter.zip"

# Thêm vào PATH (khởi động lại PowerShell sau)
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\flutter\bin", "User")
```

### Bước 2: Cài Đặt Android Studio (10 phút)

1. Truy cập: https://developer.android.com/studio
2. Tải xuống Android Studio
3. Chạy file `.exe` và cài đặt (nhấn Next)
4. Chờ cài đặt Android SDK

### Bước 3: Chạy Ứng Dụng (1 phút)

```powershell
# Khởi động lại PowerShell
# Chuyển vào thư mục dự án
cd D:\flutter\QLNV

# Chuẩn bị dự án (lần đầu)
flutter pub get

# Chạy ứng dụng
# Option 1: Windows Desktop (nhanh nhất)
flutter run -d windows

# Option 2: Android (cần emulator)
flutter run

# Option 3: Web (Chrome)
flutter run -d chrome
```

## 🐛 Nếu Có Lỗi

### "Flutter is not recognized"

```powershell
# Khởi động lại PowerShell (rất quan trọng!)
# Kiểm tra PATH:
echo $env:Path
```

### "No devices found"

- Mở Android Studio → Device Manager → Tạo & Khởi động emulator

### Lỗi khác

```powershell
# Chạy kiểm tra
flutter doctor -v

# Dọn dẹp và cài lại
flutter clean
flutter pub get
```

## 🚀 Các Lệnh Hữu Ích

```powershell
# Kiểm tra cài đặt
flutter doctor

# Xem device
flutter devices

# Tải dependencies
flutter pub get

# Chạy app
flutter run

# Hot reload (gõ 'r' khi app chạy)
# Hot restart (gõ 'R' khi app chạy)
# Quit (gõ 'q' khi app chạy)
```

## 💡 Bổ Sung

- **Android Emulator**: Cần 4GB RAM + 5GB disk
- **Hot Reload**: Tiết kiệm thời gian phát triển
- **Desktop**: Nhanh nhất cho desktop app

## ✨ Hoàn Thành!

Nếu ứng dụng chạy được, bạn đã thành công! 🎉

---

**Cần chi tiết hơn?** Xem `INSTALL_GUIDE.md`
