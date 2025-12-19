import 'package:flutter/material.dart';
// import 'package:location/location.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:synquerra/screens/landing/alarms_and_notifications_screen.dart';
import 'package:synquerra/screens/landing/location_history_screen.dart';
import 'package:synquerra/screens/landing/settings_screen.dart';
import 'package:synquerra/screens/landing/map_screen.dart';
import 'package:synquerra/theme/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No app bar or drawer here; handled inside MapPage
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
        children: [
          MapScreen(),
          const LocationHistoryScreen(),
          const AlarmsAndNotificationsScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Material(
        elevation: 12,
        color: Colors.white,
        child: SalomonBottomBar(
          currentIndex: _selectedIndex,
          onTap: (i) {
            setState(() => _selectedIndex = i);
            _pageController.animateToPage(
              i,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.home),
              title: const Text("Home"),
              selectedColor: AppColors.navBlue,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.history_edu_sharp),
              title: const Text("Location history"),
              selectedColor: AppColors.navBlue,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.notifications),
              title: const Text("Notifications"),
              selectedColor: AppColors.navBlue,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.settings),
              title: const Text("Settings"),
              selectedColor: AppColors.navBlue,
            ),
          ],
        ),
      ),
    );
  }
}
