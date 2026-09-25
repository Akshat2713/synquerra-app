import 'package:equatable/equatable.dart';

import '../../../core/utils/app_logger.dart';
import '../signup/person_entity.dart';
import 'device_association_entity.dart';
import 'device_owner_entity.dart';

class DeviceEntity extends Equatable {
  final String id;
  final String? topic;
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
  final bool? isActive;
  final bool? isSubscribed;
  final String? inventoryStatus;
  final String? associationType;
  final bool? isOnline;
  final bool? isCharging;
  final String createdAt;
  final String updatedAt;
  final String relationship;
  final DeviceOwnerEntity? owner;
  final PersonEntity? carrier;
  final List<DeviceAssociationEntity> assignments;

  // Fields present in the newer API payload that weren't modeled before.
  final int? schemaVersion;
  final String? hdop;
  final String? satsUsed;
  final String? satsInView;
  final String? fixType;
  final String? deviceMode;
  final String? gnssMode;
  final String? source;
  final String? hardwareVersion;
  final String? firmwareVersion;

  const DeviceEntity({
    required this.id,
    this.topic,
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
    this.isActive,
    this.isSubscribed,
    this.inventoryStatus,
    this.associationType,
    this.isOnline,
    this.isCharging,
    required this.createdAt,
    required this.updatedAt,
    required this.relationship,
    this.owner,
    this.carrier,
    this.assignments = const [],
    this.schemaVersion,
    this.hdop,
    this.satsUsed,
    this.satsInView,
    this.fixType,
    this.deviceMode,
    this.gnssMode,
    this.source,
    this.hardwareVersion,
    this.firmwareVersion,
  });

  bool get hasLocation => latitude != null && longitude != null;
  bool get hasData => battery != null && signal != null;
  bool get isOwned => relationship == 'owned';

  String displayOwnerName(String currentUserFullName) {
    AppLogger.d('DeviceEntity', 'New Device');
    final carrierName = carrier != null
        ? '${carrier!.firstName} ${carrier!.lastName}'.trim()
        : '';
    AppLogger.d('DeviceEntity', 'Carrier Name: "$carrierName"');
    if (carrierName.isNotEmpty) return carrierName;

    final ownerName = owner?.name.trim() ?? '';
    AppLogger.d('DeviceEntity', 'Owner Name: "$ownerName"');
    if (ownerName.isNotEmpty) return ownerName;

    return currentUserFullName;
  }

  DeviceAssociationEntity? associationFor(String roleKey) {
    try {
      return assignments.firstWhere((a) => a.assignmentType == roleKey);
    } catch (_) {
      return null;
    }
  }

  String? get geoidLocation {
    if (geoid == '10' || geoid == '11') {
      return 'outside';
    }
    return geoid;
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
    owner,
    carrier,
    assignments,
    schemaVersion,
    hdop,
    satsUsed,
    satsInView,
    fixType,
    deviceMode,
    gnssMode,
    source,
    hardwareVersion,
    firmwareVersion,
  ];
}

extension DeviceEntityFiltering on List<DeviceEntity> {
  List<DeviceEntity> get ownedDevices => where(
    (d) => d.relationship == 'owned' || d.relationship == 'both',
  ).toList();

  List<DeviceEntity> get unassignedDevices =>
      ownedDevices.where((d) => d.carrier == null).toList();

  List<DeviceEntity> get assignedDevices =>
      ownedDevices.where((d) => d.carrier != null).toList();
}
