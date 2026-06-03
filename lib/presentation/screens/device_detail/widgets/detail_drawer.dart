// presentation/screens/device_detail/widgets/detail_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synquerra/presentation/blocs/theme/theme_cubit.dart';
import 'package:synquerra/presentation/screens/device_detail/widgets/drawer_item.dart';
import '../../../../domain/entities/device/device_entity.dart';

// Notice: Removed app_router.dart, analytics_entity.dart, and analytics_bloc.dart imports!

class DetailDrawer extends StatelessWidget {
  final String userName;
  final String imei;
  final DeviceEntity device;
  final VoidCallback onProfileTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onAlertsTap;
  final VoidCallback onSettingsTap;

  const DetailDrawer({
    super.key,
    required this.userName,
    required this.imei,
    required this.device,
    required this.onProfileTap,
    required this.onHistoryTap,
    required this.onAlertsTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // ── User header ──────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: colors.primary.withValues(alpha: 0.15),
                    child: Icon(
                      Icons.person_rounded,
                      color: colors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          imei,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Menu items ───────────────────────────
            DrawerItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              onTap: onProfileTap, // Delegated to parent
            ),
            DrawerItem(
              icon: Icons.analytics_outlined,
              label: 'Telemetry History',
              onTap: onHistoryTap, // Delegated to parent
            ),
            DrawerItem(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: onAlertsTap, // Delegated to parent
            ),
            DrawerItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: onSettingsTap, // Delegated to parent
            ),

            const Divider(indent: 16, endIndent: 16),

            // ── Theme toggle ─────────────────────────
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                final isDark = themeMode == ThemeMode.dark;
                return DrawerItem(
                  icon: isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  label: isDark ? 'Dark Mode' : 'Light Mode',
                  onTap: () => context.read<ThemeCubit>().toggle(),
                  trailing: Switch(
                    value: isDark,
                    onChanged: (_) => context.read<ThemeCubit>().toggle(),
                    activeThumbColor: colors.primary,
                  ),
                );
              },
            ),

            const Spacer(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
