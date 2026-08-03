import '../../domain/entities/device/device_entity.dart';

/// Shows the carrier's name if the device is assigned to someone;
/// otherwise falls back to the current logged-in user (device owner).
String ownerDisplayName(DeviceEntity device, String currentUserFullName) {
  final carrier = device.carrier;
  if (carrier == null) return currentUserFullName;
  final name = '${carrier.firstName} ${carrier.lastName}'.trim();
  return name.isEmpty ? currentUserFullName : name;
}
