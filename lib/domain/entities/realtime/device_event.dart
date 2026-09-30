import '../alerts/alert_entity.dart';

sealed class DeviceEvent {
  const DeviceEvent();
}

class ModeChanged extends DeviceEvent {
  final String imei;
  final String deviceId;
  final String modeId;
  final String modeName;
  const ModeChanged({
    required this.imei,
    required this.deviceId,
    required this.modeId,
    required this.modeName,
  });
}

class AlertReceived extends DeviceEvent {
  final AlertEntity alert;
  const AlertReceived(this.alert);
}
