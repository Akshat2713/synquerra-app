// lib/business/entities/user_entity.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uniqueId;
  final String firstName;
  final String lastName;
  final String imei;
  final String email;
  final String mobile;
  final String userType;
  final String? accessToken;
  final String? refreshToken;
  final String? lastLoginAt;

  const UserEntity({
    required this.uniqueId,
    required this.firstName,
    required this.lastName,
    required this.imei,
    required this.email,
    required this.mobile,
    required this.userType,
    this.accessToken,
    this.refreshToken,
    this.lastLoginAt,
  });

  String get fullName => "$firstName $lastName";

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

  UserEntity copyWith({
    String? uniqueId,
    String? firstName,
    String? lastName,
    String? imei,
    String? email,
    String? mobile,
    String? userType,
    String? accessToken,
    String? refreshToken,
    String? lastLoginAt,
  }) {
    return UserEntity(
      uniqueId: uniqueId ?? this.uniqueId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      imei: imei ?? this.imei,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      userType: userType ?? this.userType,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
