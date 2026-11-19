import '../../../domain/entities/realtime/device_alert.dart';

class DeviceAlertModel {
  final String id, code, title, severity, description, imei, deviceId;
  final DateTime timestamp;

  const DeviceAlertModel({
    required this.id,
    required this.code,
    required this.title,
    required this.severity,
    required this.description,
    required this.imei,
    required this.deviceId,
    required this.timestamp,
  });

  factory DeviceAlertModel.fromJson(Map<String, dynamic> j) {
    final data = j['data'] as Map<String, dynamic>?;
    return DeviceAlertModel(
      id: data?['_id'] as String? ?? '',
      code: j['code'] as String? ?? data?['code'] as String? ?? '',
      title: j['title'] as String? ?? data?['title'] as String? ?? 'Alert',
      severity:
          j['severity'] as String? ??
          data?['severity'] as String? ??
          'advisory',
      description:
          j['description'] as String? ?? data?['description'] as String? ?? '',
      imei: j['imei'] as String? ?? '',
      deviceId: j['device_id'] as String? ?? '',
      timestamp:
          DateTime.tryParse(j['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }

  DeviceAlert toEntity() => DeviceAlert(
    id: id,
    code: code,
    title: title,
    severity: severity,
    description: description,
    imei: imei,
    deviceId: deviceId,
    timestamp: timestamp,
  );
}
