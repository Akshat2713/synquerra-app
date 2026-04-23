// lib/presentation/utils/color_utils.dart
import 'package:flutter/material.dart';
import '../themes/colors.dart';

class ColorUtils {
  ColorUtils._();

  /// Get battery color based on percentage
  static Color getBatteryColor(int? battery) {
    if (battery == null) return Colors.grey;
    if (battery <= 20) return AppColors.emergencyRed;
    if (battery <= 50) return AppColors.warningAmber;
    return AppColors.safeGreen;
  }

  /// Get signal color based on percentage
  static Color getSignalColor(int? signal) {
    if (signal == null) return Colors.grey;
    if (signal <= 30) return AppColors.emergencyRed;
    if (signal <= 70) return AppColors.warningAmber;
    return AppColors.safeGreen;
  }

  /// Get temperature color based on value
  static Color getTemperatureColor(int? temperature) {
    if (temperature == null) return Colors.grey;
    if (temperature > 85) return AppColors.emergencyRed;
    if (temperature > 70) return AppColors.warningAmber;
    return AppColors.safeGreen;
  }

  /// Get status color for online/offline
  static Color getOnlineStatusColor(bool isOnline) {
    return isOnline ? AppColors.safeGreen : AppColors.emergencyRed;
  }

  /// Get color for packet loss percentage
  static Color getPacketLossColor(double lossPercent) {
    if (lossPercent > 20) return AppColors.emergencyRed;
    if (lossPercent > 10) return AppColors.warningAmber;
    return AppColors.safeGreen;
  }
}
