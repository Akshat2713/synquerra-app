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
  final String? locality;
  final String? block;
  final String? district;
  final String? state;
  final String? postcode;
  final String? country;
  final String? landmark;
  final String? address;

  const GeofenceCreate({
    required this.deviceId,
    required this.name,
    required this.isActive,
    required this.coordinates,
    required this.color,
    this.locality,
    this.block,
    this.district,
    this.state,
    this.postcode,
    this.country,
    this.landmark,
    this.address,
  });

  @override
  List<Object?> get props => [
    deviceId,
    name,
    isActive,
    coordinates,
    color,
    locality,
    block,
    district,
    state,
    postcode,
    country,
    landmark,
    address,
  ];
}

class GeofenceEdit extends GeofenceEvent {
  final String deviceId;
  final String geofenceId;
  final String name;
  final bool isActive;
  final List<Coordinate> coordinates;
  final String color;
  final String geofenceNumber;
  final String? locality;
  final String? block;
  final String? district;
  final String? state;
  final String? postcode;
  final String? country;
  final String? landmark;
  final String? address;

  const GeofenceEdit({
    required this.deviceId,
    required this.geofenceId,
    required this.name,
    required this.isActive,
    required this.coordinates,
    required this.color,
    required this.geofenceNumber,
    this.locality,
    this.block,
    this.district,
    this.state,
    this.postcode,
    this.country,
    this.landmark,
    this.address,
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
    locality,
    block,
    district,
    state,
    postcode,
    country,
    landmark,
    address,
  ];
}

class GeofenceDelete extends GeofenceEvent {
  final String deviceId;
  final String geofenceId;
  const GeofenceDelete({required this.deviceId, required this.geofenceId});
  @override
  List<Object?> get props => [deviceId, geofenceId];
}
