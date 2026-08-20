// lib/presentation/screens/location/widgets/timeline_slider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:synquerra/presentation/utils/date_time_formatter.dart';
import 'package:synquerra/presentation/utils/unit_formatter.dart';
import '../../../../domain/entities/analytics/analytics_entity.dart';

class TimelineSlider extends StatefulWidget {
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
  State<TimelineSlider> createState() => _TimelineSliderState();
}

class _TimelineSliderState extends State<TimelineSlider> {
  bool _isPlaying = false;
  Timer? _playbackTimer;

  double _selectedSpeed = 1.0;
  final List<double> _speedOptions = [1.0, 2.0, 4.0];

  @override
  void dispose() {
    _stopPlayback();
    super.dispose();
  }

  void _togglePlayback() {
    if (_isPlaying) {
      _stopPlayback();
    } else {
      _startPlayback();
    }
  }

  void _startPlayback() {
    if (widget.points.isEmpty) return;
    setState(() => _isPlaying = true);

    if (widget.currentIndex >= widget.points.length - 1) {
      widget.onChanged(0);
    }

    _playbackTimer?.cancel();

    final intervalMs = (800 / _selectedSpeed).round();

    _playbackTimer = Timer.periodic(Duration(milliseconds: intervalMs), (
      timer,
    ) {
      if (widget.currentIndex < widget.points.length - 1) {
        widget.onChanged(widget.currentIndex + 1);
      } else {
        _stopPlayback();
      }
    });
  }

  void _stopPlayback() {
    _playbackTimer?.cancel();
    if (mounted && _isPlaying) {
      setState(() => _isPlaying = false);
    }
  }

  void _updateSpeed(double speed) {
    if (_selectedSpeed == speed) return;
    setState(() {
      _selectedSpeed = speed;
    });

    if (_isPlaying) {
      _startPlayback();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final sortedPoints = List<AnalyticsEntity>.from(widget.points)
      ..sort((a, b) {
        final aTime = a.deviceTimestamp;
        final bTime = b.deviceTimestamp;
        if (aTime == null) return -1;
        if (bTime == null) return 1;
        return aTime.compareTo(bTime);
      });

    final hasPoints = sortedPoints.isNotEmpty;
    final safeIndex = hasPoints
        ? widget.currentIndex.clamp(0, sortedPoints.length - 1)
        : 0;
    final current = hasPoints ? sortedPoints[safeIndex] : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: colors.onSurfaceVariant.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (current != null) ...[
            Row(
              children: [
                Icon(
                  Icons.access_time_filled_rounded,
                  size: 16,
                  color: colors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    DateTimeFormatter.formatFullDateTime(
                      current.deviceTimestamp,
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricBadge(
                    icon: Icons.speed_rounded,
                    label: UnitFormatter.formatSpeed(current.speed),
                    color: colors.primary,
                    colors: colors,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricBadge(
                    icon: _getBatteryIcon(current.battery),
                    label: current.battery != null
                        ? '${current.battery}%'
                        : 'N/A',
                    color: _getBatteryColor(current.battery, colors),
                    colors: colors,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricBadge(
                    icon: _getSignalIcon(current.signal),
                    label: current.signal != null
                        ? '${current.signal}%'
                        : 'N/A',
                    color: _getSignalColor(current.signal, colors),
                    colors: colors,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.skip_previous_rounded),
                    iconSize: 26,
                    color: colors.onSurfaceVariant,
                    onPressed: hasPoints && safeIndex > 0
                        ? () => widget.onChanged(safeIndex - 1)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      _isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                    ),
                    iconSize: 36,
                    color: colors.primary,
                    onPressed: hasPoints ? _togglePlayback : null,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.skip_next_rounded),
                    iconSize: 26,
                    color: colors.onSurfaceVariant,
                    onPressed: hasPoints && safeIndex < sortedPoints.length - 1
                        ? () => widget.onChanged(safeIndex + 1)
                        : null,
                  ),
                ],
              ),
              Positioned(
                right: 0,
                child: PopupMenuButton<double>(
                  tooltip: 'Playback Speed',
                  initialValue: _selectedSpeed,
                  onSelected: _updateSpeed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => _speedOptions.map((speed) {
                    final label =
                        '${speed.toStringAsFixed(speed == speed.toInt() ? 0 : 1)}x';
                    return PopupMenuItem<double>(
                      value: speed,
                      height: 36,
                      child: Row(
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontWeight: _selectedSpeed == speed
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _selectedSpeed == speed
                                  ? colors.primary
                                  : colors.onSurface,
                            ),
                          ),
                          if (_selectedSpeed == speed) ...[
                            const Spacer(),
                            Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: colors.primary,
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_selectedSpeed.toStringAsFixed(_selectedSpeed == _selectedSpeed.toInt() ? 0 : 1)}x',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          size: 18,
                          color: colors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: colors.primary,
              inactiveTrackColor: colors.outlineVariant.withValues(alpha: 0.4),
            ),
            child: Slider(
              value: safeIndex.toDouble(),
              min: 0,
              max: hasPoints ? (sortedPoints.length - 1).toDouble() : 1,
              divisions: hasPoints && sortedPoints.length > 1
                  ? sortedPoints.length - 1
                  : 1,
              onChanged: hasPoints
                  ? (v) {
                      if (_isPlaying) _stopPlayback();
                      widget.onChanged(v.round());
                    }
                  : null,
            ),
          ),
          if (hasPoints)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateTimeFormatter.formatCompactDate(
                      sortedPoints.first.deviceTimestamp,
                    ),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    DateTimeFormatter.formatCompactDate(
                      sortedPoints.last.deviceTimestamp,
                    ),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
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

  Color _getBatteryColor(int? battery, ColorScheme colors) {
    if (battery == null) return colors.onSurfaceVariant;
    if (battery <= 15) return colors.error;
    if (battery <= 30) return Colors.amber.shade700;
    return Colors.green.shade600;
  }

  IconData _getBatteryIcon(int? battery) {
    if (battery == null) return Icons.battery_unknown_rounded;
    if (battery <= 15) return Icons.battery_alert_rounded;
    if (battery <= 30) return Icons.battery_3_bar_rounded;
    if (battery <= 70) return Icons.battery_5_bar_rounded;
    return Icons.battery_full_rounded;
  }

  Color _getSignalColor(int? signal, ColorScheme colors) {
    if (signal == null) return colors.onSurfaceVariant;
    if (signal <= 25) return colors.error;
    if (signal <= 50) return Colors.amber.shade700;
    return colors.primary;
  }

  IconData _getSignalIcon(int? signal) {
    if (signal == null) return Icons.signal_cellular_nodata_rounded;
    if (signal <= 25) return Icons.signal_cellular_alt_1_bar_rounded;
    if (signal <= 50) return Icons.signal_cellular_alt_2_bar_rounded;
    if (signal <= 75) return Icons.signal_cellular_4_bar_rounded;
    return Icons.signal_cellular_4_bar_rounded;
  }
}

class _MetricBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final ColorScheme colors;

  const _MetricBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
