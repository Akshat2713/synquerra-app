import 'package:equatable/equatable.dart';

class DeviceOwnerEntity extends Equatable {
  final String id;
  final String ownerId;
  final String ownerType;
  final String? personId;
  final String ownedFrom;
  final String? ownedTo;
  final String status;

  const DeviceOwnerEntity({
    required this.id,
    required this.ownerId,
    required this.ownerType,
    this.personId,
    required this.ownedFrom,
    this.ownedTo,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    ownerId,
    ownerType,
    personId,
    ownedFrom,
    ownedTo,
    status,
  ];
}
