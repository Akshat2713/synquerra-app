part of 'geofence_bloc.dart';

abstract class GeofenceEvent extends Equatable {
  const GeofenceEvent();
  @override
  List<Object?> get props => [];
}

class GeofenceLoad extends GeofenceEvent {
  final String deviceId;
  const GeofenceLoad(this.deviceId);
  @override
  List<Object?> get props => [deviceId];
}

class GeofenceCreate extends GeofenceEvent {
  final String deviceId;
  final String name;
  final bool isActive;
  final List<Coordinate> coordinates;
  final String color;
  const GeofenceCreate({
    required this.deviceId,
    required this.name,
    required this.isActive,
    required this.coordinates,
    required this.color,
  });
  @override
  List<Object?> get props => [deviceId, name, isActive, coordinates, color];
}

class GeofenceEdit extends GeofenceEvent {
  final String deviceId;
  final String geofenceId;
  final String name;
  final bool isActive;
  final List<Coordinate> coordinates;
  final String color;
  final String geofenceNumber;
  final int entryAlertDelay;
  final int exitAlertDelay;
  const GeofenceEdit({
    required this.deviceId,
    required this.geofenceId,
    required this.name,
    required this.isActive,
    required this.coordinates,
    required this.color,
    required this.geofenceNumber,
    required this.entryAlertDelay,
    required this.exitAlertDelay,
  });
  @override
  List<Object?> get props => [
    deviceId,
    geofenceId,
    name,
    isActive,
    coordinates,
    color,
    geofenceNumber,
    entryAlertDelay,
    exitAlertDelay,
  ];
}

class GeofenceDelete extends GeofenceEvent {
  final String deviceId;
  final String geofenceId;
  const GeofenceDelete({required this.deviceId, required this.geofenceId});
  @override
  List<Object?> get props => [deviceId, geofenceId];
}
