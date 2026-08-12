import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/auth/user_entity.dart';
import '../../../app/app_router.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/device_list/device_list_bloc.dart';
import '../../../blocs/theme/theme_cubit.dart';

class ProfileMenuButton extends StatelessWidget {
  final UserEntity? user;
  const ProfileMenuButton({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
          enabled: false,
          child: Row(
            children: [
              Icon(
                Icons.people_alt_rounded,
                color: colors.onSurfaceVariant.withValues(alpha: 0.38),
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                'Manage Users',
                style: TextStyle(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.38),
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
                color: colors.onSurfaceVariant,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                'Manage Devices',
                style: TextStyle(
                  color: colors.onSurface,
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
                    color: colors.onSurfaceVariant,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isDark ? 'Dark Mode' : 'Light Mode',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: isDark,
                    onChanged: (_) => menuCtx.read<ThemeCubit>().toggle(),
                    activeThumbColor: colors.primary,
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
              Icon(Icons.logout_rounded, color: colors.error, size: 18),
              const SizedBox(width: 10),
              Text(
                'Logout',
                style: TextStyle(
                  color: colors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'logout') {
          context.read<AuthBloc>().add(const AuthLogoutRequested());
        } else if (value == 'manage_devices') {
          Navigator.pushNamed(
            context,
            AppRoutes.manageDevices,
            arguments: ManageDevicesArgs(
              deviceListBloc: context.read<DeviceListBloc>(),
            ),
          );
        }
      },
    );
  }
}
