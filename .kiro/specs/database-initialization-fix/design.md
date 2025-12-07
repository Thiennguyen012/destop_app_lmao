# Design Document: Database Initialization Fix

## Overview

This design addresses the critical issue where the SQLite database is not reliably initialized when the Flutter application starts for the first time. The current implementation uses lazy initialization, which can lead to unexpected errors and poor user experience. This design introduces proactive database initialization with proper error handling, logging, and user feedback.

The solution involves:
- Moving database initialization to the app startup sequence in `main()`
- Creating a dedicated initialization screen with loading indicators
- Implementing comprehensive error handling and retry mechanisms
- Adding detailed logging for debugging purposes

## Architecture

### Current Architecture Issues

The current implementation has the following problems:
1. Database is lazily initialized on first access via `DatabaseHelper().database`
2. No explicit initialization in `main()` function
3. Errors during database creation are not caught early
4. No user feedback during initialization
5. No logging for debugging initialization issues

### Proposed Architecture

```
App Startup Flow:
1. main() → WidgetsFlutterBinding.ensureInitialized()
2. main() → DatabaseInitializer.initialize()
   - Create/open database
   - Create tables if needed
   - Insert default categories
   - Log all operations
3. main() → runApp(MyApp)
4. MyApp → Show InitializationScreen (loading)
5. InitializationScreen → Wait for database ready
6. InitializationScreen → Navigate to MainScreen
```

### Component Structure

```
lib/
├── database/
│   ├── database_helper.dart (existing, enhanced)
│   └── database_initializer.dart (new)
├── screens/
│   ├── initialization_screen.dart (new)
│   ├── error_screen.dart (new)
│   └── ... (existing screens)
└── main.dart (modified)
```

## Components and Interfaces

### 1. DatabaseInitializer (New Component)

A new class that manages the database initialization process with proper error handling and logging.

```dart
class DatabaseInitializer {
  static Future<DatabaseInitResult> initialize() async {
    // Returns result with success status, error message, and timing info
  }
  
  static Future<bool> verifyDatabase() async {
    // Verifies database integrity
  }
  
  static Future<void> resetDatabase() async {
    // Deletes and recreates database
  }
}

class DatabaseInitResult {
  final bool success;
  final String? errorMessage;
  final Duration initTime;
  final String? stackTrace;
}
```

### 2. DatabaseHelper (Enhanced)

Enhance the existing `DatabaseHelper` with:
- Detailed logging methods
- Better error messages
- Initialization status tracking

```dart
class DatabaseHelper {
  // Existing singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  
  // New: Initialization status
  bool _isInitialized = false;
  DateTime? _initStartTime;
  DateTime? _initEndTime;
  
  // Enhanced: Add logging
  Future<Database> _initDatabase() async {
    _logInfo('Starting database initialization...');
    _initStartTime = DateTime.now();
    
    try {
      String path = join(await getDatabasesPath(), 'qlnv.db');
      _logInfo('Database path: $path');
      
      final db = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
      
      _initEndTime = DateTime.now();
      _isInitialized = true;
      _logInfo('Database initialized successfully in ${_initEndTime!.difference(_initStartTime!).inMilliseconds}ms');
      
      return db;
    } catch (e, stackTrace) {
      _logError('Database initialization failed', e, stackTrace);
      rethrow;
    }
  }
  
  void _logInfo(String message) {
    print('[DatabaseHelper] $message');
  }
  
  void _logError(String message, dynamic error, StackTrace stackTrace) {
    print('[DatabaseHelper ERROR] $message: $error');
    print('[DatabaseHelper ERROR] Stack trace: $stackTrace');
  }
}
```

### 3. InitializationScreen (New Component)

A screen that displays during app startup while database initializes.

```dart
class InitializationScreen extends StatefulWidget {
  // Shows loading indicator
  // Handles initialization result
  // Navigates to MainScreen or ErrorScreen
}
```

### 4. ErrorScreen (New Component)

A screen that displays when database initialization fails.

```dart
class ErrorScreen extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback? onReset;
  
  // Displays error in Vietnamese
  // Provides retry button
  // Optionally provides reset button
}
```

### 5. Modified main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting
  await initializeDateFormatting('vi_VN', null);
  
  // Initialize database (proactive, not lazy)
  final initResult = await DatabaseInitializer.initialize();
  
  runApp(MyApp(initResult: initResult));
}

class MyApp extends StatelessWidget {
  final DatabaseInitResult initResult;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: initResult.success 
        ? MainScreen() 
        : ErrorScreen(
            errorMessage: initResult.errorMessage!,
            onRetry: () => _retryInitialization(context),
          ),
    );
  }
}
```

## Data Models

No new data models are required. The existing models (Wallet, Category, Transaction) remain unchanged.

### DatabaseInitResult Model

```dart
class DatabaseInitResult {
  final bool success;
  final String? errorMessage;
  final Duration initTime;
  final String? stackTrace;
  
  DatabaseInitResult({
    required this.success,
    this.errorMessage,
    required this.initTime,
    this.stackTrace,
  });
  
  DatabaseInitResult.success(Duration initTime)
      : this(success: true, initTime: initTime);
  
