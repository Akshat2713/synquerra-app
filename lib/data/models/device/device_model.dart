import '../../../domain/entities/device/device_entity.dart';
import 'device_owner_model.dart';

class DeviceModel {
  final String id;
  final String topic;
  final String imei;
  final String serialNo;
  final String? geoid;
  final String? latitude;
  final String? longitude;
  final String? speed;
  final String? temperature;
  final String? currentMode;
  final String ledStatus;
  final String? timestamp;
  final String? battery;
  final String? signal;
  final String? gpsStrength;
  final bool isActive;
  final bool isSubscribed;
  final String? inventoryStatus;
  final String? associationType;
  final String createdAt;
  final String updatedAt;
  final String relationship;
  final DeviceOwnerModel? deviceOwner;
  final List<dynamic> deviceAssociation;

  const DeviceModel({
    required this.id,
    required this.topic,
    required this.imei,
    required this.serialNo,
    this.geoid,
    this.latitude,
    this.longitude,
    this.speed,
    this.temperature,
    this.currentMode = 'NA',
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
    this.deviceAssociation = const [],
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    final master = json['device_master'] as Map<String, dynamic>;
    final ownerJson = json['device_owner'] as Map<String, dynamic>?;

    return DeviceModel(
      id: master['id'] as String,
      topic: master['topic'] as String,
      imei: master['imei'] as String,
      serialNo: master['serial_no'] as String,
      geoid: master['geoid'] as String?,
      latitude: master['latitude'] as String?,
      longitude: master['longitude'] as String?,
      speed: master['speed'] as String?,
      temperature: master['temperature'] as String?,
      currentMode: master['current_mode'] as String?,
      ledStatus: master['led_status'] as String,
      timestamp: master['timestamp'] as String?,
      battery: master['battery'] as String?,
      signal: master['signal'] as String?,
      gpsStrength: master['gps_strength'] as String?,
      isActive: master['is_active'] as bool,
      isSubscribed: master['is_subscribed'] as bool,
      inventoryStatus: master['inventory_status'] as String?,
      associationType: master['association_type'] as String?,
      createdAt: master['createdAt'] as String,
      updatedAt: master['updatedAt'] as String,
      relationship: json['relationship'] as String,
      deviceOwner: ownerJson != null
          ? DeviceOwnerModel.fromJson(ownerJson)
          : null,
      deviceAssociation: json['device_association'] as List<dynamic>? ?? [],
    );
  }

  // Extracts the leading numeric value from strings like "7 km/hr" or "36.27 c"
  static double? _parseLeadingNumber(String? value) {
    if (value == null) return null;
    final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(value);
    return match != null ? double.tryParse(match.group(0)!) : null;
  }

  DeviceEntity toEntity() => DeviceEntity(
    id: id,
    topic: topic,
    imei: imei,
    serialNo: serialNo,
    geoid: geoid,
    latitude: latitude != null ? double.tryParse(latitude!) : null,
    longitude: longitude != null ? double.tryParse(longitude!) : null,
    speed: _parseLeadingNumber(speed),
    temperature: temperature,
    currentMode: currentMode ?? 'NA',
    ledStatus: ledStatus,
    timestamp: timestamp,
    battery: battery != null ? int.tryParse(battery!) : null,
    signal: signal != null ? int.tryParse(signal!) : null,
    gpsStrength: gpsStrength,
    isActive: isActive,
    isSubscribed: isSubscribed,
    inventoryStatus: inventoryStatus,
    associationType: associationType,
    createdAt: createdAt,
    updatedAt: updatedAt,
    relationship: relationship,
    deviceOwner: deviceOwner?.toEntity(),
  );
}
