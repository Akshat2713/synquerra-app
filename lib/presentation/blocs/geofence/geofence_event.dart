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

  const GeofenceCreate({
    required this.deviceId,
    required this.name,
    required this.isActive,
    required this.coordinates,
  });

  @override
  List<Object?> get props => [deviceId, name, isActive, coordinates];
}

class GeofenceDelete extends GeofenceEvent {
  final String deviceId;
  final String geofenceId;

  const GeofenceDelete({required this.deviceId, required this.geofenceId});

  @override
  List<Object?> get props => [deviceId, geofenceId];
}
