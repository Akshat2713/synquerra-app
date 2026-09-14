// presentation/utils/color_utils.dart

import 'package:flutter/material.dart';
import '../../domain/entities/alerts/alert_entity.dart';
import '../themes/colors.dart';

Color batteryColor(int? battery) {
  if (battery == null) return Colors.grey;

  if (battery <= 20) return AppColors.danger;
  if (battery <= 50) return AppColors.warning;
  return AppColors.success;
}

String hexFromColor(Color c) =>
    '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

Color colorFromHex(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  final value = int.tryParse(cleaned, radix: 16);
  return value == null ? Colors.blue : Color(0xFF000000 | value);
}

Color deviceSeverityColor(List<AlertEntity> deviceAlerts) {
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
