@echo off
REM ===============================================
REM Ứng Dụng Quản Lý Tài Chính - Setup Script
REM ===============================================

setlocal enabledelayedexpansion

REM Kiểm tra tham số
if "%1"=="" (
    call :show_help
    exit /b 0
)

if /i "%1"=="doctor" (
    call :check_flutter
    exit /b 0
)

if /i "%1"=="setup" (
    call :setup_project
    exit /b 0
)

if /i "%1"=="run-windows" (
    call :run_windows
    exit /b 0
)

if /i "%1"=="run-android" (
    call :run_android
    exit /b 0
)

if /i "%1"=="run-web" (
    call :run_web
    exit /b 0
)

if /i "%1"=="clean" (
    call :clean_project
    exit /b 0
)

call :show_help
exit /b 0

REM ===============================================
REM Hàm: Kiểm tra Flutter
REM ===============================================
:check_flutter
echo.
echo ===============================================
echo Kiểm Tra Cài Đặt Flutter
echo ===============================================
echo.
flutter doctor -v
exit /b 0

REM ===============================================
REM Hàm: Chuẩn bị dự án
REM ===============================================
:setup_project
echo.
echo ===============================================
echo Chuẩn Bị Dự Án
echo ===============================================
echo.

flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [x] Flutter chưa được cài đặt!
    echo Vui lòng cài đặt Flutter: https://flutter.dev/docs/get-started/install/windows
    exit /b 1
)

echo [+] Tải dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo [x] Lỗi khi tải dependencies
    exit /b 1
)

echo [+] Chấp nhận Android licenses...
echo y | flutter doctor --android-licenses >nul 2>&1

echo [✓] Chuẩn bị xong!
echo.
echo Bạn có thể chạy:
echo   setup.bat run-windows  - Chạy trên Windows Desktop
echo   setup.bat run-android  - Chạy trên Android
echo   setup.bat run-web      - Chạy trên Web (Chrome)
echo.
exit /b 0

REM ===============================================
REM Hàm: Chạy trên Windows Desktop
REM ===============================================
:run_windows
echo.
echo ===============================================
echo Chạy Ứng Dụng - Windows Desktop
echo ===============================================
echo.

flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [x] Flutter chưa được cài đặt!
    exit /b 1
)

echo [+] Khởi động ứng dụng (lần đầu có thể mất 2-3 phút)...
call flutter run -d windows
exit /b %errorlevel%

REM ===============================================
REM Hàm: Chạy trên Android
REM ===============================================
:run_android
echo.
echo ===============================================
echo Chạy Ứng Dụng - Android
echo ===============================================
echo.

flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [x] Flutter chưa được cài đặt!
    exit /b 1
)

echo [+] Kiểm tra device...
call flutter devices

echo.
echo [+] Khởi động ứng dụng...
call flutter run
exit /b %errorlevel%

REM ===============================================
REM Hàm: Chạy trên Web
REM ===============================================
:run_web
echo.
echo ===============================================
echo Chạy Ứng Dụng - Web (Chrome)
echo ===============================================
echo.

flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [x] Flutter chưa được cài đặt!
    exit /b 1
)

echo [+] Khởi động ứng dụng trong Chrome...
call flutter run -d chrome
exit /b %errorlevel%

REM ===============================================
REM Hàm: Dọn dẹp dự án
REM ===============================================
:clean_project
echo.
echo ===============================================
echo Dọn Dẹp Dự Án
echo ===============================================
echo.

flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [x] Flutter chưa được cài đặt!
    exit /b 1
)

echo [+] Đang xóa build files...
call flutter clean

echo [+] Đang tải lại dependencies...
call flutter pub get

echo [✓] Dọn dẹp xong!
echo.
exit /b 0

REM ===============================================
REM Hàm: Hiển thị hướng dẫn
REM ===============================================
:show_help
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║     Ứng Dụng Quản Lý Tài Chính - Flutter Setup Script     ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo Các lệnh có sẵn:
echo.
echo   setup.bat doctor          - Kiểm tra cài đặt Flutter
echo   setup.bat setup           - Chuẩn bị dự án (lần đầu)
echo   setup.bat run-windows     - Chạy trên Windows Desktop
echo   setup.bat run-android     - Chạy trên Android Emulator
echo   setup.bat run-web         - Chạy trên Chrome
echo   setup.bat clean           - Dọn dẹp và chuẩn bị lại
echo.
echo Ví dụ: setup.bat run-windows
echo.
exit /b 0
