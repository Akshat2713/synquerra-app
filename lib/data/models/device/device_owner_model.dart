import '../../../domain/entities/device/device_owner_entity.dart';

/// Represents the device's owner as a plain person record.
/// Mapped directly from the `owner` object in the API payload:
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
      // The API sends 'user_id', fallback to 'id' for backward compatibility
      id: (json['user_id'] ?? json['id'] ?? '') as String,
      firstName: (json['first_name'] ?? '') as String,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      // The API sends 'profile_photo', fallback to 'profile'
      profile: (json['profile_photo'] ?? json['profile']) as String?,
    );
  }

  /// Dynamically computes full name without producing extra spaces or "null"
  String get name {
    final fullName = '$firstName${lastName ?? ''}'.trim();
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
