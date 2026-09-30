import 'dart:async';
import 'dart:convert';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/analytics/analytics_model.dart';
import 'realtime_connection.dart';

class AnalyticsRealtimeDataSource {
  final RealtimeConnection _conn;
  AnalyticsRealtimeDataSource(this._conn);

  StreamSubscription<ChannelReadEvent>? _eventSub;
  String? _boundImei;

  final _controller = StreamController<AnalyticsModel>.broadcast();

  Stream<AnalyticsModel> get telemetryStream => _controller.stream;
  Stream<String> get errors => _conn.errors;

  Future<void> subscribeTelemetry(String imei) async {
    if (_boundImei == imei) return;
    await unsubscribe();
    _boundImei = imei;
    final ch = _conn.acquire('device-$imei');
    _eventSub = ch.bind('telemetry').listen((event) {
      try {
        final raw = event.data;
        final json = raw is String
            ? jsonDecode(raw) as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        _controller.add(AnalyticsModel.fromJson(json));
      } catch (e) {
        AppLogger.d('AnalyticsRealtime', 'Parse error: $e');
      }
    });
  }

  Future<void> unsubscribe() async {
    await _eventSub?.cancel();
    _eventSub = null;
    if (_boundImei != null) _conn.release('device-$_boundImei');
    _boundImei = null;
  }
}
