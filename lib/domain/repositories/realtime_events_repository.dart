import '../entities/realtime/device_event.dart';

abstract class RealtimeEventsRepository {
  Stream<DeviceEvent> watchDeviceEvents(String imei);
  Future<void> stopWatching();
}
