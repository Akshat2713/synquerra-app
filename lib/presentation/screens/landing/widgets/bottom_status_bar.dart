import 'package:flutter/material.dart';

import '../../../utils/colour_util.dart';

class BottomMetricsBar extends StatelessWidget {
  final int battery;
  final String networkStatus;

  const BottomMetricsBar({
    super.key,
    required this.battery,
    this.networkStatus = 'Fair',
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3)),
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
                  color: Colors.amber[700],
                ),
                const SizedBox(width: 4),
                Text(
                  networkStatus,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.amber[700],
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
                Icon(Icons.wifi, size: 14, color: Colors.orange[700]),
                const SizedBox(width: 4),
                Text(
                  'Poor',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.orange[700],
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
          const _MetricCell(
            title: 'REMAINING\nTIME',
            valueRow: Text(
              '≈ 3.4h',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const _MetricCell(
            title: 'DEVICE\nTEMP',
            valueRow: Text(
              '38°',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.green,
              ),
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
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        valueRow,
      ],
    );
  }
}
