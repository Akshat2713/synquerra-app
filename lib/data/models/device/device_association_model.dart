import '../../../domain/entities/device/device_association_entity.dart';

/// Represents one entry from the API's `assignments` array.
/// The API no longer sends an association id or an assigned_at timestamp,
/// so those are not modeled. The nested `user` object's fields are mapped
/// directly here rather than through PersonModel or a new model.
class DeviceAssociationModel {
  final String userId;
  final String name;
  final String? phone;
  final String? email;
  final String? profile;
  final String assignmentType;

  const DeviceAssociationModel({
    required this.userId,
    required this.name,
    this.phone,
    this.email,
    this.profile,
    required this.assignmentType,
  });

  factory DeviceAssociationModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    return DeviceAssociationModel(
      userId: user['id'] as String? ?? '',
      name: user['name'] as String? ?? '',
      phone: user['phone'] as String?,
      email: user['email'] as String?,
      profile: user['profile'] as String?,
      assignmentType: json['assignment_type'] as String? ?? '',
    );
  }

  DeviceAssociationEntity toEntity() => DeviceAssociationEntity(
    userId: userId,
    name: name,
    phone: phone,
    email: email,
    profile: profile,
    assignmentType: assignmentType,
  );
}
