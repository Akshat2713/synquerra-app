import 'dart:async';
import 'dart:convert';

import 'package:dart_pusher_channels/dart_pusher_channels.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/realtime/device_event.dart';
import '../../models/realtime/device_alert_model.dart';
import '../../models/realtime/mode_change_model.dart';
import 'realtime_connection.dart';

class DeviceEventsRealtimeDataSource {
  DeviceEventsRealtimeDataSource(this._conn);
  final RealtimeConnection _conn;

  StreamController<DeviceEvent>? _ctrl;
  final _subs = <StreamSubscription>[];
  String? _channel;

  Stream<DeviceEvent> watchUser(String userId) {
    stop();
    final name = _channel = 'user-$userId';
    AppLogger.d('DeviceEvents', 'watchUser($userId) → $name');
    final ctrl = _ctrl = StreamController<DeviceEvent>.broadcast();
    final ch = _conn.acquire(name);

    _listen(
      ch,
      'mode_change',
      ctrl,
      (j) => ModeChangeModel.fromJson(j).toEvent(),
    );
    _listen(
      ch,
      'device_alert',
      ctrl,
      (j) => AlertReceived(DeviceAlertModel.fromJson(j).toEntity()),
    );
    return ctrl.stream;
  }

  void _listen(
    PublicChannel ch,
    String event,
    StreamController<DeviceEvent> ctrl,
    DeviceEvent Function(Map<String, dynamic>) parse,
  ) {
    AppLogger.d('DeviceEvents', 'bound event: $event');
    _subs.add(
      ch.bind(event).listen((e) {
        AppLogger.d('DeviceEvents', '[$event] received: ${e.data}');
        try {
          final d = e.data;
          final m = d is String ? jsonDecode(d) : d;
          if (m is! Map) {
            AppLogger.d(
              'DeviceEvents',
              '[$event] skipped, payload not a Map: ${m.runtimeType}',
            );
            return;
          }
          final parsed = parse(Map<String, dynamic>.from(m));
          AppLogger.d('DeviceEvents', '[$event] parsed → ${_describe(parsed)}');
          ctrl.add(parsed);
        } catch (err, st) {
          AppLogger.e('DeviceEvents', '[$event] PARSE FAILED', err, st);
        }
      }),
    );
  }

  String _describe(DeviceEvent e) => switch (e) {
    ModeChanged(:final imei, :final modeName) =>
      'ModeChanged($imei, $modeName)',
    AlertReceived(:final alert) =>
      'Alert(${alert.code}, ${alert.severity}, "${alert.title}")',
  };

  void stop() {
    AppLogger.d('DeviceEvents', 'stop() channel=$_channel');
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    _ctrl?.close();
    _ctrl = null;
    if (_channel != null) _conn.release(_channel!);
    _channel = null;
  }
}
