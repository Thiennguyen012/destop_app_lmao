# Implementation Plan

- [x] 1. Enhance DatabaseHelper with logging and status tracking





  - Add initialization status flags (_isInitialized, _initStartTime, _initEndTime)
  - Implement _logInfo() and _logError() methods for consistent logging
  - Add logging to _initDatabase() method for path, timing, and errors
  - Add logging to _onCreate() method for table creation events
  - Add logging to _insertDefaultCategories() for category insertion count
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 1.1 Write property test for logging completeness




  - **Property 6: Log completeness**
  - **Validates: Requirements 3.1, 3.2, 3.3, 3.5**

- [x] 2. Create DatabaseInitResult model





  - Create lib/database/database_init_result.dart file
  - Implement DatabaseInitResult class with success, errorMessage, initTime, and stackTrace fields
  - Add factory constructors for success and failure cases
  - _Requirements: 1.3, 3.4_

- [x] 3. Create DatabaseInitializer class





  - Create lib/database/database_initializer.dart file
  - Implement initialize() method that calls DatabaseHelper and wraps in try-catch
  - Capture timing information (start time, end time, duration)
  - Return DatabaseInitResult with appropriate success/failure status
  - Implement verifyDatabase() method to check database integrity
  - Implement resetDatabase() method to delete and recreate database
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ]* 3.1 Write property test for initialization idempotence
  - **Property 2: Initialization idempotence**
  - **Validates: Requirements 1.4, 1.5**

- [ ]* 3.2 Write property test for error propagation
  - **Property 3: Error propagation and display**
  - **Validates: Requirements 1.3, 3.4, 4.1**

- [x] 4. Create ErrorScreen widget





  - Create lib/screens/error_screen.dart file
  - Implement StatelessWidget with errorMessage, onRetry, and optional onReset parameters
  - Design UI with Vietnamese error message display
  - Add retry button that calls onRetry callback
  - Add reset button (conditionally shown) that calls onReset callback
  - Add helpful guidance text for common error scenarios
  - _Requirements: 4.1, 4.2, 4.5_

- [x] 5. Create InitializationScreen widget





  - Create lib/screens/initialization_screen.dart file
  - Implement StatefulWidget that shows loading indicator
  - Display "Đang khởi tạo..." message in Vietnamese
  - Add CircularProgressIndicator for visual feedback
  - Handle navigation to MainScreen on success or ErrorScreen on failure
  - _Requirements: 2.1, 2.2, 2.3_

- [ ]* 5.1 Write property test for loading screen lifecycle
  - **Property 4: Loading screen lifecycle**
  - **Validates: Requirements 2.1, 2.2, 2.3**

- [x] 6. Modify main.dart to use proactive initialization





  - Import DatabaseInitializer
  - Call DatabaseInitializer.initialize() in main() after WidgetsFlutterBinding.ensureInitialized()
  - Pass DatabaseInitResult to MyApp constructor
  - Modify MyApp to accept initResult parameter
  - Update MyApp.build() to show InitializationScreen initially
  - Implement conditional navigation based on initResult (MainScreen or ErrorScreen)
  - _Requirements: 1.1, 1.2, 1.3_

- [ ]* 6.1 Write property test for database initialization before UI
  - **Property 1: Database initialization before UI**
  - **Validates: Requirements 1.1, 1.2**

- [x] 7. Implement retry mechanism





  - Add retry counter to InitializationScreen or ErrorScreen state
  - Implement retry logic that calls DatabaseInitializer.initialize() again
  - Track number of retry attempts
  - Show escalated guidance after 2 failed retries
  - _Requirements: 4.2, 4.3, 4.4_

- [ ]* 7.1 Write property test for retry mechanism
  - **Property 5: Retry mechanism**
  - **Validates: Requirements 4.2, 4.3**

- [ ]* 7.2 Write property test for escalated error guidance
  - **Property 7: Escalated error guidance**
  - **Validates: Requirements 4.4**

- [x] 8. Add error message localization





  - Create helper method to convert technical errors to Vietnamese user-friendly messages
  - Map DatabaseException to "Cơ sở dữ liệu bị lỗi..."
  - Map FileSystemException to "Ứng dụng không có quyền truy cập..."
  - Map disk full errors to "Bộ nhớ thiết bị đã đầy..."
  - Provide fallback message for unknown errors
  - _Requirements: 4.1_

- [x] 9. Implement database reset functionality





  - Add reset button to ErrorScreen for corruption errors
  - Implement DatabaseInitializer.resetDatabase() to delete database file
  - Call initialize() after reset to recreate database
  - Show confirmation dialog before reset (data loss warning)
  - _Requirements: 4.5_

- [x] 10. Checkpoint - Ensure all tests pass





  - Ensure all tests pass, ask the user if questions arise.
