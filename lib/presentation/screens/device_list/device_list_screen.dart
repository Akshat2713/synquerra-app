// lib/presentation/screens/device_list/device_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synquerra/domain/entities/device/device_entity.dart';
import '../../../domain/utils/alert_device_matcher.dart';
import '../../app/app_router.dart';
import '../../blocs/alerts/alerts_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/device_list/device_list_bloc.dart';
import 'device_list_skeleton.dart';
import 'widgets/add_device_fab.dart';
import 'widgets/device_card.dart';
import 'widgets/notification_bell.dart';
import 'widgets/profile_menu_button.dart';

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
    context.read<AlertsBloc>().add(const AlertsLoadRequested());
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<DeviceListBloc>();
    bloc.add(const DeviceListRefreshRequested());
    await bloc.stream.firstWhere((s) => s is! DeviceListLoading);
  }

  static const List<MapEntry<String, String>> _relationshipOrder = [
    MapEntry('both', 'Assigned to'),
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

  void _onDeviceTap(DeviceEntity device) {
    AppRouter.pushDeviceDetail(
      context,
      device: device,
      deviceListBloc: context.read<DeviceListBloc>(),
    ).then((_) {
      if (mounted) {
        context.read<DeviceListBloc>().add(const DeviceListRefreshRequested());
      }
    });
  }

  void _onModesTap(DeviceEntity device) {
    AppRouter.pushModes(
      context,
      deviceId: device.id,
      currentModeName: device.currentMode,
    ).then((_) {
      if (mounted) {
        context.read<DeviceListBloc>().add(const DeviceListRefreshRequested());
      }
    });
  }

  void _onAddDeviceTap() {
    AppRouter.pushLinkDevice(context).then((_) {
      if (mounted) {
        context.read<DeviceListBloc>().add(const DeviceListRefreshRequested());
      }
    });
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
          if (!didPop) await SystemNavigator.pop();
        },
        child: Scaffold(
          backgroundColor: colors.surface,
          appBar: AppBar(
            title: const Text('My Devices'),
            automaticallyImplyLeading: false,
            centerTitle: false,
            actions: [
              const NotificationBell(),
              ProfileMenuButton(
                user: user,
                onLogout: () =>
                    context.read<AuthBloc>().add(const AuthLogoutRequested()),
                onManageDevices: () => AppRouter.pushManageDevices(
                  context,
                  deviceListBloc: context.read<DeviceListBloc>(),
                ),
                onManageUsers: () => AppRouter.pushManageUsers(context),
              ),
            ],
          ),
          floatingActionButton: AddDeviceFab(onTap: _onAddDeviceTap),
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
                          const DeviceListLoadRequested(),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              if (state is DeviceListLoaded) {
                final grouped = _groupByRelationship(state.devices);
                final alertsState = context.watch<AlertsBloc>().state;
                final allAlerts = alertsState is AlertsLoaded
                    ? alertsState.alerts
                    : const [];

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: colors.primary,
                  child: CustomScrollView(
                    slivers: [
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
                        for (final entry in _relationshipOrder)
                          if (grouped[entry.key]?.isNotEmpty ?? false)
                            ..._buildSection(
                              context,
                              colors,
                              title: entry.value,
                              devices: grouped[entry.key]!,
                              user: user,
                              allAlerts: allAlerts,
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

  List<Widget> _buildSection(
    BuildContext context,
    ColorScheme colors, {
    required String title,
    required List<DeviceEntity> devices,
    required dynamic user,
    required List allAlerts,
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
          final deviceAlerts = alertsForDevice(device, allAlerts.cast());
          return DeviceCard(
            device: device,
            isActive: device.isActive,
            currentUserFullName: user?.fullName ?? '—',
            deviceAlerts: deviceAlerts.cast(),
            onTap: () => _onDeviceTap(device),
            onViewModesTap: () => _onModesTap(device),
            onSettingsTap: () {},
          );
        }, childCount: devices.length),
      ),
    ];
  }
}
