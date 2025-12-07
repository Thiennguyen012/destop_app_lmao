#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Script tự động cài đặt Flutter, Android Studio và chạy ứng dụng
.DESCRIPTION
    Script này giúp tự động hóa quá trình cài đặt Flutter và chạy ứng dụng quản lý tài chính
.EXAMPLE
    .\setup.ps1
#>

param(
    [ValidateSet("doctor", "setup", "run-windows", "run-android", "run-web", "clean")]
    [string]$Command = "doctor"
)

function Write-Header {
    param([string]$Text)
    Write-Host "`n$('='*60)" -ForegroundColor Cyan
    Write-Host $Text -ForegroundColor Cyan
    Write-Host "$('='*60)`n" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Text)
    Write-Host "✓ $Text" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Text)
    Write-Host "✗ $Text" -ForegroundColor Red
}

function Write-Info {
    param([string]$Text)
    Write-Host "ℹ $Text" -ForegroundColor Yellow
}

# Kiểm tra xem Flutter đã cài đặt chưa
function Test-FlutterInstalled {
    try {
        $output = flutter --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Flutter đã cài đặt: $($output[0])"
            return $true
        }
    }
    catch {
        return $false
    }
    return $false
}

# Doctor - Kiểm tra cài đặt
function Invoke-Doctor {
    Write-Header "Kiểm Tra Cài Đặt Flutter"
    
    if (Test-FlutterInstalled) {
        flutter doctor -v
    }
    else {
        Write-Error-Custom "Flutter chưa được cài đặt hoặc không trong PATH"
        Write-Info "Vui lòng cài đặt Flutter trước: https://flutter.dev/docs/get-started/install/windows"
    }
}

# Setup - Chuẩn bị dự án
function Invoke-Setup {
    Write-Header "Chuẩn Bị Dự Án"
    
    if (-not (Test-FlutterInstalled)) {
        Write-Error-Custom "Flutter chưa được cài đặt!"
        exit 1
    }
    
    Write-Info "Tải dependencies..."
    flutter pub get
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Dependencies đã được tải"
    }
    else {
        Write-Error-Custom "Lỗi khi tải dependencies"
        exit 1
    }
    
    Write-Info "Chấp nhận Android licenses..."
    flutter doctor --android-licenses
    
    Write-Success "Chuẩn bị xong! Bạn có thể chạy: .\setup.ps1 run-windows"
}

# Run-Windows - Chạy trên Desktop Windows
function Invoke-RunWindows {
    Write-Header "Chạy Ứng Dụng - Windows Desktop"
    
    if (-not (Test-FlutterInstalled)) {
        Write-Error-Custom "Flutter chưa được cài đặt!"
        exit 1
    }
    
    Write-Info "Khởi động ứng dụng (lần đầu có thể mất 2-3 phút)..."
    flutter run -d windows
}

# Run-Android - Chạy trên Android
function Invoke-RunAndroid {
    Write-Header "Chạy Ứng Dụng - Android"
    
    if (-not (Test-FlutterInstalled)) {
        Write-Error-Custom "Flutter chưa được cài đặt!"
        exit 1
    }
    
    Write-Info "Kiểm tra device..."
    flutter devices
    
    Write-Info "Khởi động ứng dụng..."
    flutter run
}

# Run-Web - Chạy trên Web (Chrome)
function Invoke-RunWeb {
    Write-Header "Chạy Ứng Dụng - Web (Chrome)"
    
    if (-not (Test-FlutterInstalled)) {
        Write-Error-Custom "Flutter chưa được cài đặt!"
        exit 1
    }
    
    Write-Info "Khởi động ứng dụng trong Chrome..."
    flutter run -d chrome
}

# Clean - Dọn dẹp dự án
function Invoke-Clean {
    Write-Header "Dọn Dẹp Dự Án"
    
    if (-not (Test-FlutterInstalled)) {
        Write-Error-Custom "Flutter chưa được cài đặt!"
        exit 1
    }
    
    Write-Info "Đang xóa build files..."
    flutter clean
    
    Write-Info "Đang tải lại dependencies..."
    flutter pub get
    
    Write-Success "Dọn dẹp xong!"
}

# Main
Write-Host "`n" -ForegroundColor Cyan
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Ứng Dụng Quản Lý Tài Chính - Flutter Setup Script     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

switch ($Command) {
    "doctor" { Invoke-Doctor }
    "setup" { Invoke-Setup }
    "run-windows" { Invoke-RunWindows }
    "run-android" { Invoke-RunAndroid }
    "run-web" { Invoke-RunWeb }
    "clean" { Invoke-Clean }
    default {
        Write-Header "Hướng Dẫn Sử Dụng"
        Write-Host "Các lệnh có sẵn:`n" -ForegroundColor Yellow
        Write-Host "  .\setup.ps1 doctor          - Kiểm tra cài đặt Flutter" -ForegroundColor White
        Write-Host "  .\setup.ps1 setup           - Chuẩn bị dự án (lần đầu)" -ForegroundColor White
        Write-Host "  .\setup.ps1 run-windows     - Chạy trên Windows Desktop" -ForegroundColor White
        Write-Host "  .\setup.ps1 run-android     - Chạy trên Android Emulator" -ForegroundColor White
        Write-Host "  .\setup.ps1 run-web         - Chạy trên Chrome" -ForegroundColor White
        Write-Host "  .\setup.ps1 clean           - Dọn dẹp và chuẩn bị lại`n" -ForegroundColor White
        
        Write-Host "Ví dụ: .\setup.ps1 run-windows`n" -ForegroundColor Green
    }
}