  DatabaseInitResult.failure(String errorMessage, Duration initTime, String? stackTrace)
      : this(
          success: false,
          errorMessage: errorMessage,
          initTime: initTime,
          stackTrace: stackTrace,
        );
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Database initialization before UI

*For any* app startup sequence, the database initialization must complete (successfully or with error) before the main UI is rendered.
**Validates: Requirements 1.1, 1.2**

### Property 2: Initialization idempotence

*For any* database state (existing or non-existing), calling the initialization function multiple times should result in a valid database without data loss or corruption.
**Validates: Requirements 1.4, 1.5**

### Property 3: Error propagation and display

*For any* database initialization failure, the error details (message and stack trace) must be logged AND a user-friendly Vietnamese error message must be displayed to the user.
**Validates: Requirements 1.3, 3.4, 4.1**

### Property 4: Loading screen lifecycle

*For any* database initialization that takes non-zero time, the loading screen must be visible from initialization start until completion or error, then transition to either MainScreen (success) or ErrorScreen (failure).
**Validates: Requirements 2.1, 2.2, 2.3**

### Property 5: Retry mechanism

*For any* failed initialization, when the user taps retry, the application must attempt to reinitialize the database with the same operations in the same order.
**Validates: Requirements 4.2, 4.3**

### Property 6: Log completeness

*For any* database initialization attempt, all major operations (path resolution, table creation, default data insertion, completion/failure) must generate corresponding log entries with timestamps.
**Validates: Requirements 3.1, 3.2, 3.3, 3.5**

### Property 7: Escalated error guidance

*For any* initialization that fails more than 2 consecutive times, the application must provide additional guidance on how to resolve the issue.
**Validates: Requirements 4.4**

## Error Handling

### Error Categories

1. **File System Errors**
   - Cannot access database directory
   - Insufficient permissions
   - Disk full

2. **Database Errors**
   - Corrupted database file
   - Schema migration failures
   - SQL syntax errors

3. **Data Errors**
   - Failed to insert default categories
   - Constraint violations

### Error Handling Strategy

```dart
try {
  // Initialize database
} on DatabaseException catch (e) {
  // Handle SQLite-specific errors
  return DatabaseInitResult.failure(
    'Lỗi cơ sở dữ liệu: ${e.toString()}',
    duration,
    e.stackTrace.toString(),
  );
} on FileSystemException catch (e) {
  // Handle file system errors
  return DatabaseInitResult.failure(
    'Lỗi truy cập file: ${e.toString()}',
    duration,
    e.stackTrace.toString(),
  );
} catch (e, stackTrace) {
  // Handle unexpected errors
  return DatabaseInitResult.failure(
    'Lỗi không xác định: ${e.toString()}',
    duration,
    stackTrace.toString(),
  );
}
```

### User-Facing Error Messages (Vietnamese)

- **Database corruption**: "Cơ sở dữ liệu bị lỗi. Vui lòng thử khởi tạo lại hoặc reset ứng dụng."
- **Permission denied**: "Ứng dụng không có quyền truy cập bộ nhớ. Vui lòng cấp quyền trong cài đặt."
- **Disk full**: "Bộ nhớ thiết bị đã đầy. Vui lòng giải phóng dung lượng và thử lại."
- **Unknown error**: "Đã xảy ra lỗi không xác định. Vui lòng thử lại."

## Testing Strategy

### Unit Tests

Unit tests will verify specific initialization scenarios:

1. **Test database creation on first run**
   - Given: No existing database file
   - When: Initialize database
   - Then: Database file is created with all tables

2. **Test database opening on subsequent runs**
   - Given: Existing valid database file
   - When: Initialize database
   - Then: Database is opened without recreating tables

3. **Test default categories insertion**
   - Given: New database
   - When: Initialize database
   - Then: 10 default categories are inserted

4. **Test error handling for corrupted database**
   - Given: Corrupted database file
   - When: Initialize database
   - Then: Error is caught and returned in result

5. **Test retry mechanism**
   - Given: Failed initialization
   - When: User taps retry
   - Then: Initialization is attempted again

### Property-Based Tests

Property-based tests will verify universal behaviors across many inputs using the `test` package with custom generators:

1. **Property test for initialization idempotence**
   - Generate: Random database states (empty, with data, corrupted)
   - Test: Multiple initializations produce consistent results

2. **Property test for error message consistency**
   - Generate: Various error conditions
   - Test: All errors produce non-null, non-empty error messages

3. **Property test for log completeness**
   - Generate: Different initialization paths (success, failure, retry)
   - Test: All paths generate expected log entries

### Integration Tests

Integration tests will verify end-to-end flows:

1. **Test complete app startup flow**
   - Start app → Initialize database → Show main screen

2. **Test error recovery flow**
   - Start app → Initialization fails → Show error screen → Retry → Success

3. **Test database reset flow**
   - Corrupt database → Show error → Reset → Reinitialize → Success

### Testing Framework

- **Unit tests**: Flutter's built-in `test` package
- **Property-based tests**: Custom generators with `test` package (Dart doesn't have a mature PBT library like QuickCheck, so we'll implement simple property tests)
- **Widget tests**: `flutter_test` package for UI components
- **Integration tests**: `integration_test` package for full app flows

### Test Configuration

- Minimum 100 iterations for property-based tests
- Each property test tagged with: `// Feature: database-initialization-fix, Property X: [description]`
- Tests run in isolated environments with temporary databases
