import 'package:flutter/material.dart';

/// ErrorScreen displays database initialization errors with retry and reset options
///
/// This screen is shown when database initialization fails, providing:
/// - User-friendly error messages in Vietnamese
/// - Retry button to attempt initialization again
/// - Optional reset button for corrupted database scenarios
/// - Helpful guidance for common error scenarios
/// - Escalated guidance after multiple retry attempts
class ErrorScreen extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback? onReset;
  final int retryCount;

  const ErrorScreen({
    Key? key,
    required this.errorMessage,
    required this.onRetry,
    this.onReset,
    this.retryCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Error icon
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red[400],
              ),
              const SizedBox(height: 24),

              // Error title
              Text(
                'Lỗi Khởi Tạo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Error message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  errorMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Helpful guidance
              _buildGuidanceText(),
              const SizedBox(height: 16),

              // Escalated guidance after multiple retries
              if (retryCount >= 2) _buildEscalatedGuidance(),
              const SizedBox(height: 32),

              // Retry button
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Thử Lại',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Reset button (conditionally shown)
              if (onReset != null) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: onReset,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Khởi Tạo Lại Cơ Sở Dữ Liệu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Builds helpful guidance text based on common error scenarios
  Widget _buildGuidanceText() {
    String guidanceText = _getGuidanceForError(errorMessage);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              guidanceText,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns appropriate guidance text based on error message content
  String _getGuidanceForError(String error) {
    final errorLower = error.toLowerCase();

    if (errorLower.contains('quyền') || errorLower.contains('permission')) {
      return 'Vui lòng kiểm tra quyền truy cập bộ nhớ của ứng dụng trong Cài đặt > Ứng dụng > Quản lý tài chính.';
    } else if (errorLower.contains('đầy') ||
        errorLower.contains('full') ||
        errorLower.contains('space')) {
      return 'Bộ nhớ thiết bị không đủ. Vui lòng xóa các file không cần thiết hoặc ứng dụng khác để giải phóng dung lượng.';
    } else if (errorLower.contains('bị lỗi') ||
        errorLower.contains('corrupt')) {
      return 'Cơ sở dữ liệu có thể bị hỏng. Bạn có thể thử khởi tạo lại để tạo cơ sở dữ liệu mới (dữ liệu cũ sẽ bị xóa).';
    } else {
      return 'Nếu lỗi vẫn tiếp tục, vui lòng thử khởi động lại ứng dụng hoặc liên hệ hỗ trợ.';
    }
  }

  /// Builds escalated guidance after multiple failed retry attempts
  Widget _buildEscalatedGuidance() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đã thử lại nhiều lần',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vui lòng thử các bước sau:\n'
                  '1. Khởi động lại ứng dụng hoàn toàn\n'
                  '2. Kiểm tra dung lượng bộ nhớ còn trống\n'
                  '3. Xóa cache của ứng dụng trong Cài đặt\n'
                  '4. Nếu vẫn lỗi, thử khởi tạo lại cơ sở dữ liệu',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
