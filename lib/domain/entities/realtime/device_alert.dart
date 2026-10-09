class AlertCodes {
  AlertCodes._();
  static const charging = 'A1001';
  static const sos = 'A1002';
}

class DeviceAlert {
  final String id;
  final String code;
  final String title;
  final String severity; // critical | warning | advisory
  final String description;
  final String imei;
  final String deviceId;
  final DateTime timestamp;

  const DeviceAlert({
    required this.id,
    required this.code,
    required this.title,
    required this.severity,
    required this.description,
    required this.imei,
    required this.deviceId,
    required this.timestamp,
  });

  bool get isCritical => severity == 'critical';
  bool get isSos => code == AlertCodes.sos;
}
