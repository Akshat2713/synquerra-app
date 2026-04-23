// lib/presentation/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../business/blocs/auth_bloc/auth_bloc.dart';
import '../../../business/blocs/theme_bloc/theme_bloc.dart';
import '../../widgets/settings/settings_item_card.dart';
import '../../widgets/dialogs/logout_dialog.dart';
import '../../themes/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          _buildProfileHeader(context),
          const SizedBox(height: 24),

          const Divider(),
          const SizedBox(height: 16),

          // Settings Items
          SettingsItemCard(
            icon: Icons.person,
            title: "Account",
            subtitle: "Manage your profile, security and notifications",
            onTap: () {
              // TODO: Navigate to Account Settings
            },
          ),
          const SizedBox(height: 12),

          SettingsItemCard(
            icon: Icons.devices,
            title: "Device Settings",
            subtitle: "Configure the behaviour and alerts",
            onTap: () {
              // TODO: Navigate to Device Settings
            },
          ),
          const SizedBox(height: 12),

          // Theme Toggle
          _buildThemeToggle(context),
          const SizedBox(height: 12),

          // Logout Button
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.person,
            size: 35,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.fullName ?? 'User Name',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.imei ?? 'No Device',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode =
        context.watch<ThemeBloc>().state is ThemeReady &&
        (context.read<ThemeBloc>().state as ThemeReady).isDarkMode;

    return Card(
      elevation: 4,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          size: 30,
          color: Colors.amber,
        ),
        title: const Text(
          "Dark Mode",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: Switch.adaptive(
          value: isDarkMode,
          onChanged: (_) {
            context.read<ThemeBloc>().add(ThemeToggled());
          },
          activeColor: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.emergencyRed.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: Icon(Icons.logout_rounded, color: AppColors.emergencyRed),
        title: Text(
          "Logout",
          style: TextStyle(
            color: AppColors.emergencyRed,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => showDialog(
          context: context,
          builder: (context) => const LogoutDialog(),
        ),
      ),
    );
  }
}
