# Flutter Personal Finance Management App

## Project Setup Complete

Ứng dụng quản lý tài chính cá nhân đã được tạo thành công với đầy đủ các tính năng.

## Quick Start Guide

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart (>=3.0.0)
- Android Studio hoặc Xcode (tùy theo nền tảng)

### Installation Steps

1. **Ensure Flutter is installed and configured**

   ```
   flutter doctor
   ```

2. **Get dependencies**

   ```
   flutter pub get
   ```

3. **Build and run**
   ```
   flutter run
   ```

## Project Structure

### Core Components

- **Database Layer**: SQLite management via `sqflite`
- **Models**: Transaction, Category, Wallet
- **Repositories**: CRUD operations for each model
- **UI Screens**: Home, Add Transaction, Reports, Transaction List
- **Utilities**: Formatting and helper functions

### Key Features

✅ Add/Edit/Delete transactions
✅ Income and expense categorization
✅ Monthly reports and statistics
✅ Real-time balance calculation
✅ Local SQLite storage

## Database Schema

Three main tables:

1. **transactions** - Record all financial transactions
2. **categories** - Store transaction categories (income/expense)
3. **wallets** - Track wallet/account balances

## Default Categories

**Income (Thu Nhập)**

- Lương (Salary)
- Thưởng (Bonus)
- Đầu tư (Investment)

**Expenses (Chi Tiêu)**

- Ăn uống (Food)
- Mua sắm (Shopping)
- Giao thông (Transportation)
- Điện nước (Utilities)
- Giáo dục (Education)
- Y tế (Healthcare)
- Giải trí (Entertainment)

## How to Use

### 1. Home Screen

- View total income, expenses, and balance
- See recent transactions (last 10)
- Pull to refresh

### 2. Add Transaction

- Tap the "+" button
- Select transaction type (income/expense)
- Fill in details
- Choose category and date
- Save

### 3. Transaction List

- View all transactions
- Filter by type
- Delete transactions (long press)

### 4. Reports

- Select month to view
- See monthly summary
- View all transactions for selected month

## Localization

App supports Vietnamese locale for:

- Currency formatting (VND)
- Date/time display
- UI text labels

## Future Enhancements

- Wallet management
- Charts and analytics
- Data export (CSV/PDF)
- Cloud sync
- Budget tracking
- Recurring transactions

## Technology Stack

- **Flutter** - UI Framework
- **sqflite** - SQLite integration
- **intl** - Internationalization
- **path** - Path utilities

## Build Instructions

### For Android

```
flutter build apk
```

### For iOS

```
flutter build ios
```

### For Web

```
flutter build web
```

## Notes

- All data is stored locally on the device using SQLite
- No internet connection required for basic functionality
- App supports Material Design 3
