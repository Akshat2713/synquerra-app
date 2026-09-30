import 'dart:async';
import '../../domain/entities/realtime/device_event.dart';
import '../../domain/repositories/realtime_events_repository.dart';
import '../datasources/realtime/device_events_realtime_datasource.dart';

class RealtimeEventsRepositoryImpl implements RealtimeEventsRepository {
  final DeviceEventsRealtimeDataSource _ds;
  RealtimeEventsRepositoryImpl(this._ds);

  final _out = StreamController<DeviceEvent>.broadcast();
  StreamSubscription? _modeSub;
  StreamSubscription? _alertSub;

  @override
  Stream<DeviceEvent> watchDeviceEvents(String imei) {
    unawaited(_ds.subscribe(imei));
    _modeSub ??= _ds.modeChanges.listen((m) => _out.add(m.toEvent()));
    _alertSub ??= _ds.alerts.listen(
      (a) => _out.add(AlertReceived(a.toEntity())),
    );
    return _out.stream;
  }

  @override
  Future<void> stopWatching() async {
    await _modeSub?.cancel();
    await _alertSub?.cancel();
    _modeSub = _alertSub = null;
    await _ds.unsubscribe();
  }
}
