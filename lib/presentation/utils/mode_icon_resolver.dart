import 'package:flutter/material.dart';
import '../../domain/entities/modes/mode_entity.dart';

class ModeIconResolver {
  ModeIconResolver._();

  static IconData resolve(ModeEntity mode) {
    switch (mode.name.toLowerCase()) {
      case 'normal':
        return Icons.radio_button_checked_rounded;
      case 'battery saving':
      case 'battery':
        return Icons.battery_saver_rounded;
      case 'live':
        return Icons.sensors_rounded;
      case 'private':
        return Icons.visibility_off_rounded;
      case 'do not track':
        return Icons.do_not_disturb_on_rounded;
      case 'safe location ':
        return Icons.home;
      default:
        return Icons.tune_rounded;
    }
  }
}
