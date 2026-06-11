import '../../../domain/entities/auth/user_entity.dart';

class UserModel {
  final String uniqueId;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String imei;
  final String userType;
  final String email;
  final String mobile;
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final bool isEmailVerified;
  final bool isMobileVerified;
  final String? lastLoginAt;

  const UserModel({
    required this.uniqueId,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.imei,
    required this.userType,
    required this.email,
    required this.mobile,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.isEmailVerified,
    required this.isMobileVerified,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final tokens = json['tokens'] as Map<String, dynamic>;
    return UserModel(
      uniqueId: json['unique_id'] as String,
      firstName: json['first_name'] as String,
      middleName: json['middle_name'] as String?,
      lastName: json['last_name'] as String,
      imei: json['imei'] as String,
      userType: json['user_type'] as String,
      email: json['email'] as String,
      mobile: json['mobile'] as String,
      accessToken: tokens['access_token'] as String,
      refreshToken: tokens['refresh_token'] as String,
      tokenType: tokens['token_type'] as String,
      expiresIn: tokens['expires_in'] as int,
      isEmailVerified: json['is_email_verified'] as bool,
      isMobileVerified: json['is_mobile_verified'] as bool,
      lastLoginAt: json['last_login_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'unique_id': uniqueId,
    'first_name': firstName,
    'middle_name': middleName,
    'last_name': lastName,
    'imei': imei,
    'user_type': userType,
    'email': email,
    'mobile': mobile,
    'is_email_verified': isEmailVerified,
    'is_mobile_verified': isMobileVerified,
    'last_login_at': lastLoginAt,
    'tokens': {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
    },
  };

  UserEntity toEntity() => UserEntity(
    uniqueId: uniqueId,
    firstName: firstName,
    middleName: middleName,
    lastName: lastName,
    imei: imei,
    userType: userType,
    email: email,
    mobile: mobile,
    accessToken: accessToken,
    refreshToken: refreshToken,
    tokenType: tokenType,
    expiresIn: expiresIn,
    isEmailVerified: isEmailVerified,
    isMobileVerified: isMobileVerified,
    lastLoginAt: lastLoginAt,
  );
}
