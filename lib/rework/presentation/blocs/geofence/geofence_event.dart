part of 'geofence_bloc.dart';

abstract class GeofenceEvent {}

class GeofenceLoad extends GeofenceEvent {
  final String imei;
  GeofenceLoad(this.imei);
}
