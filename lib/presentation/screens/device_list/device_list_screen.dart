// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:synquerra/domain/entities/device/device_entity.dart';
// import '../../blocs/alerts/alerts_bloc.dart';
// import '../../blocs/device_list/device_list_bloc.dart';
// import '../../blocs/auth/auth_bloc.dart';
// import '../../blocs/theme/theme_cubit.dart';
// import '../../widgets/critical_alert_banner.dart';
// import 'widgets/device_card.dart';
// import '../../app/app_router.dart';
// import 'device_list_skeleton.dart';
// import 'widgets/add_device_fab.dart';

// class DeviceListScreen extends StatefulWidget {
//   const DeviceListScreen({super.key});
//   @override
//   State<DeviceListScreen> createState() => _DeviceListScreenState();
// }

// class _DeviceListScreenState extends State<DeviceListScreen> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<DeviceListBloc>().add(const DeviceListLoadRequested());
//     context.read<AlertsBloc>().add(const AlertsLoadRequested());
//   }

//   Future<void> _onRefresh() async {
//     final homebloc = context.read<DeviceListBloc>();
//     homebloc.add(const DeviceListRefreshRequested());
//     await homebloc.stream.firstWhere((s) => s is! DeviceListLoading);
//   }

//   // ── Relationship section order + display labels ──────────────────
//   static const List<MapEntry<String, String>> _relationshipOrder = [
//     MapEntry('both', 'Owned & Assigned'),
//     MapEntry('owned', 'Owned by Me'),
//     MapEntry('assigned', 'Assigned to Me'),
//   ];

//   Map<String, List<DeviceEntity>> _groupByRelationship(
//     List<DeviceEntity> devices,
//   ) {
//     final grouped = <String, List<DeviceEntity>>{
//       for (final entry in _relationshipOrder) entry.key: [],
//     };
//     for (final device in devices) {
//       grouped.putIfAbsent(device.relationship, () => []).add(device);
//     }
//     return grouped;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     final authState = context.watch<AuthBloc>().state;
//     final user = authState is AuthAuthenticated ? authState.user : null;

