// presentation/screens/device_shell/device_shell_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../blocs/alerts/alerts_bloc.dart';
// import '../../blocs/analytics/analytics_bloc.dart';
import '../../blocs/device_list/device_list_bloc.dart';
import '../../blocs/landing/landing_bloc.dart';
import '../landing/landing_screen.dart';
import '../landing/widgets/attention_device_sheet.dart';
import '../manage/manage_screen.dart';
import '../settings/settings_screen.dart';
import '../location/location_screen.dart';

class DeviceShellScreen extends StatefulWidget {
  final DeviceEntity device;
  const DeviceShellScreen({super.key, required this.device});
  @override
  State<DeviceShellScreen> createState() => _DeviceShellScreenState();
}

class _DeviceShellScreenState extends State<DeviceShellScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;

  LatLng get _defaultCenter => widget.device.hasLocation
      ? LatLng(widget.device.latitude!, widget.device.longitude!)
      : const LatLng(28.6172, 77.2094);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToTab(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) => setState(() => _currentIndex = index);

  void _openAttentionSheet(BuildContext context) {
    final deviceListBloc = context.read<DeviceListBloc>();
    final landingBloc = context.read<LandingBloc>();
    final alertsBloc = context.read<AlertsBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: deviceListBloc),
          BlocProvider.value(value: landingBloc),
          BlocProvider.value(value: alertsBloc),
        ],
        child: const AttentionDeviceSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          LandingScreen(
            device: widget.device,
            onAttentionTap: () => _openAttentionSheet(context),
          ),
          DeviceDetailScreen(device: widget.device),
          ProfileScreen(device: widget.device),
          SettingsScreen(device: widget.device, initialCenter: _defaultCenter),
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
