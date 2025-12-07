import 'package:flutter/material.dart';
import '../database/database_initializer.dart';
import 'error_screen.dart';
import '../main.dart';

/// InitializationScreen displays a loading indicator during database initialization
///
/// This screen is shown during app startup while the database is being initialized.
/// It provides:
/// - Loading indicator with Vietnamese message
/// - Automatic navigation to MainScreen on successful initialization
/// - Automatic navigation to ErrorScreen on initialization failure
/// - Retry mechanism for failed initializations with retry counter
class InitializationScreen extends StatefulWidget {
  final int retryCount;

  const InitializationScreen({Key? key, this.retryCount = 0}) : super(key: key);

  @override
  State<InitializationScreen> createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> {
  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  /// Initializes the database and handles navigation based on result
  Future<void> _initializeDatabase() async {
    final result = await DatabaseInitializer.initialize();

    if (!mounted) return;

    if (result.success) {
      // Navigate to MainScreen on success
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    } else {
      // Navigate to ErrorScreen on failure with retry count
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ErrorScreen(
            errorMessage: result.errorMessage ?? 'Lỗi không xác định',
            retryCount: widget.retryCount,
            onRetry: () => _handleRetry(context),
            onReset: _shouldShowReset(result.errorMessage)
                ? () => _handleReset(context)
                : null,
          ),
        ),
      );
    }
  }

  /// Handles retry action by navigating back to InitializationScreen with incremented retry count
  void _handleRetry(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => InitializationScreen(
          retryCount: widget.retryCount + 1,
        ),
      ),
    );
  }

  /// Handles database reset action
  Future<void> _handleReset(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác Nhận Khởi Tạo Lại'),
        content: const Text(
          'Thao tác này sẽ xóa toàn bộ dữ liệu hiện tại và tạo cơ sở dữ liệu mới. Bạn có chắc chắn muốn tiếp tục?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Khởi Tạo Lại'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Reset database and retry initialization
      await DatabaseInitializer.resetDatabase();
      _handleRetry(context);
    }
  }

  /// Determines if reset button should be shown based on error message
  bool _shouldShowReset(String? errorMessage) {
    if (errorMessage == null) return false;
    final errorLower = errorMessage.toLowerCase();
    return errorLower.contains('bị lỗi') || errorLower.contains('corrupt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon (optional)
            Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: Colors.blue[700],
            ),
            const SizedBox(height: 32),

            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
            ),
            const SizedBox(height: 24),

            // Loading message in Vietnamese
            Text(
              'Đang khởi tạo...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // Additional info text
            Text(
              'Vui lòng đợi trong giây lát',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
