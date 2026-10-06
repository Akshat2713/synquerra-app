import 'package:flutter/material.dart';

import '../../../themes/colors.dart';
import '../../../utils/colour_util.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';

class BottomMetricsBar extends StatelessWidget {
  final int battery;
  final String networkStatus;
  final String temperature;

  const BottomMetricsBar({
    super.key,
    required this.battery,
    this.networkStatus = 'Fair',
    required this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant(context).withValues(alpha: AppAlpha.border),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _MetricCell(
            title: 'NETWORK\nSTRENGTH',
            valueRow: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.signal_cellular_alt,
                  size: 14,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  networkStatus,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          _MetricCell(
            title: 'LOCATION\nCONFIDENCE',
            valueRow: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi, size: 14, color: AppColors.warning),
                const SizedBox(width: 4),
                Text(
                  'Poor',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          _MetricCell(
            title: 'CURRENT\nBATTERY',
            valueRow: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.battery_4_bar_rounded,
                  size: 14,
                  color: batteryColor(battery),
                ),
                const SizedBox(width: 4),
                Text(
                  '$battery%',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: batteryColor(battery),
                  ),
                ),
              ],
            ),
          ),
          // const _MetricCell(
          //   title: 'REMAINING\nTIME',
          //   valueRow: Text(
          //     '≈ 3.4h',
          //     style: TextStyle(fontWeight: FontWeight.w800),
          //   ),
          // ),
          _MetricCell(
            title: 'DEVICE\nTEMP',
            valueRow: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.thermostat,
                  size: 14,
                  color: temperatureColor(temperature),
                ),
                const SizedBox(width: 4),
                Text(
                  '$temperature ℃',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: temperatureColor(temperature),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  final String title;
  final Widget valueRow;

  const _MetricCell({required this.title, required this.valueRow});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary(context).withValues(alpha: AppAlpha.overlay),
          ),
        ),
        const SizedBox(height: 4),
        valueRow,
      ],
    );
  }
}
