import 'package:flutter/material.dart';
import 'package:synquerra/screens/landing/home/profile_drawer/settings/device_settings_screen.dart';
import 'package:synquerra/screens/landing/home/profile_drawer/settings/account_screen.dart';
import 'package:synquerra/widgets/dummy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Helper method to navigate to the dummy screen
  void _navigateToDummy(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DummyScreen(title: title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 24),

          _buildAddNewDeviceButton(context),
          const SizedBox(height: 24),

          // --- ADDED: Divider line ---
          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: 24),

          // --- Clickable Settings Items ---
          _buildSettingsItem(
            context: context,
            icon: Icons.person,
            title: "Account",
            subtitle: "Manage your profile, security and notifications",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountSettingsScreen()),
            ),
          ),
          _buildSettingsItem(
            context: context,
            icon: Icons.devices,
            title: "Device Settings",
            subtitle: "Configure the behaviour and alerts",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DeviceSettingsScreen()),
            ),
          ),
          _buildSettingsItem(
            context: context,
            icon: Icons.smartphone,
            title: "General",
            subtitle: "Customize app language, privacy and accessibility",
            onTap: () => _navigateToDummy(context, "General Settings"),
          ),
          _buildSettingsItem(
            context: context,
            icon: Icons.settings,
            title: "Advanced",
            subtitle: "Manage API keys and account actions",
            onTap: () => _navigateToDummy(context, "Advanced Settings"),
          ),
        ],
      ),
    );
  }

  // --- WIDGET FOR THE TOP PROFILE HEADER ---
  Widget _buildProfileHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 35, // CHANGED: Larger radius
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.person,
          size: 35, // CHANGED: Larger icon
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(
        "Anil Gupta",
        style: TextStyle(
          fontSize: 24, // CHANGED: Bigger text
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        "DFZ61ZD5",
        style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
      ),
    );
  }

  // --- WIDGET FOR THE "ADD NEW DEVICE" BUTTON ---
  Widget _buildAddNewDeviceButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.purple, Colors.cyan], // As seen in the image
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton.icon(
        onPressed: () => _navigateToDummy(context, "Add New Device"),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add new device",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Make button transparent
          shadowColor: Colors.transparent, // No shadow
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // --- REUSABLE WIDGET FOR EACH CLICKABLE SETTINGS ITEM ---
  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4, // CHANGED: More elevation
      color: colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          icon,
          size: 30, // CHANGED: Larger icon
          color: colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20, // CHANGED: Bigger text
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 15, // CHANGED: Bigger text
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
