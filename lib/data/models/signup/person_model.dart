import '../../../domain/entities/signup/person_entity.dart';

class PersonModel {
  final String id;
  final String uniqueId;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? gender;
  final String? birthDate;
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
  final String? createdAt;
  final String? updatedAt;

  const PersonModel({
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

  factory PersonModel.fromJson(Map<String, dynamic> json) => PersonModel(
    id: json['id'] as String? ?? '',
    uniqueId: json['unique_id'] as String? ?? '',
    firstName: (json['first_name'] as String? ?? '').trim(),
    middleName: (json['middle_name'] as String?)?.trim(),
    lastName: (json['last_name'] as String? ?? '').trim(),
    gender: json['gender'] as String?,
    birthDate: json['birth_date'] as String?,
    email: json['email'] as String?,
    mobile: json['mobile'] as String?,
    phone: json['phone'] as String?,
    address: json['address'] as String?,
    city: json['city'] as String?,
    state: json['state'] as String?,
    country: json['country'] as String?,
    pincode: json['pincode'] as String?,
    profilePhoto: json['profile_photo'] as String?,
    role: json['role'] as String?,
    userType: json['user_type'] as String?,
    userClass: json['user_class'] as String?,
    relationships: json['relationships'] as List<dynamic>?,
    emergencyContacts: json['emergency_contacts'] as List<dynamic>?,
    isActive: json['is_active'] as bool? ?? true,
    isEmailVerified: json['is_email_verified'] as bool? ?? false,
    isMobileVerified: json['is_mobile_verified'] as bool? ?? false,
    createdAt: json['created_at'] as String?,
    updatedAt: json['updated_at'] as String?,
  );

  PersonEntity toEntity() => PersonEntity(
    id: id,
    uniqueId: uniqueId,
    firstName: firstName,
    middleName: middleName,
    lastName: lastName,
    gender: gender,
    birthDate: birthDate != null ? DateTime.tryParse(birthDate!) : null,
    email: email,
    mobile: mobile,
    phone: phone,
    address: address,
    city: city,
    state: state,
    country: country,
    pincode: pincode,
    profilePhoto: profilePhoto,
    role: role,
    userType: userType,
    userClass: userClass,
    relationships: relationships,
    emergencyContacts: emergencyContacts,
    isActive: isActive,
    isEmailVerified: isEmailVerified,
    isMobileVerified: isMobileVerified,
    createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
  );
}
