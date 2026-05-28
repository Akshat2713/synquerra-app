// presentation/screens/device_detail/widgets/detail_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synquerra/rework/presentation/blocs/theme/theme_cubit.dart';
import 'package:synquerra/rework/presentation/screens/device_detail/widgets/drawer_item.dart';
import '../../../../domain/entities/analytics/analytics_entity.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../../app/app_router.dart';
import '../../../blocs/analytics/analytics_bloc.dart';

class DetailDrawer extends StatelessWidget {
  final String userName;
  final String imei;
  final DeviceEntity device; // DeviceEntity
  // final AnalyticsEntity? analytics; // 1. Add this field

  const DetailDrawer({
    super.key,
    required this.userName,
    required this.imei,
    required this.device,
    // required this.analytics, // 2. Optional parameter
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
                color: colors.primary.withOpacity(0.08),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: colors.primary.withOpacity(0.15),
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
              onTap: () {
                final state = context.read<AnalyticsBloc>().state;
                AnalyticsEntity? latest;
                if (state is AnalyticsLoaded && state.points.isNotEmpty) {
                  latest = state.points.first; // Grab the point
                }

                debugPrint('Passing to profile! Phone1 is: ${latest?.phone1}');
                // Navigator.pop(context);
                // TODO: Navigator.pushNamed(context, AppRoutes.profile);
                Navigator.pushNamed(
                  context,
                  AppRoutes.profile,
                  arguments: {
                    'device': device, // DeviceEntity
                    'analytics': latest, // AnalyticsEntity?
                  }, // DeviceEntity
                );
              },
            ),
            DrawerItem(
              icon: Icons.analytics_outlined,
              label: 'Telemetry History',
              onTap: () {
                // Navigator.pop(context);
                // Push from anywhere with:
                Navigator.pushNamed(
                  context,
                  AppRoutes.telemetryHistory,
                  arguments: device, // DeviceEntity
                );
                // TODO: Navigator.pushNamed(context, AppRoutes.telemetryHistory);
              },
            ),
            DrawerItem(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.alertsErrors,
                  arguments: device.imei, // String
                );
                // Navigator.pop(context);
                // TODO: Navigator.pushNamed(context, AppRoutes.notifications);
              },
            ),
            DrawerItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigator.pushNamed(context, AppRoutes.settings);
              },
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
                    activeColor: colors.primary,
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

// ── Extracted StatelessWidget ────────────────────────────────────────────────
