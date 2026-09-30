import '../../entities/realtime/device_event.dart';
import '../../repositories/realtime_events_repository.dart';

class WatchDeviceEventsUseCase {
  final RealtimeEventsRepository _repo;
  WatchDeviceEventsUseCase(this._repo);

  Stream<DeviceEvent> call(String imei) => _repo.watchDeviceEvents(imei);
  Future<void> stop() => _repo.stopWatching();
}
