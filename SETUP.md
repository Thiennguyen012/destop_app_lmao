# Setup Instructions - Ứng Dụng Quản Lý Tài Chính

## 📋 Yêu Cầu Hệ Thống

- **Flutter SDK**: >= 3.0.0
- **Dart**: >= 3.0.0
- **OS**: Windows, macOS, hoặc Linux
- **RAM**: Tối thiểu 4GB

## 🔧 Cài Đặt Flutter

### Windows

1. **Download Flutter SDK**

   - Truy cập https://flutter.dev/docs/get-started/install/windows
   - Tải xuống Flutter SDK (zip file)

2. **Extract và cấu hình PATH**

   ```
   C:\flutter\bin
   ```

   - Thêm đường dẫn này vào System Environment Variables

3. **Xác minh cài đặt**
   ```bash
   flutter doctor
   ```

### macOS / Linux

```bash
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor
```

## 🚀 Khởi Động Project

### 1. Cài đặt Dependencies

```bash
cd d:\flutter\QLNV
flutter pub get
```

### 2. Chạy ứng dụng

**Trên Android**

```bash
flutter run
```

**Trên iOS**

```bash
flutter run
```

**Trên Web**

```bash
flutter run -d chrome
```

## 📱 Chuẩn Bị Thiết Bị

### Android

- Cấu hình Android emulator hoặc kết nối thiết bị vật lý
- Bật USB Debugging nếu dùng thiết bị vật lý

### iOS

- Cần macOS để build cho iOS
- Có thể dùng iOS Simulator hoặc thiết bị vật lý
- Đảm bảo có Apple Developer Account

### Web

- Chrome, Firefox, hoặc Safari
- Không cần cấu hình bổ sung

## 🛠️ Xử Lý Sự Cố

### "Flutter is not recognized"

```bash
# Kiểm tra đường dẫn
flutter --version

# Hoặc chỉ định đường dẫn đầy đủ
"C:\path\to\flutter\bin\flutter" run
```

### "No devices found"

```bash
flutter devices
# Kết nối thiết bị hoặc khởi động emulator
```

### "pub get" fails

```bash
flutter clean
flutter pub get
```

### Lỗi SQLite

```bash
flutter clean
rm pubspec.lock
flutter pub get
```

## 📦 Các Dependencies Chính

```yaml
sqflite: ^2.2.8+4 # SQLite database
path: ^1.8.3 # Path utilities
intl: ^0.19.0 # Internationalization
provider: ^6.1.0 # State management
```

## 🏗️ Kiến Trúc Project

```
lib/
├── database/           # Database operations
├── models/             # Data models
├── repositories/       # Data access layer
├── screens/            # UI screens
├── widgets/            # Reusable widgets
├── utils/              # Utilities
└── main.dart
```

## 💾 Database Schema

Ứng dụng tự động tạo 3 bảng:

- `transactions` - Ghi nhận giao dịch
- `categories` - Danh mục giao dịch
- `wallets` - Quản lý ví tiền

## ✅ Kiểm Tra Cài Đặt

```bash
# Chạy lệnh này để kiểm tra tất cả
flutter doctor -v

# Cần output tương tự:
# ✓ Flutter
# ✓ Android toolchain
# ✓ Xcode (nếu trên macOS)
# ✓ Devices
```

## 🎯 Các Lệnh Hữu Ích

```bash
# Xem tất cả thiết bị có sẵn
flutter devices

# Clean project
flutter clean

# Cập nhật dependencies
flutter pub upgrade

# Build APK (Android)
flutter build apk --release

# Build IPA (iOS)
flutter build ios --release

# Build Web
flutter build web --release

# Chạy với logging
flutter run -v

# Chạy tests
flutter test
```

## 🔍 Debugging

```bash
# Bật debug mode
flutter run

# Các phím tắt trong console:
# h - Hiển thị help
# q - Thoát
# r - Hot reload
# R - Hot restart
# p - Toggle Android profiler
# o - Toggle platform channel performance overlay
# t - Toggle timer-based performance overlay
```

## 📝 Tùy Chỉnh Ứng Dụng

### Thêm Danh Mục Mới

Chỉnh sửa trong `database_helper.dart`:

```dart
{'name': 'Tên Danh Mục', 'type': 'income/expense', 'icon': '🎉'},
```

### Thay Đổi Giao Diện

Chỉnh sửa màu sắc trong `main.dart`:

```dart
primarySwatch: Colors.blue,
```

## 🚢 Triển Khai

### Google Play Store

1. Build release APK: `flutter build apk --release`
2. Đăng ký Google Developer Account
3. Upload APK lên Play Console

### App Store

1. Build release IPA: `flutter build ios --release`
2. Đăng ký Apple Developer Account
3. Upload qua App Store Connect

## 📚 Tài Liệu Tham Khảo

- Flutter Docs: https://flutter.dev/docs
- sqflite: https://pub.dev/packages/sqflite
- Material Design: https://material.io/design
- Dart: https://dart.dev/guides

## ❓ Câu Hỏi Thường Gặp

**Q: Dữ liệu của tôi ở đâu?**
A: Được lưu trữ cục bộ trong SQLite database trên thiết bị

**Q: Có thể sao lưu dữ liệu không?**
A: Hiện tại không. Sẽ được thêm vào phiên bản tương lai

**Q: Ứng dụng có hoạt động offline không?**
A: Có, ứng dụng hoàn toàn hoạt động offline

**Q: Làm sao để xóa tất cả dữ liệu?**
A: Gỡ cài đặt ứng dụng. Hoặc xóa file `.../databases/qlnv.db`

**Q: Có thể sử dụng trên Web không?**
A: Có, chạy: `flutter run -d chrome`

## 🐛 Báo Lỗi

Nếu gặp lỗi, vui lòng cung cấp:

1. Output của `flutter doctor -v`
2. Lỗi đầy đủ từ `flutter run -v`
3. Hệ điều hành và phiên bản
4. Các bước để tái hiện lỗi
