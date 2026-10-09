import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/realtime/device_event.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';

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

  final cs = Theme.of(context).colorScheme;
  final (
    IconData icon,
    Color color,
    String title,
    String body,
  ) = switch (event) {
    ModeChanged(:final modeName, :final imei) => (
      Icons.swap_horiz_rounded,
      cs.primary,
      'Mode changed',
      '${who(imei)} switched to $modeName',
    ),
    AlertReceived(:final alert) => (
      alert.isCritical ? Icons.warning_rounded : Icons.notifications_active,
      switch (alert.severity) {
        'critical' => cs.error,
        'warning' => cs.tertiary,
        _ => cs.primary,
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
    duration: const Duration(milliseconds: 250),
  )..forward();
  Timer? _timer;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 5), _dismiss);
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
    final cs = Theme.of(context).colorScheme;
    final bodyStyle = TextStyle(color: cs.onSurfaceVariant);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, -1.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOut)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.horizontal,
              onDismissed: (_) => widget.onClose(),
              child: GestureDetector(
                onTap: _toggle,
                onVerticalDragEnd: (d) {
                  if ((d.primaryVelocity ?? 0) < -200) _dismiss();
                },
                child: Material(
                  elevation: 6,
                  color: cs.surfaceContainerHigh,
                  borderRadius: AppRadius.mdAll,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.mdAll,
                      border: Border.all(
                        color: widget.color.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(widget.icon, color: widget.color),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 200),
                                alignment: Alignment.topCenter,
                                child: Text(
                                  widget.body,
                                  maxLines: _expanded ? null : 2,
                                  overflow: _expanded
                                      ? TextOverflow.visible
                                      : TextOverflow.ellipsis,
                                  style: bodyStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
