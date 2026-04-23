// lib/data/mappers/user_mapper.dart
import '../../business/entities/user_entity.dart';
import '../models/user_model.dart';

class UserMapper {
  const UserMapper();

  /// Convert Model to Entity
  UserEntity toEntity(UserModel model) {
    return UserEntity(
      uniqueId: model.uniqueId,
      firstName: model.firstName,
      lastName: model.lastName,
      imei: model.imei,
      email: model.email,
      mobile: model.mobile,
      userType: model.userType,
      accessToken: model.accessToken,
      refreshToken: model.refreshToken,
      lastLoginAt: model.lastLoginAt,
    );
  }

  /// Convert Entity to Model (for saving)
  UserModel toModel(UserEntity entity) {
    return UserModel(
      uniqueId: entity.uniqueId,
      firstName: entity.firstName,
      lastName: entity.lastName,
      imei: entity.imei,
      email: entity.email,
      mobile: entity.mobile,
      userType: entity.userType,
      accessToken: entity.accessToken ?? '',
      refreshToken: entity.refreshToken ?? '',
      lastLoginAt: entity.lastLoginAt ?? '',
    );
  }

  /// Convert JSON to Model (from login response)
  UserModel fromLoginJson(Map<String, dynamic> json) {
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

  /// Convert JSON to Model (from signup response)
  UserModel fromSignupJson(Map<String, dynamic> json) {
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
}
