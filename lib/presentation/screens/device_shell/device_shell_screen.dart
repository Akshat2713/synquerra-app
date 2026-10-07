// lib/presentation/screens/device_shell/device_shell_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/di/injection_container.dart';
import '../../../domain/entities/alerts/alert_entity.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/entities/realtime/device_event.dart';
import '../../blocs/analytics/analytics_bloc.dart';
import '../../blocs/device_list/device_list_bloc.dart';
import '../../blocs/geofence/geofence_bloc.dart';
import '../../blocs/landing/landing_bloc.dart';
import '../../blocs/realtime/device_events_cubit.dart';
import '../../blocs/schedule_list/schedule_list_bloc.dart';
import '../../widgets/device_event_banner.dart';
import '../geofence/geofence_list_page.dart';
import '../landing/landing_screen.dart';
import '../landing/widgets/attention_device_sheet.dart';
import '../location/location_screen.dart';
import '../manage/manage_screen.dart';
import '../user_schedule/schedules_list_screen.dart';
import '../../blocs/mode_condition/mode_condition_bloc.dart';

class DeviceShellScreen extends StatefulWidget {
  final DeviceEntity device;
  const DeviceShellScreen({super.key, required this.device});

  @override
  State<DeviceShellScreen> createState() => _DeviceShellScreenState();
}

class _DeviceShellScreenState extends State<DeviceShellScreen> {
  int _currentIndex = 0;

  // Track loaded tabs lazily (Tab 0 is Home)
  final Set<int> _activatedTabs = {0};

  LatLng get _defaultCenter => widget.device.hasLocation
      ? LatLng(widget.device.latitude!, widget.device.longitude!)
      : const LatLng(28.6172, 77.2094);

  @override
  void initState() {
    super.initState();
    // 1 single initial fetch for shared telemetry between Home & Map
    context.read<AnalyticsBloc>().add(
      AnalyticsLoadDefault(
        deviceId: widget.device.id,
        imei: widget.device.imei,
      ),
    );
    context.read<DeviceEventsCubit>().start(widget.device.imei);
  }

  void _goToTab(int index) {
    setState(() {
      _currentIndex = index;
      _activatedTabs.add(index); // Lazily mount tab on first click
    });
  }

  void _openAttentionSheet(BuildContext context) {
    final deviceListBloc = context.read<DeviceListBloc>();
    final landingBloc = context.read<LandingBloc>();
    final landingState = landingBloc.state;
    final alerts = landingState is LandingLoaded
        ? landingState.alerts
        : <AlertEntity>[];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: deviceListBloc),
          BlocProvider.value(value: landingBloc),
        ],
        child: AttentionDeviceSheet(
          alerts: alerts,
          currentDeviceId: widget.device.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeviceEventsCubit, DeviceEvent?>(
      listener: (context, event) {
        if (event != null) showDeviceEventBanner(context, event);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            // Tab 0: Home (Always loaded first)
            LandingScreen(
              device: widget.device,
              onAttentionTap: () => _openAttentionSheet(context),
            ),

            // Tab 1: Map (Mounts & shares AnalyticsBloc when tapped)
            _activatedTabs.contains(1)
                ? LocationScreen(device: widget.device)
                : const SizedBox.shrink(),

            // Tab 2: Geofence List
            _activatedTabs.contains(2)
                ? MultiBlocProvider(
                    providers: [
                      BlocProvider<GeofenceBloc>(
                        create: (_) => sl<GeofenceBloc>(),
                      ),
                      BlocProvider<ModeConditionBloc>(
                        create: (_) => sl<ModeConditionBloc>(),
                      ),
                    ],
                    child: GeofenceListPage(
                      deviceId: widget.device.id,
                      initialCenter: _defaultCenter,
                    ),
                  )
                : const SizedBox.shrink(),

            // Tab 3: Schedules List
            _activatedTabs.contains(3)
                ? BlocProvider(
                    create: (_) => sl<ScheduleListBloc>(),
                    child: const SchedulesListScreen(),
                  )
                : const SizedBox.shrink(),

            // Tab 4: Manage
            _activatedTabs.contains(4)
                ? ManageScreen(device: widget.device)
                : const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _goToTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map_rounded),
              label: 'Map',
            ),
            NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              selectedIcon: Icon(Icons.shield_rounded),
              label: 'Geofence',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded),
              label: 'Schedules',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Manage',
            ),
          ],
        ),
      ),
    );
  }
}
