// lib/presentation/screens/location/widgets/timeline_slider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:synquerra/presentation/utils/date_time_formatter.dart';
import 'package:synquerra/presentation/utils/unit_formatter.dart';
import '../../../../domain/entities/analytics/analytics_entity.dart';
import '../../../themes/colors.dart';
import '../../../utils/colour_util.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';

class TimelineSlider extends StatefulWidget {
  final List<AnalyticsEntity> points;
  final int currentIndex;
  final void Function(int) onChanged;
  final VoidCallback onMinimize;

  const TimelineSlider({
    super.key,
    required this.points,
    required this.currentIndex,
    required this.onChanged,
    required this.onMinimize,
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
        color: AppColors.surfaceVariant(context),
        borderRadius: AppRadius.lgAll,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: AppAlpha.tint),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (current != null)
            Row(
              children: [
                Icon(
                  Icons.access_time_filled_rounded,
                  size: 16,
                  color: AppColors.iconSecondary(context),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    DateTimeFormatter.formatFullDateTime(
                      current.deviceTimestamp,
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Speed + Battery inline, before the minimize button
                const SizedBox(width: 8),
                _InlineMetric(
                  icon: Icons.speed_rounded,
                  label: UnitFormatter.formatSpeed(current.speed),
                  color: AppColors.iconSecondary(context),
                ),
                const SizedBox(width: 8),
                _InlineMetric(
                  icon: _getBatteryIcon(current.battery),
                  label: current.battery != null
                      ? '${current.battery}%'
                      : 'N/A',
                  color: batteryColor(current.battery),
                ),
                const SizedBox(width: 4),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.expand_more_rounded),
                  iconSize: 26,
                  color: AppColors.iconSecondary(context),
                  onPressed: widget.onMinimize,
                ),
              ],
            )
          else
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.expand_more_rounded),
                iconSize: 26,
                color: AppColors.iconSecondary(context),
                onPressed: widget.onMinimize,
              ),
            ),
          if (current != null) const SizedBox(height: 8),
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
                    color: AppColors.textSecondary(context),
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
                    color: AppColors.primary(context),
                    onPressed: hasPoints ? _togglePlayback : null,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.skip_next_rounded),
                    iconSize: 26,
                    color: AppColors.textSecondary(context),
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
                    borderRadius: AppRadius.mdAll,
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
                                  ? AppColors.primary(context)
                                  : AppColors.textPrimary(context),
                            ),
                          ),
                          if (_selectedSpeed == speed) ...[
                            const Spacer(),
                            Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: AppColors.primary(context),
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
                      color: AppColors.surface(context),
                      borderRadius: AppRadius.mdAll,
                      border: Border.all(
                        color: AppColors.outlineVariant(
                          context,
                        ).withValues(alpha: AppAlpha.border),
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
                            color: AppColors.primary(context),
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          size: 18,
                          color: AppColors.primary(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Timeline: date before + slider + date after, all inline
          if (hasPoints)
            Row(
              children: [
                Text(
                  DateTimeFormatter.formatCompactDate(
                    sortedPoints.first.deviceTimestamp,
                  ),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const _ArrowThumbShape(
                        icon: Icons.navigation_rounded,
                        size: 22,
                      ),
                      thumbColor: AppColors.primary(context),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                      activeTrackColor: AppColors.primary(context),
                      inactiveTrackColor: AppColors.outlineVariant(
                        context,
                      ).withValues(alpha: AppAlpha.border),
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
                ),
                const SizedBox(width: 4),
                Text(
                  DateTimeFormatter.formatCompactDate(
                    sortedPoints.last.deviceTimestamp,
                  ),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Color _getBatteryColor(int? battery) {
  //   if (battery == null) return AppColors.textSecondary(context);
  //   if (battery <= 15) return AppColors.danger;
  //   if (battery <= 30) return AppColors.warning;
  //   return AppColors.success;
  // }

  IconData _getBatteryIcon(int? battery) {
    if (battery == null) return Icons.battery_unknown_rounded;
    if (battery <= 15) return Icons.battery_alert_rounded;
    if (battery <= 30) return Icons.battery_3_bar_rounded;
    if (battery <= 70) return Icons.battery_5_bar_rounded;
    return Icons.battery_full_rounded;
  }
}

/// Small inline metric with icon + label, no card/background.
class _InlineMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InlineMetric({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }
}

/// Custom slider thumb rendered as an arrow (triangle) pointing up.
/// Slider thumb that renders a Material arrow icon.
/// Slider thumb that renders a Material arrow icon.
class _ArrowThumbShape extends SliderComponentShape {
  final IconData icon;
  final double size;
  final Color? color;
  final double rotation;

  const _ArrowThumbShape({
    this.icon = Icons.navigation_rounded,
    this.size = 22,
    this.color,
    this.rotation = 1.5708, // π/2 — points right by default
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(size, size);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final effectiveColor =
        color ?? sliderTheme.thumbColor ?? const Color(0xFF000000);

    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: effectiveColor,
        ),
      ),
      textDirection: textDirection,
    )..layout();

    final canvas = context.canvas;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }
}
