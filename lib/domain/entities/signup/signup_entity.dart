import 'package:equatable/equatable.dart';

class PersonEntity extends Equatable {
  final String personId;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final DateTime? birthDate;
  final String? gender;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;
  final String? profilePhoto;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PersonEntity({
    required this.personId,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.birthDate,
    this.gender,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.profilePhoto,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    personId,
    firstName,
    lastName,
    email,
    phone,
    birthDate,
    gender,
    address,
    city,
    state,
    country,
    pincode,
    profilePhoto,
    isActive,
    createdAt,
    updatedAt,
  ];
}
