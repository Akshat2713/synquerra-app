import 'package:equatable/equatable.dart';

class Coordinate extends Equatable {
  final double lat;
  final double lng;

  const Coordinate({required this.lat, required this.lng});

  @override
  List<Object?> get props => [lat, lng];
}

class GeofenceEntity extends Equatable {
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

  const GeofenceEntity({
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

  bool get isEnabled => isActive && isSyncToDevice;

  @override
  List<Object?> get props => [
    id,
    imei,
    geofenceName,
    geofenceNumber,
    geofenceId,
    isActive,
    coordinates,
    geofenceColor,
    entryAlertDelay,
    isSyncToDevice,
    exitAlertDelay,
    createdAt,
    updatedAt,
  ];
}
