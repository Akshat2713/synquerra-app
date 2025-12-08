// lib/models/auth_response.dart
class AuthResponse {
  final String status;
  final int code;
  final String message;
  final UserData? data;

  AuthResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'] ?? 'error',
      code: json['code'] ?? 500,
      message: json['message'] ?? 'Unknown error',
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }
}

class UserData {
  final String uniqueId;
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String accessToken;
  final String refreshToken;
  final String lastLoginAt;

  UserData({
    required this.uniqueId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.accessToken,
    required this.refreshToken,
    required this.lastLoginAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    final tokens = json['tokens'] ?? {};
    return UserData(
      uniqueId: json['uniqueId'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      accessToken: tokens['accessToken'] ?? '',
      refreshToken: tokens['refreshToken'] ?? '',
      lastLoginAt: json['lastLoginAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uniqueId': uniqueId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobile': mobile,
      'lastLoginAt': lastLoginAt,
      'tokens': {'accessToken': accessToken, 'refreshToken': refreshToken},
    };
  }
}
