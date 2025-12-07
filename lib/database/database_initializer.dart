import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_helper.dart';
import 'database_init_result.dart';

/// Manages database initialization with proper error handling and timing
class DatabaseInitializer {
  /// Convert technical error messages to user-friendly Vietnamese messages
  ///
  /// Maps common error types to localized, actionable error messages:
  /// - DatabaseException -> Database corruption messages
  /// - FileSystemException -> Permission and disk space messages
  /// - Unknown errors -> Generic fallback message
  ///
  /// Returns a user-friendly Vietnamese error message
  static String _localizeErrorMessage(dynamic error, String technicalMessage) {
    if (error is DatabaseException) {
      // Database-specific errors (corruption, schema issues, etc.)
      final errorMsg = error.toString().toLowerCase();

      if (errorMsg.contains('corrupt') || errorMsg.contains('malformed')) {
        return 'Cơ sở dữ liệu bị lỗi hoặc hỏng. Vui lòng thử khởi tạo lại ứng dụng.';
      } else if (errorMsg.contains('readonly') ||
          errorMsg.contains('read-only')) {
        return 'Cơ sở dữ liệu ở chế độ chỉ đọc. Vui lòng kiểm tra quyền truy cập.';
      } else if (errorMsg.contains('locked') || errorMsg.contains('busy')) {
        return 'Cơ sở dữ liệu đang bị khóa. Vui lòng đóng các ứng dụng khác và thử lại.';
      } else {
        return 'Cơ sở dữ liệu bị lỗi. Vui lòng thử lại hoặc khởi tạo lại ứng dụng.';
      }
    } else if (error is FileSystemException) {
      // File system errors (permissions, disk space, etc.)
      final errorMsg = error.toString().toLowerCase();

      if (errorMsg.contains('permission') || errorMsg.contains('denied')) {
        return 'Ứng dụng không có quyền truy cập bộ nhớ. Vui lòng cấp quyền trong cài đặt thiết bị.';
      } else if (errorMsg.contains('space') ||
          errorMsg.contains('full') ||
          errorMsg.contains('quota')) {
        return 'Bộ nhớ thiết bị đã đầy. Vui lòng giải phóng dung lượng và thử lại.';
      } else if (errorMsg.contains('not found') ||
          errorMsg.contains('no such')) {
        return 'Không tìm thấy thư mục lưu trữ. Vui lòng kiểm tra cài đặt ứng dụng.';
      } else {
        return 'Ứng dụng không thể truy cập bộ nhớ. Vui lòng kiểm tra quyền và dung lượng còn trống.';
      }
    } else if (error is IOException) {
      // General I/O errors
      return 'Lỗi đọc/ghi dữ liệu. Vui lòng kiểm tra bộ nhớ thiết bị và thử lại.';
    } else {
      // Unknown/unexpected errors - provide fallback message
      return 'Đã xảy ra lỗi không xác định. Vui lòng thử lại hoặc khởi động lại ứng dụng.';
    }
  }

  /// Initialize the database and return result with timing information
  ///
  /// This method wraps DatabaseHelper initialization in try-catch blocks
  /// to capture any errors and return them in a structured format.
  ///
  /// Returns [DatabaseInitResult] with success status, timing, and error details if any
  static Future<DatabaseInitResult> initialize() async {
    final startTime = DateTime.now();

    try {
      // Call DatabaseHelper to initialize the database
      final dbHelper = DatabaseHelper();
      await dbHelper.database;

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      return DatabaseInitResult.success(duration);
    } on DatabaseException catch (e, stackTrace) {
      // Handle SQLite-specific errors
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      final localizedMessage = _localizeErrorMessage(e, e.toString());
      print('[DatabaseInitializer] DatabaseException: ${e.toString()}');

      return DatabaseInitResult.failure(
        localizedMessage,
        duration,
        stackTrace.toString(),
      );
    } on FileSystemException catch (e, stackTrace) {
      // Handle file system errors (permissions, disk full, etc.)
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      final localizedMessage = _localizeErrorMessage(e, e.toString());
      print('[DatabaseInitializer] FileSystemException: ${e.toString()}');

      return DatabaseInitResult.failure(
        localizedMessage,
        duration,
        stackTrace.toString(),
      );
    } catch (e, stackTrace) {
      // Handle unexpected errors
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      final localizedMessage = _localizeErrorMessage(e, e.toString());
      print('[DatabaseInitializer] Unexpected error: ${e.toString()}');

      return DatabaseInitResult.failure(
        localizedMessage,
        duration,
        stackTrace.toString(),
      );
    }
  }

  /// Verify database integrity by checking if all required tables exist
  ///
  /// Returns true if database is valid and all tables exist, false otherwise
  static Future<bool> verifyDatabase() async {
    try {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      // Check if all required tables exist
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name IN (?, ?, ?)",
        ['wallets', 'categories', 'transactions'],
      );

      // Should have exactly 3 tables
      if (tables.length != 3) {
        print(
            '[DatabaseInitializer] Database verification failed: Expected 3 tables, found ${tables.length}');
        return false;
      }

      // Verify categories table has default data
      final categoryCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM categories'),
      );

      if (categoryCount == null || categoryCount < 10) {
        print(
            '[DatabaseInitializer] Database verification failed: Expected at least 10 categories, found $categoryCount');
        return false;
      }

      print('[DatabaseInitializer] Database verification successful');
      return true;
    } catch (e) {
      print(
          '[DatabaseInitializer] Database verification failed with error: $e');
      return false;
    }
  }

  /// Reset the database by deleting the file
  ///
  /// WARNING: This will delete all user data!
  ///
  /// This method:
  /// 1. Closes the current database connection
  /// 2. Deletes the database file
  ///
  /// Note: Caller is responsible for reinitializing the database after reset
  static Future<void> resetDatabase() async {
    try {
      // Close existing database connection
      final dbHelper = DatabaseHelper();
      await dbHelper.close();

      // Get database path and delete the file
      final dbPath = join(await getDatabasesPath(), 'qlnv.db');
      final dbFile = File(dbPath);

      if (await dbFile.exists()) {
        await dbFile.delete();
        print('[DatabaseInitializer] Database file deleted: $dbPath');
      }

      print('[DatabaseInitializer] Database reset successfully');
    } catch (e, stackTrace) {
      print('[DatabaseInitializer] Failed to reset database: $e');
      print('[DatabaseInitializer] Stack trace: $stackTrace');
      rethrow;
    }
  }
}
