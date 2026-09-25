import '../../../domain/entities/device/device_owner_entity.dart';

/// Represents the device's owner as a plain person record.
/// NOTE: This replaces the old ownership-record shape (owner_id, owner_type,
/// person_id, owned_from, owned_to, status) — the API no longer sends that
/// shape and this is now permanent. Fields are mapped directly from the
/// `owner` object in the API response (id, name, phone, email, profile).
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

  factory DeviceOwnerModel.fromJson(Map<String, dynamic> json) =>
      DeviceOwnerModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        profile: json['profile'] as String?,
      );

  DeviceOwnerEntity toEntity() => DeviceOwnerEntity(
    id: id,
    name: name,
    phone: phone,
    email: email,
    profile: profile,
  );
}
