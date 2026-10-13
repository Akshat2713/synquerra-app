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
  // final bool isSyncToDevice;
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
    // required this.isSyncToDevice,
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
    // isSyncToDevice,
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
  final String id;
  final String name;
  final bool isActive;
  // final bool isSyncToDevice;
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
    required this.id,
    required this.name,
    required this.isActive,
    // required this.isSyncToDevice,
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
    id,
    name,
    isActive,
    // isSyncToDevice,
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
  final String id;
  const GeofenceDelete({required this.deviceId, required this.id});
  @override
  List<Object?> get props => [deviceId, id];
}

class GeofenceAssign extends GeofenceEvent {
  final String deviceId; // Required to reload geofences after success
  final String geofenceId;
  final String geofenceNumber;

  const GeofenceAssign({
    required this.deviceId,
    required this.geofenceId,
    required this.geofenceNumber,
  });

  @override
  List<Object?> get props => [deviceId, geofenceId, geofenceNumber];
}

class GeofenceUnassign extends GeofenceEvent {
  final String deviceId; // Required to reload geofences after success
  final String geofenceNumber;

  const GeofenceUnassign({
    required this.deviceId,
    required this.geofenceNumber,
  });

  @override
  List<Object?> get props => [deviceId, geofenceNumber];
}
