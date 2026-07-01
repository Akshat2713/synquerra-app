import 'package:equatable/equatable.dart';
import '../signup/signup_entity.dart';

class DeviceAssociationEntity extends Equatable {
  final String id;
  final String associationType;
  final DateTime? assignedAt;
  final PersonEntity? person;

  const DeviceAssociationEntity({
    required this.id,
    required this.associationType,
    this.assignedAt,
    this.person,
  });

  @override
  List<Object?> get props => [
    id,
    associationType,
    assignedAt,
    person, // Nested Equatable object comparison works automatically
  ];
}
