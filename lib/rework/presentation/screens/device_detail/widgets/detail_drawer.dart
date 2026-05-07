import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synquerra/rework/presentation/blocs/theme/theme_cubit.dart';
import '../../../app/app_router.dart';
// import '../../../blocs/theme/theme_cubit.dart';

class DetailDrawer extends StatelessWidget {
  final String userName;
  final String imei;

  const DetailDrawer({super.key, required this.userName, required this.imei});

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
            _drawerItem(
              context: context,
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigator.pushNamed(context, AppRoutes.profile);
              },
            ),
            _drawerItem(
              context: context,
              icon: Icons.analytics_outlined,
              label: 'Telemetry History',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigator.pushNamed(context, AppRoutes.telemetryHistory);
              },
            ),
            _drawerItem(
              context: context,
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigator.pushNamed(context, AppRoutes.notifications);
              },
            ),
            _drawerItem(
              context: context,
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
                return _drawerItem(
                  context: context,
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

            // ── Logout ───────────────────────────────
            _drawerItem(
              context: context,
              icon: Icons.logout_rounded,
              label: 'Logout',
              iconColor: colors.error,
              labelColor: colors.error,
              onTap: () {
                Navigator.pop(context);
                // TODO: dispatch AuthLogoutRequested
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (_) => false,
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? labelColor,
    Widget? trailing,
  }) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? colors.onSurfaceVariant,
        size: 22,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: labelColor ?? colors.onSurface,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      horizontalTitleGap: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
