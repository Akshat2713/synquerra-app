import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
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

  const UserEntity({
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

  String get fullName => middleName != null
      ? '$firstName $middleName $lastName'
      : '$firstName $lastName';

  @override
  List<Object?> get props => [
    uniqueId,
    firstName,
    middleName,
    lastName,
    imei,
    userType,
    email,
    mobile,
    accessToken,
    refreshToken,
    tokenType,
    expiresIn,
    isEmailVerified,
    isMobileVerified,
    lastLoginAt,
  ];
}
