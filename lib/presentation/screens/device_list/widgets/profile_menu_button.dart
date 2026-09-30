// lib/presentation/screens/device_list/widgets/profile_menu_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/auth/user_entity.dart';
import '../../../blocs/theme/theme_cubit.dart';
import '../../../themes/colors.dart';

/// Account menu: user header, theme toggle and logout.
/// All other navigation lives in the bottom NavigationBar.
class ProfileMenuButton extends StatelessWidget {
  final UserEntity? user;
  final VoidCallback? onLogout;

  const ProfileMenuButton({super.key, this.user, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.person_outline_rounded),
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          value: 'header',
          enabled: false,
          child: Builder(
            builder: (menuCtx) {
              final colors = Theme.of(menuCtx).colorScheme;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.fullName ?? '—',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.email ?? '—',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(height: 1, color: colors.outlineVariant),
                ],
              );
            },
          ),
        ),
        PopupMenuItem<String>(
          value: 'toggle_theme',
          child: Builder(
            builder: (menuCtx) {
              final isDark =
                  menuCtx.watch<ThemeCubit>().state == ThemeMode.dark;
              return Row(
                children: [
                  Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: AppColors.textSecondary(context),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isDark ? 'Dark Mode' : 'Light Mode',
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: isDark,
                    onChanged: (_) => menuCtx.read<ThemeCubit>().toggle(),
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              );
            },
          ),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, color: AppColors.danger, size: 18),
              const SizedBox(width: 10),
              Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'logout') onLogout?.call();
      },
    );
  }
}
