import 'package:equatable/equatable.dart';

/// Represents one entry from the API's `assignments` array.
/// No association id or assigned_at timestamp is sent by the API, so
/// they're not modeled. The assigned user's fields are flattened directly
/// onto this entity rather than nested under a PersonEntity.
class DeviceAssociationEntity extends Equatable {
  final String userId;
  final String name;
  final String? phone;
  final String? email;
  final String? profile;
  final String assignmentType;

  const DeviceAssociationEntity({
    required this.userId,
    required this.name,
    this.phone,
    this.email,
    this.profile,
    required this.assignmentType,
  });

  @override
  List<Object?> get props => [
    userId,
    name,
    phone,
    email,
    profile,
    assignmentType,
  ];
}
