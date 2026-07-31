import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/alerts/alert_entity.dart';
import '../../../blocs/alerts/alerts_bloc.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});
  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _barrierEntry;
  OverlayEntry? _panelEntry;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );

  bool get _isOpen => _panelEntry != null;

  void _toggle() {
    debugPrint('[NotificationBell] bell tapped, isOpen=$_isOpen');
    _isOpen ? _close() : _open();
  }

  void _open() {
    debugPrint('[NotificationBell] _open() called');
    final overlay = Overlay.of(context);
    final alertsBloc = context.read<AlertsBloc>();

    _barrierEntry = OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          debugPrint('[NotificationBell] barrier tapped → closing');
          _close();
        },
        child: const SizedBox.expand(),
      ),
    );
    _panelEntry = OverlayEntry(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final panelWidth = screenWidth * 0.75;
        debugPrint('[NotificationBell] building panel, width=$panelWidth');
        return Positioned(
          width: panelWidth,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(
              -(panelWidth - 44) + 20,
              44,
            ), // FIXED: negative to align rightward
            child: Align(
              alignment: Alignment.topRight,
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeOutBack,
                ),
                alignment: Alignment.topRight,
                child: FadeTransition(
                  opacity: _controller,
                  child: BlocProvider.value(
                    value: alertsBloc,
                    child: _AlertsPanel(onClose: _close),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(_barrierEntry!);
    overlay.insert(_panelEntry!);
    _controller.forward();
    debugPrint('[NotificationBell] overlay entries inserted, animating in');
    setState(() {});
  }

  Future<void> _close() async {
    debugPrint('[NotificationBell] _close() called');
    await _controller.reverse();
    _barrierEntry?.remove();
    _panelEntry?.remove();
    _barrierEntry = null;
    _panelEntry = null;
    debugPrint('[NotificationBell] overlay entries removed');
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _barrierEntry?.remove();
    _panelEntry?.remove();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alertsState = context.watch<AlertsBloc>().state;
    debugPrint(
      '[NotificationBell] build, alertsState=${alertsState.runtimeType}',
    );
    final criticalCount = alertsState is AlertsLoaded
        ? alertsState.criticalCount
        : 0;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: _toggle,
          ),
          if (criticalCount > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '$criticalCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AlertsPanel extends StatelessWidget {
  final VoidCallback onClose;
  const _AlertsPanel({required this.onClose});

  int _severityRank(AlertSeverity s) => switch (s) {
    AlertSeverity.critical => 0,
    AlertSeverity.warning => 1,
    AlertSeverity.advisory => 2,
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      color: colors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 420),
        child: BlocBuilder<AlertsBloc, AlertsState>(
          builder: (context, state) {
            debugPrint(
              '[NotificationBell/_AlertsPanel] rendering state=${state.runtimeType}',
            );
            if (state is AlertsLoading || state is AlertsInitial) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (state is AlertsError) {
              debugPrint(
                '[NotificationBell/_AlertsPanel] error: ${state.message}',
              );
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  state.message,
                  style: TextStyle(color: colors.error),
                ),
              );
            }
            final alerts = (state as AlertsLoaded).alerts;
            debugPrint(
              '[NotificationBell/_AlertsPanel] alerts count=${alerts.length}',
            );
            if (alerts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No alerts',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ),
              );
            }
            final sorted = [...alerts]
              ..sort((a, b) {
                final r = _severityRank(
                  a.severity,
                ).compareTo(_severityRank(b.severity));
                if (r != 0) return r;
                return b.createdAt.compareTo(a.createdAt);
              });
            return ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: sorted.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: colors.outlineVariant),
              itemBuilder: (context, i) {
                final alert = sorted[i];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    alert.severity == AlertSeverity.critical
                        ? Icons.error_rounded
                        : Icons.warning_amber_rounded,
                    color: alert.severity == AlertSeverity.critical
                        ? Colors.red
                        : Colors.orange,
                    size: 20,
                  ),
                  title: Text(
                    alert.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    alert.imei,
                    style: const TextStyle(fontSize: 11),
                  ),
                  onTap: () {
                    debugPrint(
                      '[NotificationBell/_AlertsPanel] alert tapped: ${alert.id}',
                    );
                    // TODO: navigate to this alert's device / mark acknowledged
                    onClose();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
