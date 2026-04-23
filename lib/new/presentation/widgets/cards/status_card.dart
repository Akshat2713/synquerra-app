// lib/presentation/widgets/cards/status_card.dart
import 'package:flutter/material.dart';
import '../../../business/entities/analytics_entity.dart';
import '../../themes/colors.dart';
import '../indicators/pulse_indicator.dart';
import '../common/detail_row.dart';

class StatusCard extends StatelessWidget {
  final AnalyticsDataEntity? data;
  final List<AnalyticsDataEntity>? allPackets;

  const StatusCard({super.key, this.data, this.allPackets});

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'No Data';
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}";
  }

  Color _getBatteryColor(int? battery) {
    if (battery == null) return Colors.grey;
    if (battery <= 20) return AppColors.emergencyRed;
    if (battery <= 50) return AppColors.warningAmber;
    return AppColors.safeGreen;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOnline = data != null;
    final batteryColor = _getBatteryColor(data?.battery);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface,
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    PulseIndicator(isActive: isOnline),
                    const SizedBox(width: 10),
                    Text(
                      isOnline ? "DEVICE ACTIVE" : "DEVICE OFFLINE",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isOnline ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatTimestamp(data?.timestamp),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildQuickStat(
                  Icons.speed_rounded,
                  "${data?.speed ?? 0}",
                  "km/h",
                  "Speed",
                  Colors.blue,
                ),
                _buildQuickStat(
                  Icons.battery_full_rounded,
                  data?.battery?.toString() ?? '-',
                  "%",
                  "Battery",
                  batteryColor,
                ),
                _buildQuickStat(
                  Icons.signal_cellular_alt_rounded,
                  data?.signal?.toString() ?? '-',
                  "%",
                  "Signal",
                  Colors.orange,
                ),
                _buildQuickStat(
                  Icons.thermostat_rounded,
                  data?.temperature?.toString() ?? '-',
                  "°C",
                  "Temp",
                  Colors.redAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(
    IconData icon,
    String value,
    String unit,
    String label,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              children: [
                TextSpan(
                  text: " $unit",
                  style: const TextStyle(fontSize: 8, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      ),
    );
  }
}
