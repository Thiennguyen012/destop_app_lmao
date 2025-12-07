# Ứng Dụng Quản Lý Tài Chính Cá Nhân

Ứng dụng Flutter quản lý tài chính cá nhân với cơ sở dữ liệu SQLite.

## 🎯 Tính Năng

- **Quản lý giao dịch**: Thêm, sửa, xóa giao dịch thu nhập và chi tiêu
- **Danh mục linh hoạt**: Hỗ trợ nhiều danh mục tùy chỉnh cho thu nhập và chi tiêu
- **Báo cáo chi tiết**: Xem báo cáo tài chính theo tháng
- **Thống kê tổng hợp**: Hiển thị tổng thu nhập, chi tiêu và số dư
- **Dữ liệu cục bộ**: Lưu trữ dữ liệu an toàn trên thiết bị bằng SQLite
- **Giao diện thân thiện**: Giao diện Material Design 3 dễ sử dụng

## 📋 Yêu Cầu

- Flutter SDK >= 3.0.0
- Dart >= 3.0.0

## 🚀 Hướng Dẫn Cài Đặt

### 1. Clone hoặc tạo project

```bash
cd d:\flutter\QLNV
```

### 2. Cài đặt dependencies

```bash
flutter pub get
```

### 3. Chạy ứng dụng

```bash
flutter run
```

## 📁 Cấu Trúc Project

```
lib/
├── database/           # Tầng quản lý cơ sở dữ liệu
│   └── database_helper.dart
├── models/             # Các model dữ liệu
│   ├── transaction.dart
│   ├── category.dart
│   └── wallet.dart
├── repositories/       # Repository pattern cho dữ liệu
│   ├── transaction_repository.dart
│   ├── category_repository.dart
│   └── wallet_repository.dart
├── screens/            # Các màn hình chính
│   ├── home_screen.dart
│   ├── add_transaction_screen.dart
│   ├── report_screen.dart
│   └── transaction_list_screen.dart
├── widgets/            # Widget tái sử dụng
│   ├── transaction_card.dart
│   └── summary_card.dart
├── utils/              # Các hàm tiện ích
│   └── app_utils.dart
└── main.dart           # Entry point
```

## 🎮 Hướng Dẫn Sử Dụng

### Trang Chủ

- Xem tổng thu nhập, chi tiêu và số dư
- Xem 10 giao dịch gần nhất
- Làm mới dữ liệu bằng cách kéo từ trên xuống

### Thêm Giao Dịch

1. Nhấn nút "+" ở góc dưới bên phải
2. Chọn loại giao dịch (Thu nhập / Chi tiêu)
3. Nhập tiêu đề và số tiền
4. Chọn danh mục
5. Chọn ngày giao dịch
6. Thêm ghi chú (tùy chọn)
7. Nhấn "Thêm Giao Dịch"

### Danh Sách Giao Dịch

- Xem tất cả giao dịch
- Lọc theo loại: Tất cả, Thu nhập, Chi tiêu
- Xóa giao dịch: Nhấn giữ lên giao dịch

### Báo Cáo

- Chọn tháng để xem báo cáo chi tiết
- Xem số dư của tháng
- Xem danh sách giao dịch trong tháng

## 💾 Dữ Liệu

### Các bảng trong SQLite

**wallets** - Ví tiền

- id: Mã định danh
- name: Tên ví
- balance: Số dư
- currency: Loại tiền tệ
- createdAt: Ngày tạo

**categories** - Danh mục

- id: Mã định danh
- name: Tên danh mục
- type: Loại (income/expense)
- icon: Icon emoji

**transactions** - Giao dịch

- id: Mã định danh
- title: Tiêu đề
- amount: Số tiền
- category: Danh mục
- type: Loại (income/expense)
- date: Ngày giao dịch
- description: Ghi chú

## 🔧 Công Nghệ Sử Dụng

- **Flutter**: Framework phát triển ứng dụng
- **SQLite**: Cơ sở dữ liệu cục bộ
- **sqflite**: Package Flutter cho SQLite
- **intl**: Hỗ trợ đa ngôn ngữ và định dạng ngày giờ
- **provider**: State management (sẵn sàng để mở rộng)

## 📝 Danh Mục Mặc Định

### Thu Nhập

- 💼 Lương
- 🎁 Thưởng
- 📈 Đầu tư

### Chi Tiêu

- 🍔 Ăn uống
- 🛍️ Mua sắm
- 🚗 Giao thông
- 💡 Điện nước
- 📚 Giáo dục
- 🏥 Y tế
- 🎮 Giải trí

## 🚀 Tính Năng Cần Phát Triển

- [ ] Tính năng ví tiền (wallet)
- [ ] Biểu đồ thống kê
- [ ] Export dữ liệu (CSV, PDF)
- [ ] Dự báo chi tiêu
- [ ] Nhật ký chi tiêu chi tiết
- [ ] Sao lưu và phục hục dữ liệu
- [ ] Đồng bộ hóa đám mây

## 📄 Giấy Phép

MIT License

## 👨‍💻 Tác Giả

Phát triển bởi Flutter Developer

## 📞 Hỗ Trợ

Nếu bạn gặp vấn đề, vui lòng báo cáo qua issue hoặc liên hệ với nhà phát triển.
