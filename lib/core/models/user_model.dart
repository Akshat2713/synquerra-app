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

  factory UserData.fromLoginJson(Map<String, dynamic> json) {
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

  factory UserData.fromSignupJson(Map<String, dynamic> json) {
    return UserData(
      // MAPPING LOGIC: Map the Signup API's "_id" to our App's "uniqueId"
      uniqueId: json['_id'] ?? '',

      // MAPPING LOGIC: Map the Signup API's "name" to "firstName"
      firstName: json['name'] ?? '',
      lastName: '', // Signup doesn't return last name, so we leave it empty

      email: json['email'] ?? '',

      // These fields are missing in Signup response, so we provide defaults
      mobile: '',
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
      'email': email,
      'mobile': mobile,
      'lastLoginAt': lastLoginAt,
      'tokens': {'accessToken': accessToken, 'refreshToken': refreshToken},
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData.fromLoginJson(json); // The structure matches Login
  }
}
