import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:synquerra/old/core/models/user_model.dart';

// import '../models/auth_response.dart';
import '../models/signup_input.dart';
import '../constants/auth_queries.dart';
import 'base_api_service.dart';

class AuthService extends BaseApiService {
  AuthService(super.token);

  Future<AuthResponse> login(String email, String password) async {
    final body = {
      "query": AuthQueries.loginMutation(email, password),
      // "variables": {"email": email, "password": password},
    };

    final response = await post('/auth/signin-query', body);
    final jsonResponse = jsonDecode(response.body);

    if (jsonResponse['errors'] != null) {
      throw Exception(jsonResponse['errors'][0]['message']);
    }

    final authResponse = AuthResponse.fromJson(jsonResponse);

    // RESTORED: Your professional validation logic
    if (authResponse.code == 200 && authResponse.status == 'success') {
      if (authResponse.data?.imei.isEmpty ?? true) {
        debugPrint(
          "CRITICAL: Login succeeded but IMEI is still empty from API!",
        );
      }
      return authResponse;
    } else {
      throw Exception(authResponse.message);
    }
  }

  Future<SignupResponse> signup(SignupInput input) async {
    final body = {
      "query": AuthQueries.signupMutation({
        'firstName': input.firstName,
        'lastName': input.lastName,
        'email': input.email,
        'password': input.password,
        'mobile': input.mobile,
      }),
      // "variables": {
      //   "input": {
      //     "firstName": input.firstName,
      //     "middleName": input.middleName,
      //     "lastName": input.lastName,
      //     "email": input.email,
      //     "mobile": input.mobile,
      //     "password": input.password,
      //   },
      // },
    };

    final response = await post('/auth/signup-query', body);
    final jsonResponse = jsonDecode(response.body);

    if (jsonResponse['errors'] != null) {
      throw Exception(jsonResponse['errors'][0]['message']);
    }

    return SignupResponse.fromJson(jsonResponse);
  }

  // RESTORED: Device IMEI fetching logic
  Future<List<String>> getDeviceImeis() async {
    final body = {"query": AuthQueries.deviceImeiQuery};

    try {
      final response = await post('/device/device-master-query', body);
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == 'success') {
        final List<dynamic> devices = jsonResponse['data']['devices'] ?? [];
        return devices
            .map<String>((device) => device['imei'].toString())
            .toList();
      } else {
        throw Exception('Failed to load devices');
      }
    } catch (e) {
      debugPrint("Error fetching IMEIs: $e");
      return [];
    }
  }
}
