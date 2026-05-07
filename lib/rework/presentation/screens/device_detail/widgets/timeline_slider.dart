import 'package:flutter/material.dart';
import '../../../../domain/entities/analytics/analytics_entity.dart';

class TimelineSlider extends StatelessWidget {
  final List<AnalyticsEntity> points;
  final int currentIndex;
  final void Function(int) onChanged;

  const TimelineSlider({
    super.key,
    required this.points,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final current = points.isEmpty
        ? null
        : points[currentIndex.clamp(0, points.length - 1)];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.onSurfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Current point info
          if (current != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoChip(
                  icon: Icons.access_time_rounded,
                  label: current.deviceTimestamp
                      .split('T')
                      .last
                      .split('.')
                      .first,
                  colors: colors,
                ),
                _infoChip(
                  icon: Icons.speed_rounded,
                  label: current.speed ?? 'N/A',
                  colors: colors,
                ),
                _infoChip(
                  icon: Icons.battery_charging_full_rounded,
                  label: current.battery != null
                      ? '${current.battery}%'
                      : 'N/A',
                  colors: colors,
                ),
                _infoChip(
                  icon: Icons.signal_cellular_alt_rounded,
                  label: current.signal != null ? '${current.signal}%' : 'N/A',
                  colors: colors,
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: points.isEmpty
                  ? 0
                  : currentIndex.toDouble().clamp(
                      0,
                      (points.length - 1).toDouble(),
                    ),
              min: 0,
              max: points.isEmpty ? 1 : (points.length - 1).toDouble(),
              divisions: points.length > 1 ? points.length - 1 : 1,
              onChanged: points.isEmpty ? null : (v) => onChanged(v.round()),
            ),
          ),

          // Timeline labels
          if (points.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(points.first.deviceTimestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${currentIndex + 1} / ${points.length}',
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _formatDate(points.last.deviceTimestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required ColorScheme colors,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: colors.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }

  String _formatDate(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.day}/${dt.month}';
    } catch (_) {
      return timestamp.substring(0, 5);
    }
  }
}
