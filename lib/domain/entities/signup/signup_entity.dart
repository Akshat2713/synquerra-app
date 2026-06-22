import 'package:equatable/equatable.dart';

class PersonEntity extends Equatable {
  final String personId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final bool isActive;

  const PersonEntity({
    required this.personId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
    personId,
    firstName,
    lastName,
    email,
    phone,
    isActive,
  ];
}
