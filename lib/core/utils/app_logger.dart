import 'package:flutter/foundation.dart';

/// Centralised logger utility.
/// Logs automatically execute ONLY in debug mode (`kDebugMode`).
class AppLogger {
  AppLogger._();

  /// Debug logs
  static void d(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[$tag] 🐛 $message');
    }
  }

  /// Info logs
  static void i(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[$tag] ℹ️ $message');
    }
  }

  /// Warning logs
  static void w(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[$tag] ⚠️ $message');
    }
  }

  /// Error logs with optional exception & stacktrace
  static void e(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (kDebugMode) {
      debugPrint('[$tag] ❌ $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }
}
