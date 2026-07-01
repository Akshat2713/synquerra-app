import '../../../domain/entities/signup/signup_entity.dart';

class PersonModel {
  final String personId;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? birthDate;
  final String? gender;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;
  final String? profilePhoto;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  const PersonModel({
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

  factory PersonModel.fromJson(Map<String, dynamic> json) => PersonModel(
    personId: json['id'] as String,
    // API sometimes sends trailing whitespace (e.g. "Sanjay "), trim it
    firstName: (json['first_name'] as String? ?? '').trim(),
    lastName: (json['last_name'] as String? ?? '').trim(),
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    birthDate: json['birth_date'] as String?,
    gender: json['gender'] as String?,
    address: json['address'] as String?,
    city: json['city'] as String?,
    state: json['state'] as String?,
    country: json['country'] as String?,
    pincode: json['pincode'] as String?,
    profilePhoto: json['profile_photo'] as String?,
    isActive: json['is_active'] as bool? ?? true,
    createdAt: json['created_at'] as String?,
    updatedAt: json['updated_at'] as String?,
  );

  PersonEntity toEntity() => PersonEntity(
    personId: personId,
    firstName: firstName,
    lastName: lastName,
    email: email,
    phone: phone,
    birthDate: birthDate != null ? DateTime.tryParse(birthDate!) : null,
    gender: gender,
    address: address,
    city: city,
    state: state,
    country: country,
    pincode: pincode,
    profilePhoto: profilePhoto,
    isActive: isActive,
    createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
  );
}
