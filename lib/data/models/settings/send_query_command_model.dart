import '../../../domain/entities/settings/send_query_command_entity.dart';

class SendQueryCommandModel {
  final String deviceId;
  final String status;
  final QueryPacketModel? packet;

  const SendQueryCommandModel({
    required this.deviceId,
    required this.status,
    this.packet,
  });

  factory SendQueryCommandModel.fromJson(Map<String, dynamic> json) {
    return SendQueryCommandModel(
      deviceId: json['device_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      packet: json['packet'] != null && json['packet'] is Map<String, dynamic>
          ? QueryPacketModel.fromJson(json['packet'] as Map<String, dynamic>)
          : null,
    );
  }

  SendQueryCommandEntity toEntity() => SendQueryCommandEntity(
    deviceId: deviceId,
    status: status,
    packet: packet?.toEntity(),
  );
}

class QueryPacketModel {
  final String? packet;
  final String? imei;
  final String? latitude;
  final String? longitude;
  final String? speed;
  final String? temperature;
  final String? timestamp;
  final String? battery;
  final String? signal;
  final String? gpsStrength;
  final String? interval;
  final String? geoid;

  const QueryPacketModel({
    this.packet,
    this.imei,
    this.latitude,
    this.longitude,
    this.speed,
    this.temperature,
    this.timestamp,
    this.battery,
    this.signal,
    this.gpsStrength,
    this.interval,
    this.geoid,
  });

  factory QueryPacketModel.fromJson(Map<String, dynamic> json) {
    return QueryPacketModel(
      packet: json['packet'] as String?,
      imei: json['imei']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      speed: json['speed'] as String?,
      temperature: json['temperature'] as String?,
      timestamp: json['timestamp'] as String?,
      // Handles both uppercase (from API: "Battery", "Signal", "GPSStrength", "Geoid") and lowercase
      battery: json['Battery']?.toString() ?? json['battery']?.toString(),
      signal: json['Signal']?.toString() ?? json['signal']?.toString(),
      gpsStrength:
          json['GPSStrength'] as String? ?? json['gps_strength'] as String?,
      interval: json['interval']?.toString(),
      geoid: json['Geoid'] as String? ?? json['geoid'] as String?,
    );
  }

  QueryPacketEntity toEntity() {
    return QueryPacketEntity(
      packet: packet,
      imei: imei,
      latitude: latitude != null ? double.tryParse(latitude!) : null,
      longitude: longitude != null ? double.tryParse(longitude!) : null,
      speed: speed,
      temperature: temperature,
      timestamp: timestamp != null ? DateTime.tryParse(timestamp!) : null,
      battery: battery != null ? int.tryParse(battery!) : null,
      signal: signal != null ? int.tryParse(signal!) : null,
      gpsStrength: gpsStrength,
      interval: interval,
      geoid: geoid,
    );
  }
}
