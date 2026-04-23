// lib/data/models/user_model.dart
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
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

  const UserModel({
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

  String get fullName => "$firstName $lastName";

  /// Create UserModel from login JSON response
  factory UserModel.fromLoginJson(Map<String, dynamic> json) {
    final tokens = json['tokens'] as Map<String, dynamic>? ?? {};
    return UserModel(
      uniqueId: json['uniqueId']?.toString() ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      imei: json['imei']?.toString() ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      userType: json['userType'] ?? '',
      accessToken: tokens['accessToken'] ?? '',
      refreshToken: tokens['refreshToken'] ?? '',
      lastLoginAt: json['lastLoginAt'] ?? '',
    );
  }

  /// Create UserModel from signup JSON response
  factory UserModel.fromSignupJson(Map<String, dynamic> json) {
    return UserModel(
      uniqueId: json['_id'] ?? json['uniqueId'] ?? '',
      firstName: json['name'] ?? json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      imei: json['imei']?.toString() ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      userType: json['userType'] ?? '',
      accessToken: '',
      refreshToken: '',
      lastLoginAt: '',
    );
  }

  /// Create UserModel from generic JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel.fromLoginJson(json);
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

  @override
  List<Object?> get props => [
    uniqueId,
    firstName,
    lastName,
    imei,
    email,
    mobile,
    userType,
    accessToken,
    refreshToken,
    lastLoginAt,
  ];
}

class AuthResponseModel {
  final String status;
  final int code;
  final String message;
  final UserModel? data;

  AuthResponseModel({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      status: json['status'] ?? 'error',
      code: json['code'] ?? 500,
      message: json['message'] ?? 'Unknown error',
      data: json['data'] != null ? UserModel.fromLoginJson(json['data']) : null,
    );
  }
}

class SignupResponseModel {
  final String status;
  final UserModel? user;

  SignupResponseModel({required this.status, this.user});

  factory SignupResponseModel.fromJson(Map<String, dynamic> json) {
    final mainData = json['data'];
    final innerData = mainData?['data'];
    final userNode = innerData?['user'];

    return SignupResponseModel(
      status: mainData?['status'] ?? 'unknown',
      user: userNode != null ? UserModel.fromSignupJson(userNode) : null,
    );
  }
}
