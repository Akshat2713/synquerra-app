import '../../domain/entities/alerts/alert_entity.dart';
import '../../domain/entities/device/device_entity.dart';

/// Central place for matching alerts to devices.
/// TODO: switch `a.imei == device.imei` to `a.deviceId == device.id`
/// once the alerts API starts returning deviceId.
List<AlertEntity> alertsForDevice(
  DeviceEntity device,
  List<AlertEntity> alerts,
) {
  return alerts.where((a) => a.imei == device.imei).toList();
}
