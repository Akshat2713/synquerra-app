// lib/data/network/ssl_config.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class SslConfig {
  SslConfig._();

  /// Enable/disable SSL certificate verification
  /// Set to true for development, false for production
  static bool get allowInsecureConnections {
    // In development, allow insecure connections
    // In production, this should be false
    return kDebugMode; // Only bypass in debug mode
  }

  /// Apply SSL configuration
  static void configureSsl() {
    if (allowInsecureConnections) {
      debugPrint(
        '⚠️ WARNING: SSL certificate verification is DISABLED (Development mode only)',
      );
      HttpOverrides.global = _InsecureHttpOverrides();
    } else {
      debugPrint('✅ SSL certificate verification is ENABLED (Production mode)');
      HttpOverrides.global = null;
    }
  }
}

/// Insecure HTTP overrides - ONLY for development
class _InsecureHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Allow all certificates in development
        debugPrint('⚠️ Bypassing SSL certificate for: $host');
        return true;
      };
  }
}
