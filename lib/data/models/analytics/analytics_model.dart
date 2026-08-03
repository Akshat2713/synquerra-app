import '../../../domain/entities/analytics/analytics_entity.dart';
import '../../../presentation/utils/date_time_formatter.dart';

class AnalyticsModel {
  final String id;
  final String imei;
  final String? geoid;
  final String? packet;
  final String? latitude;
  final String? longitude;
  final double? speed;
  final String? battery;
  final String? signal;
  final String deviceTimestamp;
  final String? type;
  final String? temperature;
  final String? phone1;
  final String? phone2;
  final String? alert;
  final GeofenceData? geofence;
  final AddressData? address;

  const AnalyticsModel({
    required this.id,
    required this.imei,
    this.geoid,
    this.packet,
    this.latitude,
    this.longitude,
    this.speed,
    this.battery,
    this.signal,
    this.temperature,
    this.phone1,
    this.phone2,
    this.alert,
    required this.deviceTimestamp,
    this.type,
    this.geofence,
    this.address,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) => AnalyticsModel(
    id: json['id'] as String? ?? '',
    imei: (json['imei'] ?? '').toString(),
    geoid: json['geoid'] as String?,
    packet: json['packet'] as String?,
    latitude: json['latitude'] as String?,
    longitude: json['longitude'] as String?,
    speed: (json['speed'] as num?)?.toDouble(),
    battery: json['battery']?.toString(),
    signal: json['signal']?.toString(),
    alert: json['alert'] as String?,
    deviceTimestamp: json['deviceTimestamp'] as String? ?? '',
    type: json['type'] as String?,
    geofence: json['geofence'] != null
        ? GeofenceData.fromJson(json['geofence'] as Map<String, dynamic>)
        : null,
    address: json['address'] != null
        ? AddressData.fromJson(json['address'] as Map<String, dynamic>)
        : null,
  );

  AnalyticsEntity toEntity() => AnalyticsEntity(
    id: id,
    imei: imei,
    geoid: geoid,
    packet: packet,
    latitude: latitude != null ? double.tryParse(latitude!) : null,
    longitude: longitude != null ? double.tryParse(longitude!) : null,
    speed: speed,
    battery: battery != null ? int.tryParse(battery!) : null,
    signal: signal != null ? int.tryParse(signal!) : null,
    temperature: "NA",
    phone1: "No Primary Number",
    phone2: "No Secondary Number",
    alert: alert,
    deviceTimestamp: DateTimeFormatter.parseUtcToLocal(deviceTimestamp),
    type: type,
    geofenceName: geofence?.geofenceName,
    formattedAddress: address?.address,
  );
}

class GeofenceData {
  final String? geofenceName;
  final String? geofenceNumber;
  final String? geofenceId;

  const GeofenceData({this.geofenceName, this.geofenceNumber, this.geofenceId});

  factory GeofenceData.fromJson(Map<String, dynamic> json) => GeofenceData(
    geofenceName: json['geofence_name'] as String?,
    geofenceNumber: json['geofence_number'] as String?,
    geofenceId: json['geofence_id'] as String?,
  );
}

class AddressData {
  final String? address;

  const AddressData({this.address});

  factory AddressData.fromJson(Map<String, dynamic> json) =>
      AddressData(address: json['address'] as String?);
}
