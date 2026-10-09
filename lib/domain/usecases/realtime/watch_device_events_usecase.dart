import '../../entities/realtime/device_event.dart';
import '../../repositories/realtime_events_repository.dart';

class WatchDeviceEventsUseCase {
  WatchDeviceEventsUseCase(this._repo);
  final RealtimeEventsRepository _repo;

  Stream<DeviceEvent> call(String userId) => _repo.watchUserEvents(userId);
  void stop() => _repo.stopWatching();
}
