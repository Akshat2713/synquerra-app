import '../../../domain/entities/geofence/geofence_entity.dart';

class GeofenceModel {
  final String id;
  final String imei;
  final String geofenceName;
  final String geofenceNumber;
  final String geofenceId;
  final bool isActive;
  final List<Coordinate> coordinates;
  final String geofenceColor;
  final int entryAlertDelay;
  final bool isSyncToDevice;
  final int exitAlertDelay;
  final String createdAt;
  final String updatedAt;

  const GeofenceModel({
    required this.id,
    required this.imei,
    required this.geofenceName,
    required this.geofenceNumber,
    required this.geofenceId,
    required this.isActive,
    required this.coordinates,
    required this.geofenceColor,
    required this.entryAlertDelay,
    required this.isSyncToDevice,
    required this.exitAlertDelay,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GeofenceModel.fromJson(Map<String, dynamic> json) => GeofenceModel(
    id: json['id'] as String,
    imei: json['imei'] as String,
    geofenceName: json['geofence_name'] as String,
    geofenceNumber: json['geofence_number'] as String,
    geofenceId: json['geofence_id'] as String,
    isActive: json['is_active'] as bool,
    coordinates: (json['coordinates'] as List<dynamic>)
        .map(
          (e) => Coordinate(
            lat: (e['lat'] as num).toDouble(),
            lng: (e['lng'] as num).toDouble(),
          ),
        )
        .toList(),
    geofenceColor: json['geofence_color'] as String,
    entryAlertDelay: json['entry_alert_delay'] as int,
    isSyncToDevice: json['is_sync_to_device'] as bool,
    exitAlertDelay: json['exit_alert_delay'] as int,
    createdAt: json['created_at'] as String,
    updatedAt: json['updated_at'] as String,
  );

  GeofenceEntity toEntity() => GeofenceEntity(
    id: id,
    imei: imei,
    geofenceName: geofenceName,
    geofenceNumber: geofenceNumber,
    geofenceId: geofenceId,
    isActive: isActive,
    coordinates: coordinates,
    geofenceColor: geofenceColor,
    entryAlertDelay: entryAlertDelay,
    isSyncToDevice: isSyncToDevice,
    exitAlertDelay: exitAlertDelay,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
