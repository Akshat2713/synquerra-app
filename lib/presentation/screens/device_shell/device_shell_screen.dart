// presentation/screens/device_shell/device_shell_screen.dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../alerts_errors/alerts_errors_screen.dart';
import '../landing/landing_screen.dart';
import '../settings/settings_screen.dart';
import '../device_detail/device_detail_screen.dart'; // now exports DeviceMapTab

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          LandingScreen(onAttentionTap: () => {}),
          DeviceDetailScreen(device: widget.device),
          AlertsErrorsScreen(deviceId: widget.device.id),
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
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Notifications',
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
