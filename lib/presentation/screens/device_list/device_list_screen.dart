import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/device_list/device_list_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/critical_alert_banner.dart';
import '../../widgets/device_card.dart';
import '../../app/app_router.dart';
import 'device_list_skeleton.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DeviceListBloc>().add(const DeviceListLoadRequested());
  }

  Future<void> _onRefresh() async {
    final homebloc = context.read<DeviceListBloc>();
    homebloc.add(const DeviceListRefreshRequested());
    // wait until state changes from loading
    // await Future.doWhile(() async {
    //   await Future.delayed(const Duration(milliseconds: 100));
    //   return homebloc.state is DeviceListLoading;
    // });
    await homebloc.stream.firstWhere((s) => s is! DeviceListLoading);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // ── Grab user from AuthBloc state ────────────────────────────────
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return BlocListener<AuthBloc, AuthState>(
      // ── Navigate to login when logged out ────────────────────────
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (_) => false,
          );
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            await SystemNavigator.pop();
          }
        },
        child: Scaffold(
          backgroundColor: colors.surface,
          appBar: AppBar(
            title: const Text('My Devices'),
            automaticallyImplyLeading: false,
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // TODO: navigate to alerts screen
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.person_outline_rounded),
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (_) => [
                  // ── User info header (not tappable) ──────────
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? '—',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '—',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Divider(height: 1, color: colors.outlineVariant),
                      ],
                    ),
                  ),

                  // ── Logout ────────────────────────────────────
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: colors.error,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: colors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'logout') {
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                  }
                },
              ),
            ],
          ),
          body: BlocBuilder<DeviceListBloc, DeviceListState>(
            builder: (context, state) {
              if (state is DeviceListLoading || state is DeviceListInitial) {
                return const DeviceListSkeleton();
              }

              if (state is DeviceListError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: colors.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        style: TextStyle(color: colors.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<DeviceListBloc>().add(
                          DeviceListLoadRequested(),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is DeviceListLoaded) {
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: colors.primary,
                  child: CustomScrollView(
                    slivers: [
                      // ── Critical alert banner ────────────
                      SliverToBoxAdapter(
                        child: CriticalAlertBanner(
                          criticalCount: state.criticalAlertCount,
                          devicesNeedingAttention:
                              state.devicesNeedingAttention,
                          onTap: () {
                            // TODO: navigate to alerts screen
                          },
                        ),
                      ),

                      // ── Section header ───────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Row(
                            children: [
                              Text(
                                '${state.devices.length} Device${state.devices.length != 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Device list ──────────────────────
                      state.devices.isEmpty
                          ? SliverFillRemaining(
                              child: Center(
                                child: Text(
                                  'No devices found.',
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final device = state.devices[index];
                                final deviceAlerts = state.alerts
                                    .where((a) => a.imei == device.imei)
                                    .toList();

                                return DeviceCard(
                                  device: device,
                                  isActive: state.isDeviceActive(device),
                                  deviceAlerts: deviceAlerts,
                                  onTap: () => _navigateAndRefresh(
                                    AppRoutes.deviceDetail,
                                    arguments: device,
                                  ),
                                  onViewDetailsTap: () => _navigateAndRefresh(
                                    AppRoutes.telemetryHistory,
                                    arguments: device,
                                  ),
                                  onViewAlertsTap: () => _navigateAndRefresh(
                                    AppRoutes.alertsErrors,
                                    arguments: device.imei,
                                  ),
                                  onViewModesTap: () => _navigateAndRefresh(
                                    AppRoutes.modes,
                                    arguments: {
                                      'imei': device.imei,
                                      'currentModeName': device.currentMode,
                                    },
                                  ),
                                  onSettingsTap: () => {},
                                )
                                // Trigger the routing from the screen level!
                                ;
                              }, childCount: state.devices.length),
                            ),

                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void _navigateAndRefresh(String route, {Object? arguments}) {
    Navigator.pushNamed(context, route, arguments: arguments).then((_) {
      if (mounted) {
        context.read<DeviceListBloc>().add(const DeviceListRefreshRequested());
      }
    });
  }
}
