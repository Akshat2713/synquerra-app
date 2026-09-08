import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uniqueId;
  final String firstName;
  final String lastName;
  final String userType;
  final String email;
  final String accessToken;
  final String refreshToken;
  final String sessionId;
  final String personId;

  const UserEntity({
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

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
    uniqueId,
    firstName,
    lastName,
    userType,
    email,
    accessToken,
    refreshToken,
    sessionId,
    personId,
  ];
}
