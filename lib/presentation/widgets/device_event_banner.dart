// lib/presentation/app/device_event_banner.dart  (keep your existing path)
import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/realtime/device_event.dart';
import '../themes/colors.dart'; // adjust path if needed
import 'package:synquerra/presentation/themes/app_tokens.dart';

/// How long the banner stays before auto-hiding.
const Duration _autoHide = Duration(seconds: 4);

OverlayEntry? _current;

void showDeviceEventBanner(
  BuildContext context,
  DeviceEvent event, {
  String? deviceName,
}) {
  _current?.remove();
  _current = null;

  final hasName = deviceName != null && deviceName.trim().isNotEmpty;
  String who(String imei) => hasName
      ? deviceName
      : '…${imei.length > 4 ? imei.substring(imei.length - 4) : imei}';

  final (
    IconData icon,
    Color color,
    String title,
    String body,
  ) = switch (event) {
    ModeChanged(:final modeName, :final imei) => (
      Icons.swap_horiz_rounded,
      AppColors.primary(context),
      'Mode changed',
      '${who(imei)} switched to $modeName',
    ),
    AlertReceived(:final alert) => (
      alert.isCritical
          ? Icons.warning_rounded
          : Icons.notifications_active_rounded,
      switch (alert.severity) {
        'critical' => AppColors.danger,
        'warning' => AppColors.warning,
        _ => AppColors.primary(context),
      },
      hasName ? '${alert.title} • $deviceName' : alert.title,
      alert.description,
    ),
  };

  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;
  void close() {
    if (entry.mounted) entry.remove();
    if (_current == entry) _current = null;
  }

  entry = OverlayEntry(
    builder: (_) => _EventBanner(
      icon: icon,
      color: color,
      title: title,
      body: body,
      onClose: close,
    ),
  );
  _current = entry;
  overlay.insert(entry);
}

class _EventBanner extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final VoidCallback onClose;

  const _EventBanner({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.onClose,
  });

  @override
  State<_EventBanner> createState() => _EventBannerState();
}

class _EventBannerState extends State<_EventBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  )..forward();
  late final Animation<double> _curve = CurvedAnimation(
    parent: _ac,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  final Key _dismissKey = UniqueKey(); // stable across rebuilds
  Timer? _timer;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(_autoHide, _dismiss);
  }

  Future<void> _dismiss() async {
    _timer?.cancel();
    if (!mounted) return;
    await _ac.reverse();
    widget.onClose();
  }

  // Tap toggles expand/collapse. Auto-hide is paused while expanded.
  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _timer?.cancel();
    } else {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, -1.4),
            end: Offset.zero,
          ).animate(_curve),
          child: FadeTransition(
            opacity: _curve,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: Dismissible(
                key: _dismissKey,
                direction: DismissDirection.horizontal,
                onDismissed: (_) => widget.onClose(),
                child: GestureDetector(
                  onTap: _toggle,
                  onVerticalDragEnd: (d) {
                    if ((d.primaryVelocity ?? 0) < -200) _dismiss();
                  },
                  child: _card(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: AppColors.outlineVariant(context).withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular tinted icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.12),
              ),
              child: Icon(widget.icon, color: widget.color, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'now',
                        style: TextStyle(
                          color: AppColors.textTertiary(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.topCenter,
                    child: Text(
                      widget.body,
                      maxLines: _expanded ? null : 2,
                      overflow: _expanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
