import 'package:equatable/equatable.dart';

class AnalyticsEntity extends Equatable {
  final String id;
  final String imei;
  final String? geoid;
  final String? packet;
  final double? latitude;
  final double? longitude;
  final double? speed;
  final int? battery;
  final int? signal;
  final String? temperature;
  final String? phone1;
  final String? phone2;
  final String? alert;
  final DateTime? deviceTimestamp;
  final String? type;
  final String? geofenceName;
  final String? formattedAddress;

  const AnalyticsEntity({
    required this.id,
    required this.imei,
    this.geoid,
    this.packet,
    this.latitude,
    this.longitude,
    this.speed,
    this.battery,
    this.signal,
    this.temperature,
    this.phone1,
    this.phone2,
    this.alert,
    this.deviceTimestamp,
    this.type,
    this.geofenceName,
    this.formattedAddress,
  });

  bool get hasLocation =>
      latitude != null &&
      longitude != null &&
      latitude != 0.0 &&
      longitude != 0.0;

  String? get userAddress {
    if (geofenceName != null &&
        geofenceName!.isNotEmpty &&
        geofenceName!.trim().toLowerCase() != 'outside' &&
        geofenceName!.trim().toLowerCase() != 'gps_error') {
      return geofenceName;
    }
    return formattedAddress;
  }

  @override
  List<Object?> get props => [
    id,
    imei,
    geoid,
    packet,
    latitude,
    longitude,
    speed,
    battery,
    signal,
    temperature,
    phone1,
    phone2,
    alert,
    deviceTimestamp,
    type,
    geofenceName,
    formattedAddress,
  ];
}
