import 'package:equatable/equatable.dart';

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
  final String createdAt;
  final String updatedAt;
  final String relationship;
  final DeviceOwnerEntity? deviceOwner;

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
    required this.createdAt,
    required this.updatedAt,
    required this.relationship,
    this.deviceOwner,
  });

  bool get hasLocation => latitude != null && longitude != null;
  bool get hasData => battery != null && signal != null;
  bool get isOwned => relationship == 'owned';

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
    createdAt,
    updatedAt,
    relationship,
    deviceOwner,
  ];
}
