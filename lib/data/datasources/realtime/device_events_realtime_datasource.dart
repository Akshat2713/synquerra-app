import 'dart:async';
import 'dart:convert';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/alerts/alert_model.dart';
import '../../models/realtime/mode_change_model.dart';
import 'realtime_connection.dart';

class DeviceEventsRealtimeDataSource {
  final RealtimeConnection _conn;
  DeviceEventsRealtimeDataSource(this._conn);

  final _mode = StreamController<ModeChangeModel>.broadcast();
  final _alert = StreamController<AlertModel>.broadcast();
  StreamSubscription<ChannelReadEvent>? _modeSub;
  StreamSubscription<ChannelReadEvent>? _alertSub;
  String? _imei;

  Stream<ModeChangeModel> get modeChanges => _mode.stream;
  Stream<AlertModel> get alerts => _alert.stream;

  Future<void> subscribe(String imei) async {
    if (_imei == imei) return;
    await unsubscribe();
    _imei = imei;
    _modeSub = _listen(
      _conn.acquire('mode-$imei'),

      'mode_change',
      ModeChangeModel.fromJson,
      _mode,
    );
    _alertSub = _listen(
      _conn.acquire('alert-$imei'),
      'alert',
      AlertModel.fromJson,
      _alert,
    );
  }

  StreamSubscription<ChannelReadEvent> _listen<T>(
    PublicChannel ch,
    String event,
    T Function(Map<String, dynamic>) parse,
    StreamController<T> out,
  ) {
    return ch.bind(event).listen((e) {
      try {
        final raw = e.data;
        final json = raw is String
            ? jsonDecode(raw) as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        out.add(parse(json));
        final parsed = parse(json);
        AppLogger.d('DeviceEventsRealtime', '$event parsed OK');
        out.add(parsed);
      } catch (err, st) {
        AppLogger.d('DeviceEventsRealtime', '$event parse error: $err\n$st');
      }
    });
  }

  Future<void> unsubscribe() async {
    await _modeSub?.cancel();
    await _alertSub?.cancel();
    _modeSub = _alertSub = null;
    if (_imei != null) {
      _conn.release('mode-$_imei');
      _conn.release('alert-$_imei');
    }
    _imei = null;
  }
}
