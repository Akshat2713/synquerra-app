import '../../../domain/entities/auth/user_entity.dart';

class UserModel {
  final String uniqueId;
  final String firstName;
  final String lastName;
  final String userType;
  final String email;
  final String accessToken;
  final String refreshToken;
  final String sessionId;
  final String personId;

  const UserModel({
    required this.uniqueId,
    required this.firstName,
    required this.lastName,
    required this.userType,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
    required this.sessionId,
    required this.personId,
  });

  /// Handles both API network responses and flat cached local storage.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // 1. Check if reading from local cache (flat map)
    if (json.containsKey('uniqueId')) {
      return UserModel(
        uniqueId: json['uniqueId'] as String? ?? '',
        personId: json['personId'] as String? ?? '',
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        userType: json['userType'] as String? ?? 'user',
        email: json['email'] as String? ?? '',
        accessToken: json['accessToken'] as String? ?? '',
        refreshToken: json['refreshToken'] as String? ?? '',
        sessionId: json['sessionId'] as String? ?? '',
      );
    }

    // 2. Otherwise parse API response structure
    final payload =
        json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final user = (payload['user'] as Map<String, dynamic>?) ?? {};

    return UserModel(
      uniqueId: (user['id'] ?? '') as String,
      personId: (user['id'] ?? '') as String,
      firstName: (user['first_name'] ?? '') as String,
      lastName: (user['last_name'] ?? '') as String,
      userType: (user['user_type'] ?? 'user') as String,
      email: (user['email'] ?? '') as String,
      accessToken: (payload['access_token'] ?? '') as String,
      refreshToken: (payload['refresh_token'] ?? '') as String,
      sessionId: (payload['session_id'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'uniqueId': uniqueId,
    'firstName': firstName,
    'lastName': lastName,
    'userType': userType,
    'email': email,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'sessionId': sessionId,
    'personId': personId,
  };

  UserEntity toEntity() => UserEntity(
    uniqueId: uniqueId,
    firstName: firstName,
    lastName: lastName,
    userType: userType,
    email: email,
    accessToken: accessToken,
    refreshToken: refreshToken,
    sessionId: sessionId,
    personId: personId,
  );
}
