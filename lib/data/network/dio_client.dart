import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/log_interceptor.dart';
import 'interceptors/token_refresh_interceptor.dart';
import 'session_expired_notifier.dart';

class DioClient {
  late final Dio _dio;

  DioClient(
    FlutterSecureStorage secureStorage,
    SessionExpiredNotifier notifier,
  ) {
    _dio = _buildDio();
    final refreshDio = _buildDio(); // no interceptors on purpose

    _dio.interceptors.addAll([
      AuthInterceptor(secureStorage),
      // Must come BEFORE ErrorInterceptor so it sees the raw 401
      TokenRefreshInterceptor(
        dio: _dio,
        refreshDio: refreshDio,
        storage: secureStorage,
        notifier: notifier,
      ),
      ErrorInterceptor(),
      AppLogInterceptor(),
    ]);
  }

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        // baseUrl: ApiConstants.devBaseUrl, // ⚠️ DEV ONLY
        connectTimeout: const Duration(
          milliseconds: ApiConstants.connectTimeoutMs,
        ),
        receiveTimeout: const Duration(
          milliseconds: ApiConstants.receiveTimeoutMs,
        ),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeoutMs),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    // ⚠️ DEV ONLY — remove before production
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    return dio;
  }

  Dio get dio => _dio;
}
