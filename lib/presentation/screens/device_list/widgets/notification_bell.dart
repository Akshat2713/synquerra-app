import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../domain/entities/alerts/alert_entity.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../../app/app_router.dart';
import '../../../blocs/alerts/alerts_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/device_list/device_list_bloc.dart';
import '../../../utils/colour_util.dart';

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
    AppLogger.d('NotificationBell', 'bell tapped, isOpen=$_isOpen');
    _isOpen ? _close() : _open();
  }

  void _open() {
    AppLogger.d('NotificationBell', '_open() called');
    final overlay = Overlay.of(context);
    final alertsBloc = context.read<AlertsBloc>();
    final deviceListBloc = context.read<DeviceListBloc>();
    final authBloc = context.read<AuthBloc>();

    _barrierEntry = OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          AppLogger.d('NotificationBell', 'barrier tapped → closing');
          _close();
        },
        child: const SizedBox.expand(),
      ),
    );
    _panelEntry = OverlayEntry(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final panelWidth = screenWidth * 0.75;
        AppLogger.d('NotificationBell', 'building panel, width=$panelWidth');
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
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: alertsBloc),
                      BlocProvider.value(value: deviceListBloc),
                      BlocProvider.value(value: authBloc),
                    ],
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
    AppLogger.d('NotificationBell', 'overlay entries inserted, animating in');
    setState(() {});
  }

  Future<void> _close() async {
    AppLogger.d('NotificationBell', '_close() called');
    await _controller.reverse();
    _barrierEntry?.remove();
    _panelEntry?.remove();
    _barrierEntry = null;
    _panelEntry = null;
    AppLogger.d('NotificationBell', 'overlay entries removed');
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
    final deviceState = context.watch<DeviceListBloc>().state;
    final authState = context.watch<AuthBloc>().state;
    final currentUserFullName = authState is AuthAuthenticated
        ? authState.user.fullName
        : '—';
    final devices = deviceState is DeviceListLoaded
        ? deviceState.devices
        : <DeviceEntity>[];
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
                final device = devices
                    .where((d) => d.imei == alert.imei)
                    .firstOrNull;
                final name =
                    device?.displayOwnerName(currentUserFullName) ?? alert.imei;

                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundImage: device?.carrier?.profilePhoto != null
                        ? CachedNetworkImageProvider(
                            device!.carrier!.profilePhoto!,
                          )
                        : null,
                    child: device?.carrier?.profilePhoto == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(name),
                  subtitle: Text(
                    alert.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(
                    alert.severity == AlertSeverity.critical
                        ? Icons.error_rounded
                        : Icons.warning_amber_rounded,
                    color: alertColor(alert),
                    size: 20,
                  ),
                  onTap: () {
                    debugPrint(
                      '[NotificationBell/_AlertsPanel] alert tapped: ${alert.id}',
                    );
                    onClose();
                    if (device != null) {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.deviceDetail,
                        arguments: DeviceDetailArgs(
                          device: device,
                          deviceListBloc: context.read<DeviceListBloc>(),
                        ),
                      );
                    }
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
