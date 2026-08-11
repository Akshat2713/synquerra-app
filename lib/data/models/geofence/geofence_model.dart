import '../../../domain/entities/geofence/geofence_entity.dart';

class GeofenceModel {
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

  const GeofenceModel({
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

  factory GeofenceModel.fromJson(Map<String, dynamic> json) => GeofenceModel(
    id: json['id'] as String? ?? '',
    imei: json['imei'] as String? ?? '',
    geofenceName: json['geofence_name'] as String? ?? '',
    geofenceNumber: json['geofence_number'] as String? ?? '-1',
    geofenceId: json['geofence_id'] as String? ?? '',
    isActive: json['is_active'] as bool? ?? false,
    coordinates:
        (json['coordinates'] as List<dynamic>?)
            ?.map(
              (e) => Coordinate(
                lat: (e['lat'] as num).toDouble(),
                lng: (e['lng'] as num).toDouble(),
              ),
            )
            .toList() ??
        [],
    geofenceColor: json['geofence_color'] as String? ?? '',
    isSyncToDevice: json['is_sync_to_device'] as bool? ?? false,
    locality: json['locality'] as String?,
    block: json['block'] as String?,
    district: json['district'] as String?,
    state: json['state'] as String?,
    postcode: json['postcode'] as String?,
    country: json['country'] as String?,
    landmark: json['landmark'] as String?,
    address: json['address'] as String?,
    createdAt: json['created_at'] as String? ?? '',
    updatedAt: json['updated_at'] as String? ?? '',
  );

  GeofenceEntity toEntity() => GeofenceEntity(
    id: id,
    imei: imei,
    geofenceName: geofenceName,
    geofenceNumber: geofenceNumber,
    geofenceId: geofenceId,
    isActive: isActive,
    coordinates: coordinates,
    geofenceColor: geofenceColor,
    isSyncToDevice: isSyncToDevice,
    locality: locality,
    block: block,
    district: district,
    state: state,
    postcode: postcode,
    country: country,
    landmark: landmark,
    address: address,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
