import '../../../domain/entities/signup/signup_entity.dart';

class PersonModel {
  final String personId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final bool isActive;

  const PersonModel({
    required this.personId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.isActive,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return PersonModel(
      personId: data['id'] as String,
      firstName: data['first_name'] as String,
      lastName: data['last_name'] as String,
      email: data['email'] as String,
      phone: data['phone'] as String,
      isActive: data['is_active'] as bool,
    );
  }

  Map<String, dynamic> toRequestJson({
    required String birthDate,
    required String gender,
    required String address,
    required String city,
    required String state,
    required String country,
    required String pincode,
  }) => {
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'phone': phone,
    'birth_date': birthDate,
    'gender': gender,
    'address': address,
    'city': city,
    'state': state,
    'country': country,
    'pincode': pincode,
    'is_active': true,
  };

  PersonEntity toEntity() => PersonEntity(
    personId: personId,
    firstName: firstName,
    lastName: lastName,
    email: email,
    phone: phone,
    isActive: isActive,
  );
}
