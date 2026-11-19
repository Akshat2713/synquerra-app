import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';
import '../utils/app_logger.dart';
// import 'package:flutter/services.dart' show rootBundle;

class SosAlarmService {
  static const _asset = 'assets/audio/sos_siren.wav';
  static const _tag = 'SosAlarmService';
  final AudioPlayer _player = AudioPlayer();
  bool _ringing = false;
  bool _loaded = false;

  Future<void> start() async {
    AppLogger.d(_tag, 'start() called, _ringing=$_ringing, _loaded=$_loaded');
    if (_ringing) {
      AppLogger.d(_tag, 'start() skipped: already ringing');
      return;
    }
    _ringing = true;
    try {
      // final bytes = await rootBundle.load(_asset);
      // AppLogger.d(
      //   _tag,
      //   'asset bytes=${bytes.lengthInBytes}, '
      //   'head=${bytes.buffer.asUint8List().take(8).toList()}',
      // );
      if (!_loaded) {
        final d = await _player.setAsset(_asset);
        AppLogger.d(_tag, 'setAsset OK, duration=$d');
        await _player.setLoopMode(LoopMode.one);
        _loaded = true;
      }
      if (!_ringing) {
        AppLogger.d(_tag, 'stop() raced start(); aborting before play');
        return;
      }
      await _player.setVolume(1.0);
      await _player.seek(Duration.zero);
      _player.play().catchError((e) {
        AppLogger.d(_tag, 'play() error: $e');
      });
      AppLogger.d(
        _tag,
        'play() issued, playing=${_player.playing}, '
        'state=${_player.processingState}, vol=${_player.volume}',
      );
      if (await Vibration.hasVibrator() == true && _ringing) {
        Vibration.vibrate(pattern: [0, 800, 400], repeat: 0);
        AppLogger.d(_tag, 'vibrate started');
      }
    } catch (e, st) {
      _ringing = false;
      AppLogger.d(_tag, 'start failed: $e\n$st');
    }
  }

  Future<void> stop() async {
    AppLogger.d(_tag, 'stop() called, _ringing=$_ringing');
    if (!_ringing) return;
    _ringing = false;
    try {
      await _player.pause();
      await _player.seek(Duration.zero);
      await Vibration.cancel();
      AppLogger.d(_tag, 'stopped');
    } catch (e) {
      AppLogger.d(_tag, 'stop failed: $e');
    }
  }
}
