import 'package:equatable/equatable.dart';

class PersonEntity extends Equatable {
  final String id;
  final String uniqueId;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? gender;
  final DateTime? birthDate;
  final String? email;
  final String? mobile;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;
  final String? profilePhoto;
  final String? role;
  final String? userType;
  final String? userClass;
  final List<dynamic>? relationships;
  final List<dynamic>? emergencyContacts;
  final bool isActive;
  final bool isEmailVerified;
  final bool isMobileVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PersonEntity({
    required this.id,
    required this.uniqueId,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.gender,
    this.birthDate,
    this.email,
    this.mobile,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.profilePhoto,
    this.role,
    this.userType,
    this.userClass,
    this.relationships,
    this.emergencyContacts,
    required this.isActive,
    required this.isEmailVerified,
    required this.isMobileVerified,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    uniqueId,
    firstName,
    middleName,
    lastName,
    gender,
    birthDate,
    email,
    mobile,
    phone,
    address,
    city,
    state,
    country,
    pincode,
    profilePhoto,
    role,
    userType,
    userClass,
    relationships,
    emergencyContacts,
    isActive,
    isEmailVerified,
    isMobileVerified,
    createdAt,
    updatedAt,
  ];
}
