import 'dart:async';
import 'dart:convert';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import '../../../core/utils/app_logger.dart';
import '../../network/api_constants.dart';
import '../../models/analytics/analytics_model.dart';

class AnalyticsRealtimeDataSource {
  PusherChannelsClient? _client;
  PublicChannel? _channel;
  StreamSubscription<ChannelReadEvent>? _eventSub;
  StreamSubscription? _connectionSub;
  String? _boundImei;
  bool _connected = false;

  final _controller = StreamController<AnalyticsModel>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<AnalyticsModel> get telemetryStream => _controller.stream;
  Stream<String> get errors => _errorController.stream;

  void _ensureClient() {
    if (_client != null) return;
    final options = PusherChannelsOptions.fromHost(
      scheme: ApiConstants.soketiUseTLS ? 'wss' : 'ws',
      host: ApiConstants.soketiHost,
      key: ApiConstants.soketiKey,
      port: ApiConstants.soketiPort,
      shouldSupplyMetadataQueries: true,
      metadata: PusherChannelsOptionsMetadata.byDefault(),
    );
    _client = PusherChannelsClient.websocket(
      options: options,
      // reconnectTries: 3,
      connectionErrorHandler: (exception, trace, refresh) {
        AppLogger.d('AnalyticsRealtime', 'Connection error: $exception');
        _errorController.add(exception.toString());
      },
    );
    _connectionSub = _client!.onConnectionEstablished.listen((_) {
      _connected = true;
      AppLogger.d('AnalyticsRealtime', 'Connected');
      if (_boundImei != null) _bindChannel(_boundImei!);
    });
    _client!.connect();
  }

  void _bindChannel(String imei) {
    _eventSub?.cancel();
    _channel ??= _client!.publicChannel(
      'device-$imei',
    ); // CHANGED: reuse, don't recreate
    _eventSub = _channel!.bind('telemetry').listen((event) {
      try {
        final raw = event.data;
        final json = raw is String
            ? jsonDecode(raw) as Map<String, dynamic>
            : raw as Map<String, dynamic>;
        AppLogger.d(
          'AnalyticsRealtime',
          'Telemetry received: imei=${json['imei']}',
        );
        _controller.add(AnalyticsModel.fromJson(json));
      } catch (e) {
        AppLogger.d('AnalyticsRealtime', 'Parse error: $e');
      }
    });
    _channel!.subscribe();
  }

  Future<void> subscribeTelemetry(String imei) async {
    if (_boundImei == imei) return;
    _boundImei = imei;
    _ensureClient();
    if (_connected) _bindChannel(imei);
  }

  Future<void> unsubscribe() async {
    await _eventSub?.cancel();
    _channel?.unsubscribe();
    _channel = null;
    _boundImei = null;
  }
}
