import 'package:flutter/material.dart';
import '../../domain/entities/modes/mode_entity.dart';

class ModeIconResolver {
  ModeIconResolver._();

  static IconData resolve(ModeEntity mode) {
    final name = mode.name.toLowerCase();

    if (name.contains('sos')) return Icons.sos_rounded;
    if (name.contains('privacy')) return Icons.privacy_tip_rounded;
    if (name.contains('incognito')) return Icons.visibility_off_rounded;
    if (name.contains('battery')) return Icons.battery_saver_rounded;
    if (name.contains('live')) return Icons.sensors_rounded;
    if (name.contains('do not track')) return Icons.do_not_disturb_on_rounded;
    if (name.contains('safe location')) return Icons.home_rounded;
    if (name.contains('normal') || name.contains('tracking')) {
      return Icons.radio_button_checked_rounded;
    }

    return Icons.tune_rounded; // fallback for unrecognized modes
  }
}
