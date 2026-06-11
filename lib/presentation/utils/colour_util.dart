// presentation/utils/color_utils.dart

import 'package:flutter/material.dart';
import '../themes/colors.dart';

Color batteryColor(int? battery) {
  if (battery == null) return Colors.grey;

  if (battery <= 20) return AppColors.alertCritical;
  if (battery <= 50) return AppColors.alertWarning;
  return AppColors.alertSuccess;
}
