import 'package:equatable/equatable.dart';

/// Represents the device's owner as a plain person record.
/// Replaces the old ownership-record shape (owner_id, owner_type, person_id,
/// owned_from, owned_to, status) — that shape is permanently gone from the API.
class DeviceOwnerEntity extends Equatable {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? profile;

  const DeviceOwnerEntity({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.profile,
  });

  @override
  List<Object?> get props => [id, name, phone, email, profile];
}