//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) {
//         if (state is AuthUnauthenticated) {
//           Navigator.pushNamedAndRemoveUntil(
//             context,
//             AppRoutes.login,
//             (_) => false,
//           );
//         }
//       },
//       child: PopScope(
//         canPop: false,
//         onPopInvokedWithResult: (didPop, result) async {
//           if (!didPop) {
//             await SystemNavigator.pop();
//           }
//         },
//         child: Scaffold(
//           backgroundColor: colors.surface,
//           appBar: AppBar(
//             title: const Text('My Devices'),
//             automaticallyImplyLeading: false,
//             centerTitle: false,
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.notifications_outlined),
//                 onPressed: () {
//                   // TODO: navigate to alerts screen
//                 },
//               ),
//               PopupMenuButton<String>(
//                 icon: const Icon(Icons.person_outline_rounded),
//                 offset: const Offset(0, 48),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 itemBuilder: (_) => [
//                   PopupMenuItem<String>(
//                     enabled: false,
//                     child: Builder(
//                       builder: (menuCtx) {
//                         final liveColors = Theme.of(menuCtx).colorScheme;
//                         return Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               user?.fullName ?? '—',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 14,
//                                 color: liveColors.onSurface,
//                               ),
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               user?.email ?? '—',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: liveColors.onSurfaceVariant,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Divider(
//                               height: 1,
//                               color: liveColors.outlineVariant,
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                   ),
//                   PopupMenuItem<String>(
//                     value: 'manage_users',
//                     enabled:
//                         false, // This natively disables the tap interaction in Flutter
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.people_alt_rounded,
//                           color: colors.onSurfaceVariant.withValues(
//                             alpha: 0.38,
//                           ),
//                           size: 18,
//                         ),
//                         const SizedBox(width: 10),
//                         Text(
//                           'Manage Users',
//                           style: TextStyle(
//                             color: colors.onSurfaceVariant.withValues(
//                               alpha: 0.38,
//                             ),
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   PopupMenuItem<String>(
//                     value: 'manage_devices',
//                     enabled:
//                         false, // This natively disables the tap interaction in Flutter
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.developer_board_rounded,
//                           color: colors.onSurfaceVariant.withValues(
//                             alpha: 0.38,
//                           ),
//                           size: 18,
//                         ),
//                         const SizedBox(width: 10),
//                         Text(
//                           'Manage Devices',
//                           style: TextStyle(
//                             color: colors.onSurfaceVariant.withValues(
//                               alpha: 0.38,
//                             ),
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   PopupMenuItem<String>(
//                     value: 'toggle_theme',
//                     child: Builder(
//                       builder: (menuCtx) {
//                         final isDark =
//                             menuCtx.watch<ThemeCubit>().state == ThemeMode.dark;
//                         return Row(
//                           children: [
//                             Icon(
//                               isDark
//                                   ? Icons.dark_mode_rounded
//                                   : Icons.light_mode_rounded,
//                               color: colors.onSurfaceVariant,
//                               size: 18,
//                             ),
//                             const SizedBox(width: 10),
//                             Text(
//                               isDark ? 'Dark Mode' : 'Light Mode',
//                               style: TextStyle(
//                                 color: colors.onSurface,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const Spacer(),
//                             Switch(
//                               value: isDark,
//                               onChanged: (_) {
//                                 context.read<ThemeCubit>().toggle();
//                               },
//                               activeThumbColor: colors.primary,
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                   ),
//                   PopupMenuItem<String>(
//                     value: 'logout',
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.logout_rounded,
//                           color: colors.error,
//                           size: 18,
//                         ),
//                         const SizedBox(width: 10),
//                         Text(
//                           'Logout',
//                           style: TextStyle(
//                             color: colors.error,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//                 onSelected: (value) {
//                   if (value == 'logout') {
//                     context.read<AuthBloc>().add(const AuthLogoutRequested());
//                   }
//                 },
//               ),
//             ],
//           ),
//           floatingActionButton: AddDeviceFab(
//             onTap: () => _navigateAndRefresh(AppRoutes.linkDevice),
//           ),
//           body: BlocBuilder<DeviceListBloc, DeviceListState>(
//             builder: (context, state) {
//               if (state is DeviceListLoading || state is DeviceListInitial) {
//                 return const DeviceListSkeleton();
//               }
//               if (state is DeviceListError) {
//                 return Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.error_outline_rounded,
//                         size: 48,
//                         color: colors.error,
//                       ),
//                       const SizedBox(height: 12),
//                       Text(
//                         state.message,
//                         style: TextStyle(color: colors.error),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: () => context.read<DeviceListBloc>().add(
//                           DeviceListLoadRequested(),
//                         ),
//                         child: const Text('Retry'),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//               if (state is DeviceListLoaded) {
//                 final grouped = _groupByRelationship(state.devices);

//                 return RefreshIndicator(
//                   onRefresh: _onRefresh,
//                   color: colors.primary,
//                   child: CustomScrollView(
//                     slivers: [
//                       // ── Critical alert banner ────────────
//                       SliverToBoxAdapter(
//                         child: CriticalAlertBanner(
//                           criticalCount: state.criticalAlertCount,
//                           devicesNeedingAttention:
//                               state.devicesNeedingAttention,
//                           onTap: () {
//                             // TODO: navigate to alerts screen
//                           },
//                         ),
//                       ),
//                       // ── Total count header ────────────────
//                       SliverToBoxAdapter(
//                         child: Padding(
//                           padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
//                           child: Text(
//                             '${state.devices.length} Device${state.devices.length != 1 ? 's' : ''}',
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               color: colors.onSurfaceVariant,
//                             ),
//                           ),
//                         ),
//                       ),
//                       if (state.devices.isEmpty)
//                         SliverFillRemaining(
//                           child: Center(
//                             child: Text(
//                               'No devices found.',
//                               style: TextStyle(color: colors.onSurfaceVariant),
//                             ),
//                           ),
//                         )
//                       else
//                         // ── One section per relationship group ──
//                         for (final entry in _relationshipOrder)
//                           if (grouped[entry.key]?.isNotEmpty ?? false)
//                             ..._buildSection(
//                               context,
//                               colors,
//                               title: entry.value,
//                               devices: grouped[entry.key]!,
//                               state: state,
//                             ),
//                       const SliverToBoxAdapter(child: SizedBox(height: 24)),
//                     ],
//                   ),
//                 );
//               }
//               return const SizedBox.shrink();
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Builds a section header + its device cards as slivers ────────
//   List<Widget> _buildSection(
//     BuildContext context,
//     ColorScheme colors, {
//     required String title,
//     required List<DeviceEntity> devices,
//     required DeviceListLoaded state,
//   }) {
//     return [
//       SliverToBoxAdapter(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
//           child: Row(
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w700,
//                   color: colors.primary,
//                 ),
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 '(${devices.length})',
//                 style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
//               ),
//             ],
//           ),
//         ),
//       ),
//       SliverList(
//         delegate: SliverChildBuilderDelegate((context, index) {
//           final device = devices[index];
//           final deviceAlerts = state.alerts
//               .where((a) => a.imei == device.imei)
//               .toList();
//           return DeviceCard(
//             device: device,
//             isActive: state.isDeviceActive(device),
//             deviceAlerts: deviceAlerts,
//             onTap: () =>
//                 _navigateAndRefresh(AppRoutes.deviceDetail, arguments: device),
//             onViewDetailsTap: () => _navigateAndRefresh(
//               AppRoutes.telemetryHistory,
//               arguments: device,
//             ),
//             onViewAlertsTap: () => _navigateAndRefresh(
//               AppRoutes.alertsErrors,
//               arguments: device.id,
//             ),
//             onViewModesTap: () => _navigateAndRefresh(
//               AppRoutes.modes,
//               arguments: {
//                 'deviceId': device.id,
//                 'currentModeName': device.currentMode,
//               },
//             ),
//             onSettingsTap: () => {},
//           );
//         }, childCount: devices.length),
//       ),
//     ];
//   }

//   void _navigateAndRefresh(String route, {Object? arguments}) {
//     Navigator.pushNamed(context, route, arguments: arguments).then((_) {
//       if (mounted) {
//         context.read<DeviceListBloc>().add(const DeviceListRefreshRequested());
//       }
//     });
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synquerra/domain/entities/device/device_entity.dart';
import '../../blocs/device_list/device_list_bloc.dart';
import '../../blocs/alerts/alerts_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../utils/device_alert_matcher.dart';
import '../../widgets/critical_alert_banner.dart';
import '../../app/app_router.dart';
import 'device_list_skeleton.dart';
import 'widgets/add_device_fab.dart';
import 'widgets/device_card.dart';
import 'widgets/profile_menu_button.dart';
import 'widgets/notification_bell.dart';

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
              ProfileMenuButton(user: user),
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
                final criticalCount = alertsState is AlertsLoaded
                    ? alertsState.criticalCount
                    : 0;

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: colors.primary,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: CriticalAlertBanner(
                          criticalCount: criticalCount,
                          devicesNeedingAttention:
                              state.devicesNeedingAttention,
                          onTap: () {
                            // TODO: navigate to alerts screen
                          },
                        ),
                      ),
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
    required dynamic user, // UserEntity?
    required List allAlerts, // List<AlertEntity>
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
            // WITH (back to original)
            onTap: () => _navigateAndRefresh(
              AppRoutes.deviceDetail,
              arguments: DeviceDetailArgs(
                device: device,
                deviceListBloc: context.read<DeviceListBloc>(),
              ),
            ),
            onViewModesTap: () => _navigateAndRefresh(
              AppRoutes.modes,
              arguments: {
                'deviceId': device.id,
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
