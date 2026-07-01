import '../../../domain/entities/device/device_owner_entity.dart';

class DeviceOwnerModel {
  final String id;
  final String ownerId;
  final String ownerType;
  final String? personId;
  final String ownedFrom;
  final String? ownedTo;
  final String status;

  const DeviceOwnerModel({
    required this.id,
    required this.ownerId,
    required this.ownerType,
    this.personId,
    required this.ownedFrom,
    this.ownedTo,
    required this.status,
  });

  factory DeviceOwnerModel.fromJson(Map<String, dynamic> json) =>
      DeviceOwnerModel(
        id: json['id'] as String,
        ownerId: json['owner_id'] as String,
        ownerType: json['owner_type'] as String,
        personId: json['person_id'] as String?,
        ownedFrom: json['owned_from'] as String,
        ownedTo: json['owned_to'] as String?,
        status: json['status'] as String,
      );

  DeviceOwnerEntity toEntity() => DeviceOwnerEntity(
    id: id,
    ownerId: ownerId,
    ownerType: ownerType,
    personId: personId,
    ownedFrom: ownedFrom,
    ownedTo: ownedTo,
    status: status,
  );
}
