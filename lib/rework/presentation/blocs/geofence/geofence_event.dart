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
