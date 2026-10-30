// lib/presentation/utils/colour_util.dart
import 'package:flutter/material.dart';
import '../../domain/entities/alerts/alert_entity.dart';
import '../themes/colors.dart';

// ======================================================= thresholds
// Shared with app_icons.dart. Never hardcode these numbers anywhere else.

// Battery (%)
const int kBatteryCritical = 20; // <= red
const int kBatteryLow = 50; // <= yellow
const int kBatteryHigh = 70; // icon only: <= 5 bars, above = full

// Temperature (°C)
const double kTempDangerHigh = 45; // >= red
const double kTempWarnHigh = 38; // >= yellow
const double kTempWarnLow = 10; // <= yellow
const double kTempDangerLow = 0; // <= red

// ======================================================= parsing

/// Temperature may arrive as num, a numeric String, or 'NA' / null.
/// Returns null when there is no usable value.
// TODO(logic): drop this once the entity exposes temperature as num?.
double? parseTemperature(dynamic temp) {
  if (temp == null) return null;
  if (temp is num) return temp.toDouble();
  return double.tryParse(temp.toString());
}

// ======================================================= colors

Color batteryColor(int? battery) {
  if (battery == null) return AppColors.offline;
  if (battery <= kBatteryCritical) return AppColors.danger;
  if (battery <= kBatteryLow) return AppColors.warning;
  return AppColors.success;
}

Color temperatureColor(dynamic temp) {
  final parsed = parseTemperature(temp);
  if (parsed == null) return AppColors.offline;

  if (parsed >= kTempDangerHigh || parsed <= kTempDangerLow) {
    return AppColors.danger;
  }
  if (parsed >= kTempWarnHigh || parsed <= kTempWarnLow) {
    return AppColors.warning;
  }
  return AppColors.success;
}

Color alertColor(AlertEntity alert) {
  switch (alert.severity) {
    case AlertSeverity.critical:
      return AppColors.danger;
    case AlertSeverity.warning:
      return AppColors.warning;
    case AlertSeverity.advisory:
      return AppColors.success;
  }
}

Color deviceSeverityColor(List<dynamic> deviceAlerts) {
  final hasCritical = deviceAlerts.any(
    (a) => a.severity == AlertSeverity.critical && !a.isAcknowledged,
  );
  final hasWarning = deviceAlerts.any(
    (a) =>
        (a.severity == AlertSeverity.advisory ||
            a.severity == AlertSeverity.warning) &&
        !a.isAcknowledged,
  );
  if (hasCritical) return AppColors.danger;
  if (hasWarning) return AppColors.warning;
  return AppColors.success;
}

// TODO(logic): priority is a raw String on the entity. Use an enum there.
// CRITICAL and HIGH share danger for now.
Color priorityColor(String priority) {
  switch (priority.toUpperCase()) {
    case 'CRITICAL':
    case 'HIGH':
      return AppColors.danger;
    case 'MEDIUM':
      return AppColors.warning;
    case 'LOW':
      return AppColors.info;
    default:
      return AppColors.offline;
  }
}

// ======================================================= hex helpers

String hexFromColor(Color c) =>
    '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

Color colorFromHex(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  final value = int.tryParse(cleaned, radix: 16);
  return value == null ? Colors.blue : Color(0xFF000000 | value);
}
