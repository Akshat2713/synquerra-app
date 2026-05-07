// lib/data/datasources/remote/auth_remote_datasource.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:synquerra/new/data/models/user_model.dart';

import '../../network/api_client.dart';
import '../graphql/auth_queries.dart';
// import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Login with email and password
  Future<UserModel> login(String email, String password) async {
    final body = {"query": AuthQueries.loginMutation(email, password)};

    debugPrint('📤 Login Request Body: ${jsonEncode(body)}');

    final response = await _apiClient.post('/auth/signin-query', body);
    final jsonResponse = jsonDecode(response.body);

    debugPrint('📥 Login Response: $jsonResponse');

    if (jsonResponse['errors'] != null) {
      throw Exception(jsonResponse['errors'][0]['message']);
    }

    final authResponse = AuthResponseModel.fromJson(jsonResponse);

    if (authResponse.code == 200 && authResponse.status == 'success') {
      if (authResponse.data == null) {
        throw Exception('No user data received');
      }
      return authResponse.data!;
    } else {
      throw Exception(authResponse.message);
    }
  }

  /// Signup with user details
  Future<UserModel> signup(Map<String, dynamic> input) async {
    final body = {"query": AuthQueries.signupMutation(input)};

    debugPrint('📤 Signup Request Body: ${jsonEncode(body)}');

    final response = await _apiClient.post('/auth/signup-query', body);
    final jsonResponse = jsonDecode(response.body);

    debugPrint('📥 Signup Response: $jsonResponse');

    if (jsonResponse['errors'] != null) {
      throw Exception(jsonResponse['errors'][0]['message']);
    }

    final signupResponse = SignupResponseModel.fromJson(jsonResponse);

    if (signupResponse.user == null) {
      throw Exception('Signup failed');
    }

    return signupResponse.user!;
  }

  /// Get device IMEIs for the authenticated user
  Future<List<String>> getDeviceImeis() async {
    final body = {"query": AuthQueries.deviceImeiQuery};

    final response = await _apiClient.post('/device/device-master-query', body);
    final jsonResponse = jsonDecode(response.body);

    if (jsonResponse['status'] == 'success') {
      final List<dynamic> devices = jsonResponse['data']['devices'] ?? [];
      return devices
          .map<String>((device) => device['imei'].toString())
          .toList();
    } else {
      throw Exception('Failed to load devices');
    }
  }
}
