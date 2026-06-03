import 'package:flutter/material.dart';

class BatterySection extends StatelessWidget {
  final int percent;
  final String chargeByTime;
  final String statusText;

  const BatterySection({
    super.key,
    required this.percent,
    required this.chargeByTime,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isLow = percent <= 20;
    final batteryColor = isLow
        ? colors.error
        : percent <= 50
        ? Colors.orange
        : colors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: batteryColor,
                ),
              ),
              const Spacer(),
              Text(
                chargeByTime,
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Battery bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 6,
              backgroundColor: colors.outlineVariant,
              valueColor: AlwaysStoppedAnimation<Color>(batteryColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.battery_charging_full_rounded,
                size: 16,
                color: batteryColor,
              ),
              const SizedBox(width: 6),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
