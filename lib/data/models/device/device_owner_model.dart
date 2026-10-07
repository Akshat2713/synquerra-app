import '../../../domain/entities/device/device_owner_entity.dart';

/// Represents the device's owner as a plain person record.
///
/// Mapped from the `owner` object in the API payload:
/// (`user_id`, `first_name`, `last_name`, `phone`, `email`, `profile_photo`).
class DeviceOwnerModel {
  final String id;
  final String firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final String? profile;

  const DeviceOwnerModel({
    required this.id,
    required this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.profile,
  });

  factory DeviceOwnerModel.fromJson(Map<String, dynamic> json) {
    return DeviceOwnerModel(
      id: (json['user_id'] ?? json['id'] ?? '').toString(),
      firstName: json['first_name']?.toString().trim() ?? '',
      lastName: json['last_name']?.toString().trim(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      profile: (json['profile_photo'] ?? json['profile'])?.toString(),
    );
  }

  /// Dynamically computes the full name without extra spaces.
  String get name {
    final names = [
      firstName,
      lastName,
    ].where((value) => value != null && value.isNotEmpty);

    final fullName = names.join(' ');

    return fullName.isNotEmpty ? fullName : 'Unknown Owner';
  }

  DeviceOwnerEntity toEntity() => DeviceOwnerEntity(
    id: id,
    name: name,
    phone: phone,
    email: email,
    profile: profile,
  );
}
