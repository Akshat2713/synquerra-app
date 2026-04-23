// lib/data/network/api_client.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import 'error_handler.dart';

class ApiClient {
  String? _accessToken;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final int maxRetries;

  ApiClient({
    String? accessToken,
    this.connectTimeout = const Duration(seconds: ApiConstants.connectTimeout),
    this.receiveTimeout = const Duration(seconds: ApiConstants.receiveTimeout),
    this.sendTimeout = const Duration(seconds: ApiConstants.sendTimeout),
    this.maxRetries = ApiConstants.maxRetries,
  }) : _accessToken = accessToken;

  /// Update access token
  void updateToken(String? token) {
    _accessToken = token;
  }

  /// Clear access token
  void clearToken() {
    _accessToken = null;
  }

  /// Get headers with authorization
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  /// POST request with retry logic
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    int attempt = 0;
    Exception? lastError;

    while (attempt < maxRetries) {
      try {
        final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
        debugPrint('🌐 POST Request: $url');
        debugPrint('📤 Body: ${jsonEncode(body)}');
        final response = await http
            .post(url, headers: _headers, body: jsonEncode(body))
            .timeout(connectTimeout);

        debugPrint('📥 Response Status: ${response.statusCode}');
        debugPrint('📥 Response Body: ${response.body}');
        // Handle response - throws exceptions on error status codes
        NetworkErrorHandler.handleResponse(response);

        return response;
      } on TimeoutException catch (e) {
        debugPrint('❌ Timeout: $e');

        lastError = e;
        attempt++;
        if (attempt >= maxRetries) rethrow;
        await Future.delayed(
          Duration(milliseconds: ApiConstants.retryDelayMs * attempt),
        );
      } on SocketException catch (e) {
        debugPrint('❌ Socket Error: $e');

        lastError = e;
        attempt++;
        if (attempt >= maxRetries) rethrow;
        await Future.delayed(
          Duration(milliseconds: ApiConstants.retryDelayMs * attempt),
        );
      } on ApiException catch (e) {
        debugPrint('❌ POST Error: $e');

        // Don't retry on client errors (4xx) except 401
        if (e.statusCode == 401) {
          // Token expired - caller should refresh
          rethrow;
        }
        rethrow;
      } catch (e) {
        lastError = e as Exception;
        rethrow;
      }
    }

    throw lastError ??
        NetworkException('Request failed after $maxRetries attempts');
  }

  /// GET request
  Future<http.Response> get(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      final response = await http
          .get(url, headers: _headers)
          .timeout(receiveTimeout);

      NetworkErrorHandler.handleResponse(response);
      return response;
    } catch (e) {
      throw NetworkErrorHandler.handleError(e);
    }
  }

  /// PUT request
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      final response = await http
          .put(url, headers: _headers, body: jsonEncode(body))
          .timeout(sendTimeout);

      NetworkErrorHandler.handleResponse(response);
      return response;
    } catch (e) {
      throw NetworkErrorHandler.handleError(e);
    }
  }

  /// DELETE request
  Future<http.Response> delete(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      final response = await http
          .delete(url, headers: _headers)
          .timeout(sendTimeout);

      NetworkErrorHandler.handleResponse(response);
      return response;
    } catch (e) {
      throw NetworkErrorHandler.handleError(e);
    }
  }
}
