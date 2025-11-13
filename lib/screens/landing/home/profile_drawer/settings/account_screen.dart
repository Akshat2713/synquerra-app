import 'package:flutter/material.dart';
import 'package:safe_track/theme/colors.dart'; // Reusing the dummy screen
import 'package:safe_track/widgets/dummy_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  // State variables for the switches
  bool _pushNotifications = true;
  bool _emailAlerts = true;
  bool _smsAlerts = false;
  bool _sosAlerts = true;
  bool _geofenceAlerts = true;
  bool _lowBatteryAlerts = false;
  bool _speedAlerts = true;

  // Helper method to navigate
  void _navigateToDummy(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DummyScreen(title: title)),
    );
  }

  // Helper for underlined text style
  final TextStyle _underlinedTextStyle = const TextStyle(
    decoration: TextDecoration.underline,
    decorationColor: Colors.grey, // Adjust underline color if needed
    decorationThickness: 1,
    fontSize: 17, // Slightly larger font
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Account")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Edit Profile Section ---
          _buildSectionCard(
            context: context,
            child: _buildNavigationTile(
              context: context,
              icon: Icons.person_outline,
              title: "Edit Profile",
              onTap: () => _navigateToDummy(context, "Edit Profile"),
            ),
          ),
          const SizedBox(height: 20),

          // --- Security Section ---
          _buildSectionCard(
            context: context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  // Title with Icon
                  children: [
                    Icon(
                      Icons.security,
                      color: colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Security",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _buildNavigationTile(
                  context: context,
                  titleWidget: Text(
                    "Change Password",
                    style: _underlinedTextStyle,
                  ),
                  onTap: () => _navigateToDummy(context, "Change Password"),
                  dense: true, // Make tiles more compact
                ),
                _buildNavigationTile(
                  context: context,
                  titleWidget: Text(
                    "Two Factor Authentication",
                    style: _underlinedTextStyle,
                  ),
                  onTap: () => _navigateToDummy(context, "Two Factor Auth"),
                  dense: true,
                ),
                _buildNavigationTile(
                  context: context,
                  titleWidget: Text(
                    "Login history",
                    style: _underlinedTextStyle,
                  ),
                  onTap: () => _navigateToDummy(context, "Login History"),
                  dense: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- Notifications Section ---
          _buildSectionCard(
            context: context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  // Title with Icon
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Notifications",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _buildSwitchTile(
                  context: context,
                  titleWidget: Text(
                    "Push Notifications",
                    style: _underlinedTextStyle.copyWith(
                      decoration: TextDecoration.none,
                    ),
                  ),
                  value: _pushNotifications,
                  onChanged: (value) =>
                      setState(() => _pushNotifications = value),
                ),
                _buildSwitchTile(
                  context: context,
                  titleWidget: Text(
                    "Email Alerts",
                    style: _underlinedTextStyle.copyWith(
                      decoration: TextDecoration.none,
                    ),
                  ),
                  value: _emailAlerts,
                  onChanged: (value) => setState(() => _emailAlerts = value),
                ),
                _buildSwitchTile(
                  context: context,
                  titleWidget: Text(
                    "SMS Alerts",
                    style: _underlinedTextStyle.copyWith(
                      decoration: TextDecoration.none,
                    ),
                  ),
                  value: _smsAlerts,
                  onChanged: (value) => setState(() => _smsAlerts = value),
                ),
                const SizedBox(height: 15),
                Padding(
                  // Subtitle for specific alerts
                  padding: const EdgeInsets.only(
                    left: 0,
                    bottom: 8.0,
                  ), // Align with text
                  child: Text(
                    "Choose which alerts to receive:",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      fontSize: 18,
                    ),
                  ),
                ),
                _buildSwitchTile(
                  context: context,
                  titleWidget: Text(
                    "SOS Alerts",
                    style: _underlinedTextStyle.copyWith(
                      decoration: TextDecoration.none,
                    ),
                  ),
                  value: _sosAlerts,
                  onChanged: (value) => setState(() => _sosAlerts = value),
                ),
                _buildSwitchTile(
                  context: context,
                  titleWidget: Text(
                    "Geofence Entry/Exit",
                    style: _underlinedTextStyle.copyWith(
                      decoration: TextDecoration.none,
                    ),
                  ),
                  value: _geofenceAlerts,
                  onChanged: (value) => setState(() => _geofenceAlerts = value),
                ),
                _buildSwitchTile(
                  context: context,
                  titleWidget: Text(
                    "Low Battery Warnings",
                    style: _underlinedTextStyle.copyWith(
                      decoration: TextDecoration.none,
                    ),
                  ),
                  value: _lowBatteryAlerts,
                  onChanged: (value) =>
                      setState(() => _lowBatteryAlerts = value),
                ),
                _buildSwitchTile(
                  context: context,
                  titleWidget: Text(
                    "Speed Alerts",
                    style: _underlinedTextStyle.copyWith(
                      decoration: TextDecoration.none,
                    ),
                  ),
                  value: _speedAlerts,
                  onChanged: (value) => setState(() => _speedAlerts = value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for the main section cards
  Widget _buildSectionCard({
    required BuildContext context,
    required Widget child,
  }) {
    return Card(
      elevation: 3, // Slight elevation
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: const EdgeInsets.all(16.0), child: child),
    );
  }

  // Helper widget for tiles that navigate somewhere
  Widget _buildNavigationTile({
    required BuildContext context,
    IconData? icon,
    String? title, // Either title or titleWidget should be provided
    Widget? titleWidget,
    required VoidCallback onTap,
    bool dense = false, // Option for more compact tiles
  }) {
    assert(
      title != null || titleWidget != null,
      'Provide either title or titleWidget',
    );
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero, // Remove default padding
      leading: icon != null
          ? Icon(
              icon,
              color: colorScheme.onSurfaceVariant,
              size: dense ? 22 : 24,
            )
          : null,
      title:
          titleWidget ??
          Text(
            title!,
            style: TextStyle(
              fontSize: dense ? 16 : 18, // Slightly smaller if dense
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
      trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
      onTap: onTap,
      dense: dense, // Apply density
    );
  }

  // Helper widget for tiles with a switch
  Widget _buildSwitchTile({
    required BuildContext context,
    IconData? icon, // Optional icon if needed later
    String? title,
    Widget? titleWidget,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool dense = true, // Default to dense for notification toggles
  }) {
    assert(
      title != null || titleWidget != null,
      'Provide either title or titleWidget',
    );
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: icon != null
          ? Icon(
              icon,
              color: colorScheme.onSurfaceVariant,
              size: dense ? 22 : 24,
            )
          : null,
      title:
          titleWidget ??
          Text(
            title!,
            style: TextStyle(
              fontSize: dense ? 16 : 18,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.safeGreen, // Use theme primary color
      ),
      dense: dense,
      // Make the whole tile tappable to toggle the switch (optional)
      onTap: () => onChanged(!value),
    );
  }
}
