part of 'geofence_bloc.dart';

abstract class GeofenceEvent extends Equatable {
  const GeofenceEvent();

  @override
  List<Object?> get props => [];
}

class GeofenceLoad extends GeofenceEvent {
  final String imei;

  const GeofenceLoad(this.imei);

  @override
  List<Object?> get props => [imei];
}

class GeofenceCreate extends GeofenceEvent {
  final String imei;
  final String name;
  final bool isActive;
  final List<Coordinate> coordinates;

  const GeofenceCreate({
    required this.imei,
    required this.name,
    required this.isActive,
    required this.coordinates,
  });

  @override
  List<Object?> get props => [imei, name, isActive, coordinates];
}

class GeofenceDelete extends GeofenceEvent {
  final String imei;
  final String geofenceId;

  const GeofenceDelete({required this.imei, required this.geofenceId});

  @override
  List<Object?> get props => [imei, geofenceId];
}
