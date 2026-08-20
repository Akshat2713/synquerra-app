// lib/presentation/screens/device_list/widgets/notification_bell.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synquerra/domain/entities/alerts/alert_entity.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../../app/app_router.dart';
import '../../../blocs/alerts/alerts_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/device_list/device_list_bloc.dart';
import '../../../themes/colors.dart';
import 'notification_panel.dart';

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
          AppLogger.d('NotificationBell', 'barrier tapped -> closing');
          _close();
        },
        child: const SizedBox.expand(),
      ),
    );

    _panelEntry = OverlayEntry(
      builder: (ctx) {
        final screenWidth = MediaQuery.of(ctx).size.width;
        final panelWidth = screenWidth * 0.75;
        return Positioned(
          width: panelWidth,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(-(panelWidth - 44) + 20, 44),
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
                    child: BlocBuilder<AlertsBloc, AlertsState>(
                      builder: (panelContext, state) {
                        final authState = panelContext.watch<AuthBloc>().state;
                        final deviceState = panelContext
                            .watch<DeviceListBloc>()
                            .state;

                        final currentUserFullName =
                            authState is AuthAuthenticated
                            ? authState.user.fullName
                            : '—';
                        final devices = deviceState is DeviceListLoaded
                            ? deviceState.devices
                            : <DeviceEntity>[];

                        final isLoading =
                            state is AlertsLoading || state is AlertsInitial;
                        final errorMessage = state is AlertsError
                            ? state.message
                            : null;
                        final alerts = state is AlertsLoaded
                            ? state.alerts
                            : [];

                        return NotificationPanel(
                          alerts: alerts as List<AlertEntity>,
                          devices: devices,
                          currentUserFullName: currentUserFullName,
                          isLoading: isLoading,
                          errorMessage: errorMessage,
                          onClose: _close,
                          onAlertTap: (alert, device) {
                            if (device != null) {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.deviceDetail,
                                arguments: DeviceDetailArgs(
                                  device: device,
                                  deviceListBloc: context
                                      .read<DeviceListBloc>(),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
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
    setState(() {});
  }

  Future<void> _close() async {
    await _controller.reverse();
    _barrierEntry?.remove();
    _panelEntry?.remove();
    _barrierEntry = null;
    _panelEntry = null;
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
                  color: AppColors.danger,
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
