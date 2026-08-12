import '../../../domain/entities/device/device_association_entity.dart';
import '../signup/person_model.dart';

class DeviceAssociationModel {
  final String id;
  final String associationType;
  final String? assignedAt;
  final PersonModel? person;

  const DeviceAssociationModel({
    required this.id,
    required this.associationType,
    this.assignedAt,
    this.person,
  });

  factory DeviceAssociationModel.fromJson(Map<String, dynamic> json) {
    final personJson = json['person'] as Map<String, dynamic>?;
    return DeviceAssociationModel(
      id: json['id'] as String,
      associationType: json['association_type'] as String,
      assignedAt: json['assigned_at'] as String?,
      person: personJson != null ? PersonModel.fromJson(personJson) : null,
    );
  }

  DeviceAssociationEntity toEntity() => DeviceAssociationEntity(
    id: id,
    associationType: associationType,
    assignedAt: assignedAt != null ? DateTime.tryParse(assignedAt!) : null,
    person: person?.toEntity(),
  );
}
