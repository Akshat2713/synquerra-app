// lib/presentation/screens/location/widgets/timeline_slider.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:synquerra/presentation/utils/date_time_formatter.dart';
import 'package:synquerra/presentation/utils/unit_formatter.dart';
import '../../../../domain/entities/analytics/analytics_entity.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/colors.dart';
import '../../../utils/app_icons.dart';
import '../../../utils/colour_util.dart';
import '../../../widgets/app_surfaces.dart';
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
  // TODO(logic): playback (timer, speed, base interval) belongs in a
  // controller/bloc, not in the widget state.
  static const _speedOptions = [1.0, 2.0, 4.0];
  static const _baseIntervalMs = 800;

  bool _isPlaying = false;
  Timer? _playbackTimer;
  double _selectedSpeed = 1.0;

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _togglePlayback() => _isPlaying ? _stopPlayback() : _startPlayback();

  void _startPlayback() {
    if (widget.points.isEmpty) return;
    setState(() => _isPlaying = true);

    if (widget.currentIndex >= widget.points.length - 1) {
      widget.onChanged(0);
    }

    _playbackTimer?.cancel();
    final intervalMs = (_baseIntervalMs / _selectedSpeed).round();

    _playbackTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
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
    setState(() => _selectedSpeed = speed);
    if (_isPlaying) _startPlayback();
  }

  static String _speedLabel(double speed) =>
      '${speed.toStringAsFixed(speed == speed.toInt() ? 0 : 1)}x';

  // // TODO(logic): move to colour_util.dart next to batteryColor.
  // IconData _batteryIcon(int? battery) {
  //   if (battery == null) return Icons.battery_unknown_rounded;
  //   if (battery <= 15) return Icons.battery_alert_rounded;
  //   if (battery <= 30) return Icons.battery_3_bar_rounded;
  //   if (battery <= 70) return Icons.battery_5_bar_rounded;
  //   return Icons.battery_full_rounded;
  // }

  @override
  Widget build(BuildContext context) {
    // TODO(logic): the bloc's mappablePoints is already sorted oldest -> newest,
    // so this sort is redundant. Remove it and use widget.points directly.
    final sortedPoints = List<AnalyticsEntity>.from(widget.points)
      ..sort((a, b) {
        final aTime = a.deviceTimestamp;
        final bTime = b.deviceTimestamp;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return -1;
        if (bTime == null) return 1;
        return aTime.compareTo(bTime);
      });

    final hasPoints = sortedPoints.isNotEmpty;
    final safeIndex = hasPoints
        ? widget.currentIndex.clamp(0, sortedPoints.length - 1)
        : 0;
    final current = hasPoints ? sortedPoints[safeIndex] : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.smd,
        0,
        AppSpacing.smd,
        AppSpacing.md,
      ),
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.smd,
          AppSpacing.md,
          AppSpacing.smd,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.sm,
          children: [
            if (current != null)
              Row(
                spacing: AppSpacing.sm,
                children: [
                  Expanded(
                    child: Row(
                      spacing: AppSpacing.xs,
                      children: [
                        Icon(
                          AppIcons.timestamp,
                          size: AppSize.iconSm,
                          color: AppColors.iconSecondary(context),
                        ),
                        Expanded(
                          child: Text(
                            DateTimeFormatter.formatFullDateTime(
                              current.deviceTimestamp,
                            ),
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.metaWithColor(
                              context,
                              color: AppColors.textPrimary(context),
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _InlineMetric(
                    icon: AppIcons.speed,
                    label: UnitFormatter.formatSpeed(current.speed),
                    color: AppColors.iconSecondary(context),
                  ),
                  _InlineMetric(
                    icon: AppIcons.battery(current.battery),
                    label: current.battery != null
                        ? '${current.battery}%'
                        : 'N/A',
                    color: batteryColor(current.battery),
                  ),
                  _MinimizeButton(onPressed: widget.onMinimize),
                ],
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: _MinimizeButton(onPressed: widget.onMinimize),
              ),
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: AppSpacing.md,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.skip_previous_rounded),
                      iconSize: AppSize.iconLg,
                      color: AppColors.textSecondary(context),
                      tooltip: 'Previous point',
                      onPressed: hasPoints && safeIndex > 0
                          ? () => widget.onChanged(safeIndex - 1)
                          : null,
                    ),
                    IconButton.filled(
                      icon: Icon(_isPlaying ? AppIcons.pause : AppIcons.play),
                      iconSize: AppSize.iconLg,
                      tooltip: _isPlaying ? 'Pause' : 'Play',
                      onPressed: hasPoints ? _togglePlayback : null,
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(AppIcons.next),
                      iconSize: AppSize.iconLg,
                      color: AppColors.textSecondary(context),
                      tooltip: 'Next point',
                      onPressed:
                          hasPoints && safeIndex < sortedPoints.length - 1
                          ? () => widget.onChanged(safeIndex + 1)
                          : null,
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  child: PopupMenuButton<double>(
                    tooltip: 'Playback speed',
                    initialValue: _selectedSpeed,
                    onSelected: _updateSpeed,
                    itemBuilder: (context) => _speedOptions.map((speed) {
                      final selected = _selectedSpeed == speed;
                      return PopupMenuItem<double>(
                        value: speed,
                        child: Row(
                          children: [
                            Text(
                              _speedLabel(speed),
                              style:
                                  AppTextStyles.bodyWithColor(
                                    context,
                                    color: selected
                                        ? AppColors.primary(context)
                                        : AppColors.textPrimary(context),
                                  ).copyWith(
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                  ),
                            ),
                            if (selected) ...[
                              const Spacer(),
                              Icon(
                                Icons.check_rounded,
                                size: AppSize.iconSm,
                                color: AppColors.primary(context),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                    child: _SpeedChip(label: _speedLabel(_selectedSpeed)),
                  ),
                ),
              ],
            ),
            // Timeline: start date + slider + end date
            if (hasPoints)
              Row(
                spacing: AppSpacing.xs,
                children: [
                  Text(
                    DateTimeFormatter.formatCompactDate(
                      sortedPoints.first.deviceTimestamp,
                    ),
                    style: AppTextStyles.microWithColor(
                      context,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  Expanded(
                    // Track, colors and overlay come from sliderTheme in
                    // app_theme. Only the arrow thumb is local.
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: const _ArrowThumbShape(
                          icon: AppIcons.directionMarker,
                          size: AppSize.iconLg,
                        ),
                      ),
                      child: Slider(
                        value: safeIndex.toDouble(),
                        min: 0,
                        max: (sortedPoints.length - 1).toDouble(),
                        divisions: sortedPoints.length > 1
                            ? sortedPoints.length - 1
                            : 1,
                        onChanged: (v) {
                          if (_isPlaying) _stopPlayback();
                          widget.onChanged(v.round());
                        },
                      ),
                    ),
                  ),
                  Text(
                    DateTimeFormatter.formatCompactDate(
                      sortedPoints.last.deviceTimestamp,
                    ),
                    style: AppTextStyles.microWithColor(
                      context,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _MinimizeButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _MinimizeButton({required this.onPressed});

  @override
  Widget build(BuildContext context) => IconButton(
    visualDensity: VisualDensity.compact,
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints(),
    icon: const Icon(AppIcons.minimize),
    iconSize: AppSize.iconLg,
    color: AppColors.iconSecondary(context),
    tooltip: 'Minimize',
    onPressed: onPressed,
  );
}

/// Playback speed selector (the popup's trigger).
class _SpeedChip extends StatelessWidget {
  final String label;
  const _SpeedChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final foreground = AppColors.onPrimaryContainer(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryContainer(context),
        borderRadius: AppRadius.pillAll,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.smd,
          AppSpacing.xs,
          AppSpacing.xs,
          AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.metaWithColor(
                context,
                color: foreground,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
            Icon(AppIcons.menuDropdown, size: AppSize.icon, color: foreground),
          ],
        ),
      ),
    );
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
      spacing: AppSpacing.xs,
      children: [
        Icon(icon, size: AppSize.iconSm, color: color),
        Text(
          label,
          style: AppTextStyles.microWithColor(
            context,
            color: AppColors.textPrimary(context),
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Slider thumb that renders a Material icon (default: arrow rotated to
/// point along the track).
class _ArrowThumbShape extends SliderComponentShape {
  final IconData icon;
  final double size;
  final Color? color;
  final double rotation;

  const _ArrowThumbShape({
    this.icon = AppIcons.directionMarker,
    this.size = AppSize.iconLg,
  }) : rotation = math.pi / 2,
       color = null;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(size, size);

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
    // Slider passes a fully resolved theme here, so thumbColor is non-null.
    final effectiveColor = color ?? sliderTheme.thumbColor!;

    // Glyph painting (icon font), not UI text, so no AppTextStyles role.
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
