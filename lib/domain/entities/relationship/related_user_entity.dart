import 'package:equatable/equatable.dart';

class RelatedUserEntity extends Equatable {
  final String id;
  final String uniqueId;
  final String firstName;
  final String lastName;
  final String? email;
  final String? mobile;
  final String? profilePhoto;

  const RelatedUserEntity({
    required this.id,
    required this.uniqueId,
    required this.firstName,
    required this.lastName,
    this.email,
    this.mobile,
    this.profilePhoto,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
    id,
    uniqueId,
    firstName,
    lastName,
    email,
    mobile,
    profilePhoto,
  ];
}
