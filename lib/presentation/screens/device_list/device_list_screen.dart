import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synquerra/domain/entities/device/device_entity.dart';
import '../../blocs/device_list/device_list_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/critical_alert_banner.dart';
import '../../widgets/device_card.dart';
import '../../app/app_router.dart';
import 'device_list_skeleton.dart';
import 'widgets/add_device_fab.dart';

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
    await homebloc.stream.firstWhere((s) => s is! DeviceListLoading);
  }

  // ── Relationship section order + display labels ──────────────────
  static const List<MapEntry<String, String>> _relationshipOrder = [
    MapEntry('both', 'Owned & Assigned'),
    MapEntry('owned', 'Owned by Me'),
    MapEntry('assigned', 'Assigned to Me'),
  ];

  Map<String, List<DeviceEntity>> _groupByRelationship(
    List<DeviceEntity> devices,
  ) {
    final grouped = <String, List<DeviceEntity>>{
      for (final entry in _relationshipOrder) entry.key: [],
    };
    for (final device in devices) {
      grouped.putIfAbsent(device.relationship, () => []).add(device);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return BlocListener<AuthBloc, AuthState>(
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
          floatingActionButton: AddDeviceFab(
            onTap: () => _navigateAndRefresh(AppRoutes.linkDevice),
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
                final grouped = _groupByRelationship(state.devices);

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
                      // ── Total count header ────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Text(
                            '${state.devices.length} Device${state.devices.length != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      if (state.devices.isEmpty)
                        SliverFillRemaining(
                          child: Center(
                            child: Text(
                              'No devices found.',
                              style: TextStyle(color: colors.onSurfaceVariant),
                            ),
                          ),
                        )
                      else
                        // ── One section per relationship group ──
                        for (final entry in _relationshipOrder)
                          if (grouped[entry.key]?.isNotEmpty ?? false)
                            ..._buildSection(
                              context,
                              colors,
                              title: entry.value,
                              devices: grouped[entry.key]!,
                              state: state,
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

  // ── Builds a section header + its device cards as slivers ────────
  List<Widget> _buildSection(
    BuildContext context,
    ColorScheme colors, {
    required String title,
    required List<DeviceEntity> devices,
    required DeviceListLoaded state,
  }) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '(${devices.length})',
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final device = devices[index];
          final deviceAlerts = state.alerts
              .where((a) => a.imei == device.imei)
              .toList();
          return DeviceCard(
            device: device,
            isActive: state.isDeviceActive(device),
            deviceAlerts: deviceAlerts,
            onTap: () =>
                _navigateAndRefresh(AppRoutes.deviceDetail, arguments: device),
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
          );
        }, childCount: devices.length),
      ),
    ];
  }

  void _navigateAndRefresh(String route, {Object? arguments}) {
    Navigator.pushNamed(context, route, arguments: arguments).then((_) {
      if (mounted) {
        context.read<DeviceListBloc>().add(const DeviceListRefreshRequested());
      }
    });
  }
}
