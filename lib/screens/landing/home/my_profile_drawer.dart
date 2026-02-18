import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synquerra/providers/theme_provider.dart'; // Import the provider
import 'package:synquerra/providers/user_provider.dart';
import 'package:synquerra/screens/landing/home/profile_drawer/device_information2.dart';
import 'package:synquerra/screens/landing/home/profile_drawer/device_information.dart';
import 'package:synquerra/screens/landing/home/profile_drawer/feedback_screen.dart';
import 'package:synquerra/screens/landing/home/profile_drawer/personal_information.dart';
import 'package:synquerra/screens/landing/home/profile_drawer/recharge_and_renewal_options.dart';
import 'package:synquerra/screens/landing/home/profile_drawer/subscription_status.dart';
import 'package:synquerra/screens/landing/settings_screen.dart';

import 'package:synquerra/core/preferences/user_preferences.dart';
import 'package:synquerra/screens/registration/login_page.dart';

class MyProfileDrawer extends StatelessWidget {
  const MyProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    // Access the theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);

    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final theme = Theme.of(context);

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
                    leading: const Icon(Icons.app_registration),
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

                  // ListTile(
                  //   leading: const Icon(Icons.devices),
                  //   title: const Text('Device Information'),
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (_) => const DeviceInformationScreen(),
                  //       ),
                  //     );
                  //   },
                  // ),
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
                  SwitchListTile(
                    // leading: const Icon(Icons.dark_mode),
                    title: const Text('Dark Mode'),
                    secondary: Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    ),

                    value: isDarkMode,
                    onChanged: (bool value) {
                      context.read<ThemeProvider>().toggleTheme();
                    },
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
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context), // Close dialog
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Close dialog
                              Navigator.pop(context);

                              // Perform Logout Logic
                              await UserPreferences().removeUser();

                              if (!context.mounted) return;

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
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
