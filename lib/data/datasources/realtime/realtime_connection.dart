import 'dart:async';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import '../../../core/utils/app_logger.dart';
import '../../network/api_constants.dart';

class RealtimeConnection {
  PusherChannelsClient? _client;
  StreamSubscription? _connSub;
  bool _connected = false;

  final _channels = <String, PublicChannel>{};
  final _errors = StreamController<String>.broadcast();
  Stream<String> get errors => _errors.stream;

  void _ensureClient() {
    if (_client != null) return;
    _client = PusherChannelsClient.websocket(
      options: PusherChannelsOptions.fromHost(
        scheme: ApiConstants.soketiUseTLS ? 'wss' : 'ws',
        host: ApiConstants.soketiHost,
        key: ApiConstants.soketiKey,
        port: ApiConstants.soketiPort,
        shouldSupplyMetadataQueries: true,
        metadata: PusherChannelsOptionsMetadata.byDefault(),
      ),
      connectionErrorHandler: (e, _, __) {
        AppLogger.d('Realtime', 'Connection error: $e');
        _connected = false;
        _errors.add(e.toString());
      },
    );
    // Fires on first connect AND every reconnect, so all channels resubscribe.
    _connSub = _client!.onConnectionEstablished.listen((_) {
      _connected = true;
      AppLogger.d('Realtime', 'Connected');
      for (final c in _channels.values) {
        AppLogger.d('Realtime', '↻ resubscribe on connect');
        c.subscribeIfNotUnsubscribed();
      }
    });
    _client!.connect();
  }

  /// Returns the channel (cached by name) and subscribes when possible.
  PublicChannel acquire(String name) {
    _ensureClient();
    final ch = _channels.putIfAbsent(name, () {
      AppLogger.d('Realtime', '+ channel created: $name');
      final c = _client!.publicChannel(name);
      // RAW: every event on this channel, whatever its name
      c.bindToAll().listen(
        (e) => AppLogger.d(
          'Realtime',
          '[$name] RAW event=${e.name} data=${e.data}',
        ),
      );
      c.whenSubscriptionSucceeded().listen(
        (_) => AppLogger.d('Realtime', '✔ SUBSCRIBED: $name'),
      );
      return c;
    });
    if (_connected) {
      AppLogger.d('Realtime', '→ subscribing: $name');
      ch.subscribeIfNotUnsubscribed();
    } else {
      AppLogger.d('Realtime', '… $name queued, socket not connected yet');
    }
    return ch;
  }

  void release(String name) {
    final ch = _channels.remove(name);
    if (ch == null) {
      AppLogger.d('Realtime', '✘ release($name) ignored, not held');
      return;
    }
    AppLogger.d('Realtime', '✘ UNSUBSCRIBED: $name');
    ch.unsubscribe();
  }

  Future<void> dispose() async {
    AppLogger.d('Realtime', 'dispose(): channels=${_channels.keys.toList()}');
    for (final n in _channels.keys.toList()) {
      release(n);
    }
    await _connSub?.cancel();
    _client?.disconnect();
    _client = null;
    _connected = false;
    AppLogger.d('Realtime', 'Disconnected');
  }
}
