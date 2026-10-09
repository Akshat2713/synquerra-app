import '../../domain/entities/realtime/device_event.dart';
import '../../domain/repositories/realtime_events_repository.dart';
import '../datasources/realtime/device_events_realtime_datasource.dart';

class RealtimeEventsRepositoryImpl implements RealtimeEventsRepository {
  RealtimeEventsRepositoryImpl(this._ds);
  final DeviceEventsRealtimeDataSource _ds;

  @override
  Stream<DeviceEvent> watchUserEvents(String userId) => _ds.watchUser(userId);

  @override
  void stopWatching() => _ds.stop();
}
