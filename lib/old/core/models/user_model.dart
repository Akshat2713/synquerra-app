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
      data: json['data'] != null ? UserData.fromLoginJson(json['data']) : null,
    );
  }
}

class SignupResponse {
  final String status;
  final UserData? user; // Reusing the same UserData object!

  SignupResponse({required this.status, this.user});

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    // Navigate: data -> signup -> data -> user
    // final signupNode = json['data']?['signup'];
    final mainData = json['data'];

    final innerData = mainData?['data'];
    // final userNode = signupNode?['data']?['user'];

    final userNode = innerData?['user'];

    return SignupResponse(
      status: mainData?['status'] ?? 'unknown',
      // We use a SPECIFIC constructor for Signup data
      user: userNode != null ? UserData.fromSignupJson(userNode) : null,
    );
  }
}

class UserData {
  final String uniqueId;
  final String firstName;
  final String lastName;
  final String imei;
  final String email;
  final String mobile;
  final String userType;
  final String accessToken;
  final String refreshToken;
  final String lastLoginAt;

  UserData({
    required this.uniqueId,
    required this.firstName,
    required this.lastName,
    required this.imei,
    required this.email,
    required this.mobile,
    required this.userType,
    required this.accessToken,
    required this.refreshToken,
    required this.lastLoginAt,
  });

  factory UserData.fromLoginJson(Map<String, dynamic> json) {
    // OPTIMIZATION: Debug print to see what the model is receiving
    print("DEBUG: Parsing UserData from JSON: $json");

    final tokens = json['tokens'] ?? {};

    return UserData(
      uniqueId: json['uniqueId']?.toString() ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      // Ensure we catch 'imei' even if it comes as an int or string
      imei: json['imei']?.toString() ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      userType: json['userType'] ?? '',
      accessToken: tokens['accessToken'] ?? '',
      refreshToken: tokens['refreshToken'] ?? '',
      lastLoginAt: json['lastLoginAt'] ?? '',
    );
  }

  factory UserData.fromSignupJson(Map<String, dynamic> json) {
    return UserData(
      uniqueId: json['_id'] ?? json['uniqueId'] ?? '',
      firstName: json['name'] ?? json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? 'N/A',
      imei: json['imei']?.toString() ?? '', // Try to get IMEI even on signup
      mobile: json['mobile'] ?? '',
      userType: json['userType'] ?? '',
      accessToken: '',
      refreshToken: '',
      lastLoginAt: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uniqueId': uniqueId,
      'firstName': firstName,
      'lastName': lastName,
      'imei': imei,
      'email': email,
      'mobile': mobile,
      'userType': userType,
      'lastLoginAt': lastLoginAt,
      'tokens': {'accessToken': accessToken, 'refreshToken': refreshToken},
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData.fromLoginJson(json); // The structure matches Login
  }
}
