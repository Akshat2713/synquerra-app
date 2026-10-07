import '../../../domain/entities/device/device_owner_entity.dart';

class DeviceOwnerModel {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? profile;

  const DeviceOwnerModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.profile,
  });

  factory DeviceOwnerModel.fromJson(Map<String, dynamic> json) {
    final firstName = json['first_name']?.toString().trim() ?? '';
    final lastName = json['last_name']?.toString().trim() ?? '';

    final name = [
      firstName,
      lastName,
    ].where((value) => value.isNotEmpty).join(' ');

    return DeviceOwnerModel(
      id: json['user_id']?.toString() ?? '',
      name: name,
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      profile: json['profile_photo']?.toString(),
    );
  }

  DeviceOwnerEntity toEntity() => DeviceOwnerEntity(
    id: id,
    name: name,
    phone: phone,
    email: email,
    profile: profile,
  );
}
