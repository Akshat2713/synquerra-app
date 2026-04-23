// lib/presentation/screens/profile/my_profile_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synquerra/presentation/widgets/feedback/feedback_screen.dart';
import '../../../business/blocs/auth_bloc/auth_bloc.dart';
import '../../../business/blocs/theme_bloc/theme_bloc.dart';
import '../../widgets/dialogs/logout_dialog.dart';
import '../../widgets/profile/profile_avatar.dart';
import '../../widgets/profile/drawer_menu_item.dart';
import '../../widgets/profile/drawer_menu_section.dart';
import '../../widgets/profile/theme_toggle_item.dart';
import '../../themes/colors.dart';
import 'personal_information_screen.dart';
import 'device_information_screen.dart';
import 'subscription_status_screen.dart';
// import 'feedback_screen.dart';
import '../settings/settings_screen.dart';

class MyProfileDrawer extends StatelessWidget {
  const MyProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.2),
                      colorScheme.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ProfileAvatar(name: user?.fullName ?? 'User', size: 70),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.fullName ?? 'User Name',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? 'user@example.com',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildQuickStat(
                          context,
                          icon: Icons.devices_rounded,
                          label: "Devices",
                          value: "1",
                        ),
                        const SizedBox(width: 16),
                        _buildQuickStat(
                          context,
                          icon: Icons.subscriptions_rounded,
                          label: "Plan",
                          value: "Premium",
                        ),
                        const SizedBox(width: 16),
                        _buildQuickStat(
                          context,
                          icon: Icons.verified_rounded,
                          label: "Status",
                          value: "Active",
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Navigation Menu
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    DrawerMenuSection(
                      title: "ACCOUNT",
                      children: [
                        DrawerMenuItem(
                          icon: Icons.person_rounded,
                          label: 'Personal Information',
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PersonalInformationScreen(),
                              ),
                            );
                          },
                        ),
                        DrawerMenuItem(
                          icon: Icons.app_registration_rounded,
                          label: 'Device Information',
                          color: Colors.purple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DeviceInformationScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    DrawerMenuSection(
                      title: "SUBSCRIPTION",
                      children: [
                        DrawerMenuItem(
                          icon: Icons.subscriptions_rounded,
                          label: 'Subscription Status',
                          color: Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const SubscriptionStatusScreen(),
                              ),
                            );
                          },
                        ),
                        DrawerMenuItem(
                          icon: Icons.payment_rounded,
                          label: 'Recharge & Renewal',
                          color: Colors.orange,
                          onTap: () {
                            // TODO: Navigate to Recharge & Renewal
                          },
                        ),
                      ],
                    ),

                    DrawerMenuSection(
                      title: "PREFERENCES",
                      children: [
                        DrawerMenuItem(
                          icon: Icons.settings_rounded,
                          label: 'Settings',
                          color: Colors.indigo,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                        DrawerMenuItem(
                          icon: Icons.feedback_rounded,
                          label: 'Feedback',
                          color: Colors.teal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FeedbackScreen(),
                              ),
                            );
                          },
                        ),
                        const ThemeToggleItem(),
                      ],
                    ),
                  ],
                ),
              ),

              // Logout Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: _buildLogoutButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showDialog(
          context: context,
          builder: (context) => const LogoutDialog(),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.emergencyRed.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: AppColors.emergencyRed,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.emergencyRed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
