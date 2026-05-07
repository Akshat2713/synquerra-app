import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/home/home_bloc.dart';
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
    context.read<HomeBloc>().add(HomeLoadRequested());
  }

  Future<void> _onRefresh() async {
    context.read<HomeBloc>().add(HomeRefreshRequested());
    // wait until state changes from loading
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      return context.read<HomeBloc>().state is HomeLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
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
            IconButton(
              icon: const Icon(Icons.person_outline_rounded),
              onPressed: () {
                // TODO: navigate to profile
              },
            ),
          ],
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return const DeviceListSkeleton();
            }

            if (state is HomeError) {
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
                      onPressed: () =>
                          context.read<HomeBloc>().add(HomeLoadRequested()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is HomeLoaded) {
              return RefreshIndicator(
                onRefresh: _onRefresh,
                color: colors.primary,
                child: CustomScrollView(
                  slivers: [
                    // ── Critical alert banner ────────────
                    SliverToBoxAdapter(
                      child: CriticalAlertBanner(
                        criticalCount: state.criticalAlertCount,
                        devicesNeedingAttention: state.devicesNeedingAttention,
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
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.deviceDetail,
                                  arguments: device,
                                ),
                                onToggleActive: () => context
                                    .read<HomeBloc>()
                                    .add(HomeDeviceToggled(device.imei)),
                              );
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
    );
  }
}
