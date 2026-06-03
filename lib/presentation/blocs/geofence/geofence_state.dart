part of 'geofence_bloc.dart';

abstract class GeofenceState extends Equatable {
  const GeofenceState();

  @override
  List<Object?> get props => [];
}

class GeofenceInitial extends GeofenceState {
  const GeofenceInitial();
}

class GeofenceLoading extends GeofenceState {
  const GeofenceLoading();
}

class GeofenceLoaded extends GeofenceState {
  final List<GeofenceEntity> geofences;

  const GeofenceLoaded(this.geofences);

  // Only active geofences should be rendered on the map
  List<GeofenceEntity> get activeGeofences =>
      geofences.where((g) => g.isActive).toList();

  @override
  List<Object?> get props => [geofences];
}

class GeofenceError extends GeofenceState {
  final String message;

  const GeofenceError(this.message);

  @override
  List<Object?> get props => [message];
}

class GeofenceOperationLoading extends GeofenceState {
  const GeofenceOperationLoading();
}

class GeofenceCreated extends GeofenceState {
  final GeofenceEntity geofence;
  const GeofenceCreated(this.geofence);
  @override
  List<Object?> get props => [geofence];
}

class GeofenceDeleted extends GeofenceState {
  const GeofenceDeleted();
}

class GeofenceOperationError extends GeofenceState {
  final String message;
  const GeofenceOperationError(this.message);
  @override
  List<Object?> get props => [message];
}
