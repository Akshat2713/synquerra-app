import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AppLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('── REQUEST ──────────────────────────');
      debugPrint('${options.method} ${options.uri}');
      debugPrint('Headers: ${options.headers}');
      debugPrint('Body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('── RESPONSE ─────────────────────────');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Data: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('── ERROR ────────────────────────────');
      debugPrint('${err.type}: ${err.message}');
      debugPrint('Error: ${err.error}');
      debugPrint('Response: ${err.response?.data}');
    }
    handler.next(err);
  }
}
