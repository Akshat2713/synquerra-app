import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/alerts/alert_entity.dart';
import '../../domain/entities/realtime/device_event.dart';

OverlayEntry? _current;

void showDeviceEventBanner(BuildContext context, DeviceEvent event) {
  _current?.remove();
  _current = null;

  final cs = Theme.of(context).colorScheme;
  final (
    IconData icon,
    Color color,
    String title,
    String body,
  ) = switch (event) {
    ModeChanged(:final modeName) => (
      Icons.swap_horiz_rounded,
      cs.primary,
      'Mode changed',
      'Device switched to $modeName',
    ),
    AlertReceived(:final alert) => (
      alert.isCritical ? Icons.warning_rounded : Icons.notifications_active,
      alert.severity == AlertSeverity.critical ? cs.error : cs.tertiary,
      alert.isCritical ? 'Critical alert' : 'New alert',
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

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 5), _dismiss);
  }

  Future<void> _dismiss() async {
    _timer?.cancel();
    if (!mounted) return;
    await _ac.reverse();
    widget.onClose();
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
                onTap: _dismiss,
                onVerticalDragEnd: (d) {
                  if ((d.primaryVelocity ?? 0) < -200) _dismiss();
                },
                child: Material(
                  elevation: 6,
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: widget.color.withOpacity(0.6)),
                    ),
                    child: Row(
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
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                widget.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: cs.onSurfaceVariant),
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
