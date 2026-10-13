import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';

import '../utils/app_logger.dart';

class SosAlarmService {
  static const _asset = 'assets/audio/sos_siren.mp3';
  static const _tag = 'SosAlarmService';

  final AudioPlayer _player = AudioPlayer();
  bool _ringing = false;
  bool _loaded = false;

  Future<void> start() async {
    if (_ringing) return;
    _ringing = true;

    try {
      if (!_loaded) {
        await _player.setAsset(_asset);
        await _player.setLoopMode(LoopMode.one);
        _loaded = true;
      }
      if (!_ringing) return; // stop() called while loading

      await _player.seek(Duration.zero);
      _player.play(); // not awaited: future only completes when playback ends

      if (await Vibration.hasVibrator() == true && _ringing) {
        Vibration.vibrate(pattern: [0, 800, 400], repeat: 0);
      }
    } catch (e) {
      AppLogger.d(_tag, 'start failed: $e');
    }
  }

  Future<void> stop() async {
    if (!_ringing) return;
    _ringing = false;

    try {
      await _player.pause();
      await _player.seek(Duration.zero);
      await Vibration.cancel();
    } catch (e) {
      AppLogger.d(_tag, 'stop failed: $e');
    }
  }
}
