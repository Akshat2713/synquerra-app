import 'package:equatable/equatable.dart';

class Coordinate extends Equatable {
  final double lat;
  final double lng;

  const Coordinate({required this.lat, required this.lng});

  @override
  List<Object?> get props => [lat, lng];
}

class GeofenceEntity extends Equatable {
  final String id;
  final String imei;
  final String geofenceName;
  final String geofenceNumber;
  final String geofenceId;
  final bool isActive;
  final List<Coordinate> coordinates;
  final String geofenceColor;
  final bool isSyncToDevice;
  final String? locality;
  final String? block;
  final String? district;
  final String? state;
  final String? postcode;
  final String? country;
  final String? landmark;
  final String? address;
  final String createdAt;
  final String updatedAt;

  const GeofenceEntity({
    required this.id,
    required this.imei,
    required this.geofenceName,
    required this.geofenceNumber,
    required this.geofenceId,
    required this.isActive,
    required this.coordinates,
    required this.geofenceColor,
    required this.isSyncToDevice,
    this.locality,
    this.block,
    this.district,
    this.state,
    this.postcode,
    this.country,
    this.landmark,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isEnabled => isActive && isSyncToDevice;

  @override
  List<Object?> get props => [
    id,
    imei,
    geofenceName,
    geofenceNumber,
    geofenceId,
    isActive,
    coordinates,
    geofenceColor,
    isSyncToDevice,
    locality,
    block,
    district,
    state,
    postcode,
    country,
    landmark,
    address,
    createdAt,
    updatedAt,
  ];
}
