import 'package:equatable/equatable.dart';

import '../signup/person_entity.dart';
import 'device_association_entity.dart';
import 'device_owner_entity.dart';

class DeviceEntity extends Equatable {
  final String id;
  final String topic;
  final String imei;
  final String serialNo;
  final String? geoid;
  final double? latitude;
  final double? longitude;
  final double? speed;
  final String? temperature;
  final String currentMode;
  final String ledStatus;
  final String? timestamp;
  final int? battery;
  final int? signal;
  final String? gpsStrength;
  final bool isActive;
  final bool isSubscribed;
  final String? inventoryStatus;
  final String? associationType;
  final bool? isOnline;
  final bool? isCharging;
  final String createdAt;
  final String updatedAt;
  final String relationship;
  final DeviceOwnerEntity? deviceOwner;
  final PersonEntity? carrier;
  final List<DeviceAssociationEntity> associations;

  const DeviceEntity({
    required this.id,
    required this.topic,
    required this.imei,
    required this.serialNo,
    this.geoid,
    this.latitude,
    this.longitude,
    this.speed,
    this.temperature,
    required this.currentMode,
    required this.ledStatus,
    this.timestamp,
    this.battery,
    this.signal,
    this.gpsStrength,
    required this.isActive,
    required this.isSubscribed,
    this.inventoryStatus,
    this.associationType,
    this.isOnline,
    this.isCharging,
    required this.createdAt,
    required this.updatedAt,
    required this.relationship,
    this.deviceOwner,
    this.carrier,
    this.associations = const [],
  });

  bool get hasLocation => latitude != null && longitude != null;
  bool get hasData => battery != null && signal != null;
  bool get isOwned => relationship == 'owned';

  /// Shows the carrier's name if the device is assigned to someone;
  /// otherwise falls back to the current logged-in user (device owner).
  String displayOwnerName(String currentUserFullName) {
    if (carrier == null) return currentUserFullName;
    final name = '${carrier!.firstName} ${carrier!.lastName}'.trim();
    return name.isEmpty ? currentUserFullName : name;
  }

  DeviceAssociationEntity? associationFor(String roleKey) {
    try {
      return associations.firstWhere((a) => a.associationType == roleKey);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
    id,
    topic,
    imei,
    serialNo,
    geoid,
    latitude,
    longitude,
    speed,
    temperature,
    currentMode,
    ledStatus,
    timestamp,
    battery,
    signal,
    gpsStrength,
    isActive,
    isSubscribed,
    inventoryStatus,
    associationType,
    isOnline,
    isCharging,
    createdAt,
    updatedAt,
    relationship,
    deviceOwner,
    carrier,
    associations,
  ];
}
