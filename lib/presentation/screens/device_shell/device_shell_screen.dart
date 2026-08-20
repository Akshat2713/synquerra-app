// lib/presentation/screens/device_shell/device_shell_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../../../domain/entities/alerts/alert_entity.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../blocs/analytics/analytics_bloc.dart';
import '../../blocs/device_list/device_list_bloc.dart';
import '../../blocs/landing/landing_bloc.dart';
import '../landing/landing_screen.dart';
import '../landing/widgets/attention_device_sheet.dart';
import '../location/location_screen.dart';
import '../manage/manage_screen.dart';
import '../settings/settings_screen.dart';

class DeviceShellScreen extends StatefulWidget {
  final DeviceEntity device;
  const DeviceShellScreen({super.key, required this.device});

  @override
  State<DeviceShellScreen> createState() => _DeviceShellScreenState();
}

class _DeviceShellScreenState extends State<DeviceShellScreen> {
  int _currentIndex = 0;

  // Only Tab 0 (Home) is active initially. Tabs 1, 2, 3 only mount on first tap.
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
          currentDeviceId: widget.device.imei,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          // Tab 2: Manage (Only makes API calls when tapped for the first time)
          _activatedTabs.contains(2)
              ? ManageScreen(device: widget.device)
              : const SizedBox.shrink(),

          // Tab 3: Settings (Only loads when tapped)
          _activatedTabs.contains(3)
              ? SettingsScreen(
                  device: widget.device,
                  initialCenter: _defaultCenter,
                )
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
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Manage',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
