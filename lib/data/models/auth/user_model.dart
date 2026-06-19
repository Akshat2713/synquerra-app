import '../../../domain/entities/auth/user_entity.dart';

class UserModel {
  final String uniqueId;
  final String firstName;
  // final String? middleName;
  final String lastName;
  // final String imei;
  final String userType;
  final String email;
  // final String mobile;
  final String accessToken;
  final String refreshToken;
  // final String tokenType;
  // final int expiresIn;
  // final bool isEmailVerified;
  // final bool isMobileVerified;
  // final String? lastLoginAt;
  final String personId;

  const UserModel({
    required this.uniqueId,
    required this.firstName,
    // this.middleName,
    required this.lastName,
    // required this.imei,
    required this.userType,
    required this.email,
    // required this.mobile,
    required this.accessToken,
    required this.refreshToken,
    // required this.tokenType,
    // required this.expiresIn,
    // required this.isEmailVerified,
    // required this.isMobileVerified,
    // this.lastLoginAt,
    required this.personId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final tokens = json['tokens'] as Map<String, dynamic>;
    return UserModel(
      uniqueId: user['id'] as String,
      firstName: user['firstName'] as String,
      lastName: user['lastName'] as String,
      userType: user['role'] as String,
      email: user['email'] as String,
      accessToken: tokens['accessToken'] as String,
      refreshToken: tokens['refreshToken'] as String,
      personId: user['personId'] as String,
    );
  }

  // ✅ Fix toJson to match API camelCase
  Map<String, dynamic> toJson() => {
    'user': {
      'id': uniqueId,
      'firstName': firstName,
      'lastName': lastName,
      'role': userType,
      'email': email,
      'personId': personId,
    },
    'tokens': {'accessToken': accessToken, 'refreshToken': refreshToken},
  };

  UserEntity toEntity() => UserEntity(
    uniqueId: uniqueId,
    firstName: firstName,
    // middleName: middleName,
    lastName: lastName,
    // imei: imei,
    userType: userType,
    email: email,
    // mobile: mobile,
    accessToken: accessToken,
    refreshToken: refreshToken,
    // tokenType: tokenType,
    // expiresIn: expiresIn,
    // isEmailVerified: isEmailVerified,
    // isMobileVerified: isMobileVerified,
    // lastLoginAt: lastLoginAt,
    personId: personId,
  );
}
