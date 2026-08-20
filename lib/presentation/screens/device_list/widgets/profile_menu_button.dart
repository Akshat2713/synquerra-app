// lib/presentation/screens/device_list/widgets/profile_menu_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/auth/user_entity.dart';
import '../../../blocs/theme/theme_cubit.dart';
import '../../../themes/colors.dart';

class ProfileMenuButton extends StatelessWidget {
  final UserEntity? user;
  final VoidCallback? onLogout;
  final VoidCallback? onManageUsers;
  final VoidCallback? onManageDevices;

  const ProfileMenuButton({
    super.key,
    this.user,
    this.onLogout,
    this.onManageUsers,
    this.onManageDevices,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.person_outline_rounded),
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Builder(
            builder: (menuCtx) {
              final liveColors = Theme.of(menuCtx).colorScheme;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.fullName ?? '—',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: liveColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.email ?? '—',
                    style: TextStyle(
                      fontSize: 12,
                      color: liveColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(height: 1, color: liveColors.outlineVariant),
                ],
              );
            },
          ),
        ),
        PopupMenuItem<String>(
          value: 'manage_users',
          enabled: true,
          child: Row(
            children: [
              Icon(
                Icons.people_alt_rounded,
                color: AppColors.textSecondary(context),
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                'Manage Users',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'manage_devices',
          enabled: true,
          child: Row(
            children: [
              Icon(
                Icons.developer_board_rounded,
                color: AppColors.textSecondary(context),
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                'Manage Devices',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
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
        switch (value) {
          case 'logout':
            onLogout?.call();
            break;
          case 'manage_devices':
            onManageDevices?.call();
            break;
          case 'manage_users':
            onManageUsers?.call();
            break;
        }
      },
    );
  }
}
