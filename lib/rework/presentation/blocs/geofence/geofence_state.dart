part of 'geofence_bloc.dart';

abstract class GeofenceState {}

class GeofenceInitial extends GeofenceState {}

class GeofenceLoading extends GeofenceState {}

class GeofenceLoaded extends GeofenceState {
  final List<GeofenceEntity> geofences;

  GeofenceLoaded(this.geofences);

  // Only active geofences should be rendered on the map
  List<GeofenceEntity> get activeGeofences =>
      geofences.where((g) => g.isActive).toList();
}

class GeofenceError extends GeofenceState {
  final String message;
  GeofenceError(this.message);
}
