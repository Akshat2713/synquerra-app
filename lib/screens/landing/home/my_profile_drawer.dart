import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_track/providers/theme_provider.dart'; // Import the provider
import 'package:safe_track/screens/landing/home/profile_drawer/device_information.dart';
import 'package:safe_track/screens/landing/home/profile_drawer/device_registration.dart';
import 'package:safe_track/screens/landing/home/profile_drawer/feedback_screen.dart';
import 'package:safe_track/screens/landing/home/profile_drawer/personal_information.dart';
import 'package:safe_track/screens/landing/home/profile_drawer/recharge_and_renewal_options.dart';
import 'package:safe_track/screens/landing/home/profile_drawer/subscription_status.dart';
import 'package:safe_track/screens/landing/settings_screen.dart';

class MyProfileDrawer extends StatelessWidget {
  const MyProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      // The drawer's background color will be set by your app's theme
      // backgroundColor: AppColors.backgroundDarkMode,
      child: SafeArea(
        // SafeArea prevents UI overlap with the status bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TOP SECTION: LOGO AND APP NAME ---
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 24, 0, 24),
              child: Row(
                children: [
                  // TODO: Replace with your app logo widget
                  Image.asset(
                    'assets/images/app_logo.png', // Make sure you have a logo in your assets folder
                    width: 80,
                    height: 80,
                    // As a fallback, you can use an Icon
                    // Icon(Icons.location_pin, size: 40, color: AppColors.navBlue),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Synquerra",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      // Color will be inherited from the theme
                    ),
                  ),
                ],
              ),
            ),

            // --- MIDDLE SECTION: SCROLLABLE LIST OF ITEMS ---
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.app_registration),
                    title: const Text('Device Registration'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeviceRegistrationScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Personal Information'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PersonalInformationScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.devices),
                    title: const Text('Device Information'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeviceInformationScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.subscriptions),
                    title: const Text('Subscription Status'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SubscriptionStatusScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.payment),
                    title: const Text('Recharge & Renewal'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RechargeRenewalOptionsScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SettingsScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.feedback),
                    title: const Text('Feedback'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FeedbackScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Dark Mode'),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        final provider = Provider.of<ThemeProvider>(
                          context,
                          listen: false,
                        );
                        provider.toggleTheme(value);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // --- BOTTOM SECTION: LOGOUT BUTTON ---
            // --- BOTTOM SECTION: LOGOUT BUTTON ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  // Changed to ElevatedButton.icon
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Add your logout logic here
                  },
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ), // Added icon
                  label: const Text(
                    // Label is now the text part
                    'Logout',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
