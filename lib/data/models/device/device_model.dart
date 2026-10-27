import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/device/device_entity.dart';
import 'device_association_model.dart';
import 'device_owner_model.dart';

class DeviceModel {
  final String id;
  final String? topic;
  final String imei;
  final String serialNo;
  final String? geoid;
  final String? latitude;
  final String? longitude;
  final String? speed;
  final String? temperature;
  final String? currentMode;
  // final String ledStatus;
  final String? timestamp;
  final String? battery;
  final String? signal;
  final String? gpsStrength;
  final String? associationType;
  final bool? isOnline;
  final bool? isCharging;
  final String createdAt;
  final String updatedAt;
  final String relationship;
  final DeviceOwnerModel? owner;
  // final PersonModel? carrier;
  final List<DeviceAssociationModel> assignments;

  const DeviceModel({
    required this.id,
    this.topic,
    required this.imei,
    required this.serialNo,
    this.geoid,
    this.latitude,
    this.longitude,
    this.speed,
    this.temperature,
    this.currentMode = 'NA',
    // required this.ledStatus,
    this.timestamp,
    this.battery,
    this.signal,
    this.gpsStrength,
    this.associationType,
    this.isOnline,
    this.isCharging,
    required this.createdAt,
    required this.updatedAt,
    required this.relationship,
    this.owner,
    // this.carrier,
    this.assignments = const [],
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    // Use nested 'device_master' if available, otherwise fallback to root json
    final master = (json['device_master'] as Map<String, dynamic>?) ?? json;
    // final carrierJson = json['carrier_user'] as Map<String, dynamic>?;
    final ownerJson = json['owner'] as Map<String, dynamic>?;
    final assignmentsJson = json['assignments'] as List<dynamic>? ?? [];

    return DeviceModel(
      id: (master['id'] ?? '') as String,
      topic: (master['subscription_topic'] ?? master['topic'])?.toString(),
      imei: (master['imei'] ?? '') as String,
      serialNo: (master['serial_no'] ?? '') as String,
      geoid: master['geoid']?.toString(),
      latitude: master['latitude']?.toString(),
      longitude: master['longitude']?.toString(),
      speed: master['speed']?.toString(),
      temperature: master['temperature']?.toString(),
      currentMode: master['current_mode'] as String?,
      // ledStatus: (master['led_status'] ?? '') as String,
      timestamp: master['timestamp'] as String?,
      battery: master['battery']?.toString(),
      signal: master['signal']?.toString(),
      gpsStrength: master['gps_strength']?.toString(),
      associationType: master['association_type'] as String?,
      isOnline: master['is_online'] as bool?,
      isCharging: master['is_charging'] as bool?,
      createdAt: (master['created_at'] ?? master['createdAt'] ?? '') as String,
      updatedAt: (master['updated_at'] ?? master['updatedAt'] ?? '') as String,
      relationship: (json['relationship'] ?? '') as String,
      owner: ownerJson != null ? DeviceOwnerModel.fromJson(ownerJson) : null,
      // carrier: carrierJson != null ? PersonModel.fromJson(carrierJson) : null,
      assignments: assignmentsJson
          .map(
            (a) => DeviceAssociationModel.fromJson(a as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  // Extracts the leading numeric value from strings like "7 km/hr" or "36.27 c"
  static double? _parseLeadingNumber(String? value) {
    if (value == null) return null;
    final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(value);
    return match != null ? double.tryParse(match.group(0)!) : null;
  }

  String get displayOwnerName => _resolveDisplayOwnerName();

  String? get displayProfilePhoto => _resolveDisplayProfilePhoto();

  String get displayRealUserId => _resolveDisplayRealUserId();

  String _resolveDisplayRealUserId() {
    // 1. Check carrier in assignments first
    final c = carrierAssignment;
    if (c != null) {
      final carrierUserId = c.userId
          .trim(); // (or c.id depending on your model property)
      if (carrierUserId.isNotEmpty) return carrierUserId;
    }

    // 2. Fall back to the owner's id
    return owner?.id ?? ''; // (or owner?.userId ?? '')
  }

  String _resolveDisplayOwnerName() {
    AppLogger.d('DeviceEntity', 'New Device');

    // 1. Check carrier in assignments first
    final c = carrierAssignment;
    if (c != null) {
      final carrierName = c.name.trim(); // already "first last" combined
      AppLogger.d('DeviceEntity', 'Carrier Name: "$carrierName"');
      if (carrierName.isNotEmpty) return carrierName;
    }

    // 2. Fall back to non-null owner
    final ownerName = owner!.name.trim();
    AppLogger.d('DeviceEntity', 'Owner Name: "$ownerName"');
    return ownerName;
  }

  String? _resolveDisplayProfilePhoto() {
    // 1. Carrier exists -> use the carrier's photo only (null if they have none)
    final c = carrierAssignment;
    if (c != null) {
      final p = c.profile;
      return (p != null && p.isNotEmpty) ? p : null;
    }

    // 2. No carrier -> fall back to the owner's photo
    final p = owner?.profile;
    return (p != null && p.isNotEmpty) ? p : null;
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
    // ledStatus: ledStatus,
    timestamp: timestamp,
    battery: battery != null ? int.tryParse(battery!) : null,
    signal: signal != null ? int.tryParse(signal!) : null,
    gpsStrength: gpsStrength,
    associationType: associationType,
    isOnline: isOnline,
    isCharging: isCharging,
    createdAt: createdAt,
    updatedAt: updatedAt,
    relationship: relationship,
    owner: owner!.toEntity(),
    // carrier: carrier?.toEntity(),
    assignments: assignments.map((a) => a.toEntity()).toList(),
    displayOwnerName: displayOwnerName,
    displayProfilePhoto: displayProfilePhoto,
    displayRealUserId: displayRealUserId,
  );

  DeviceAssociationModel? get carrierAssignment {
    for (final a in assignments) {
      if (a.assignmentType.toLowerCase() == 'carrier') return a;
    }
    return null;
  }
}
