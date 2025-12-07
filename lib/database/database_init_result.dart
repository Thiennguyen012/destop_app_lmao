/// Result of database initialization operation
class DatabaseInitResult {
  /// Whether the initialization was successful
  final bool success;

  /// Error message if initialization failed (null if successful)
  final String? errorMessage;

  /// Time taken to complete initialization
  final Duration initTime;

  /// Stack trace if initialization failed (null if successful)
  final String? stackTrace;

  DatabaseInitResult({
    required this.success,
    this.errorMessage,
    required this.initTime,
    this.stackTrace,
  });

  /// Factory constructor for successful initialization
  factory DatabaseInitResult.success(Duration initTime) {
    return DatabaseInitResult(
      success: true,
      initTime: initTime,
    );
  }

  /// Factory constructor for failed initialization
  factory DatabaseInitResult.failure(
    String errorMessage,
    Duration initTime,
    String? stackTrace,
  ) {
    return DatabaseInitResult(
      success: false,
      errorMessage: errorMessage,
      initTime: initTime,
      stackTrace: stackTrace,
    );
  }
}
