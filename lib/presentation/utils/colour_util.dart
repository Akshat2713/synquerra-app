// presentation/utils/color_utils.dart

import 'package:flutter/material.dart';
import '../themes/colors.dart';

Color batteryColor(int? battery) {
  if (battery == null) return Colors.grey;

  if (battery <= 20) return AppColors.alertCritical;
  if (battery <= 50) return AppColors.alertWarning;
  return AppColors.alertSuccess;
}

String hexFromColor(Color c) =>
    '#${c.value.toRadixString(16).substring(2).toUpperCase()}';

Color colorFromHex(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  final value = int.tryParse(cleaned, radix: 16);
  return value == null ? Colors.blue : Color(0xFF000000 | value);
}
