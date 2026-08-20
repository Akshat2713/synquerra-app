import 'package:flutter/material.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/colour_util.dart';

class BatteryGauge extends StatelessWidget {
  final int? batteryLevel;
  final bool isCharging;

  const BatteryGauge({
    super.key,
    required this.batteryLevel,
    required this.isCharging,
  });

  @override
  Widget build(BuildContext context) {
    final color = batteryColor(batteryLevel);

    return SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 38,
            height: 38,
            child: CircularProgressIndicator(
              value: (batteryLevel ?? 0) / 100,
              strokeWidth: 3.5,
              backgroundColor: AppColors.textSecondary(context).withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Text(
            '${batteryLevel ?? '–'}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          if (isCharging)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow(context).withValues(alpha: 0.15),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  size: 11,
                  color: AppColors.warning,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
