// lib/presentation/utils/app_icons.dart
import 'package:flutter/material.dart';
import '../../domain/entities/alerts/alert_entity.dart';
import '../../domain/entities/modes/mode_entity.dart';
import 'colour_util.dart';

/// Single place that decides every icon in the app.
/// Screens never reference `Icons.xxx` directly. They call this instead.
///
/// Value-driven icons (battery, temperature, alert) read their thresholds
/// from colour_util.dart, so the icon and its color always agree. Pair them:
///   Icon(AppIcons.battery(level), color: batteryColor(level))
class AppIcons {
  AppIcons._();

  // ===================================================== data-driven icons

  // TODO(logic): modes are matched by name text, which breaks if a mode is
  // renamed or localized. Match on a mode id/type from the entity instead.
  static IconData mode(ModeEntity mode) {
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

  /// Pair with [batteryColor].
  static IconData battery(int? level) {
    if (level == null) return Icons.battery_unknown_rounded;
    if (level <= kBatteryCritical) return Icons.battery_alert_rounded;
    if (level <= kBatteryLow) return Icons.battery_3_bar_rounded;
    if (level <= kBatteryHigh) return Icons.battery_5_bar_rounded;
    return Icons.battery_full_rounded;
  }

  /// Pair with [temperatureColor]. Accepts num, numeric String or null/'NA'.
  static IconData temperature(dynamic temp) {
    final parsed = parseTemperature(temp);
    if (parsed == null) return Icons.thermostat_rounded;
    if (parsed <= kTempWarnLow) return Icons.ac_unit_rounded;
    if (parsed >= kTempWarnHigh) return Icons.local_fire_department_rounded;
    return Icons.thermostat_rounded;
  }

  /// Pair with [alertColor].
  static IconData alert(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Icons.error_rounded;
      case AlertSeverity.warning:
        return Icons.warning_amber_rounded;
      case AlertSeverity.advisory:
        return Icons.info_rounded;
    }
  }

  // ========================================================= map controls
  static const IconData liveQuery = Icons.location_searching_rounded;
  static const IconData recenterDevice = Icons.my_location_rounded;
  static const IconData recenterUser = Icons.phone_android_rounded;
  static const IconData userLoading = Icons.hourglass_bottom_rounded;
  static const IconData compass = Icons.explore_rounded;
  static const IconData zoomIn = Icons.add_rounded;
  static const IconData zoomOut = Icons.remove_rounded;
  static const IconData userMarker = Icons.person_rounded;
  static const IconData directionMarker = Icons.navigation_rounded;
  static const IconData address = Icons.location_on_rounded;

  // ============================================================== timeline
  static const IconData previous = Icons.skip_previous_rounded;
  static const IconData next = Icons.skip_next_rounded;
  static const IconData play = Icons.play_arrow_rounded;
  static const IconData pause = Icons.pause_rounded;
  static const IconData minimize = Icons.expand_more_rounded;
  static const IconData timestamp = Icons.access_time_filled_rounded;
  static const IconData speed = Icons.speed_rounded;
  static const IconData menuDropdown = Icons.arrow_drop_down_rounded;
  static const IconData selected = Icons.check_rounded;

  // ============================================================== filters
  static const IconData lastHour = Icons.access_time_rounded;
  static const IconData last24Hours = Icons.today_rounded;
  static const IconData customRange = Icons.tune_rounded;
  static const IconData date = Icons.calendar_today_rounded;
  static const IconData dateRange = Icons.date_range_rounded;

  // =============================================================== common
  static const IconData back = Icons.arrow_back_rounded;
  static const IconData chevron = Icons.chevron_right_rounded;
  static const IconData activeCheck = Icons.check_circle_rounded;
  static const IconData info = Icons.info_outline_rounded;
  static const IconData error = Icons.error_outline_rounded;
  static const IconData success = Icons.check_circle_rounded;
}
