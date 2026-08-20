// lib/presentation/blocs/geofence/geofence_state.dart

part of 'geofence_bloc.dart';

abstract class GeofenceState extends BaseState {
  const GeofenceState();
}

class GeofenceInitial extends GeofenceState {
  const GeofenceInitial();
}

class GeofenceLoading extends GeofenceState with LoadingState {
  const GeofenceLoading();
}

class GeofenceLoaded extends GeofenceState {
  final List<GeofenceEntity> geofences;

  const GeofenceLoaded(this.geofences);

  List<GeofenceEntity> get activeGeofences =>
      geofences.where((g) => g.isActive).toList();

  @override
  List<Object?> get props => [geofences];
}

class GeofenceError extends GeofenceState with ErrorState {
  @override
  final String message;

  const GeofenceError(this.message);

  @override
  List<Object?> get props => [message];
}

class GeofenceOperationLoading extends GeofenceState with LoadingState {
  const GeofenceOperationLoading();
}

class GeofenceCreated extends GeofenceState {
  final GeofenceEntity geofence;

  const GeofenceCreated(this.geofence);

  @override
  List<Object?> get props => [geofence];
}

class GeofenceEdited extends GeofenceState {
  final GeofenceEntity geofence;

  const GeofenceEdited(this.geofence);

  @override
  List<Object?> get props => [geofence];
}

class GeofenceDeleted extends GeofenceState {
  const GeofenceDeleted();
}

class GeofenceOperationError extends GeofenceState with ErrorState {
  @override
  final String message;

  const GeofenceOperationError(this.message);

  @override
  List<Object?> get props => [message];
}
