import '../entities/realtime/device_event.dart';

abstract class RealtimeEventsRepository {
  Stream<DeviceEvent> watchUserEvents(String userId);
  void stopWatching();
}
