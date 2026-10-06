// lib/presentation/screens/device_list/widgets/profile_menu_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/auth/user_entity.dart';
import '../../../blocs/theme/theme_cubit.dart';
import '../../../themes/app_palette.dart';
import '../../../themes/colors.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';

/// Account menu: user header, theme dropdown and logout.
///
/// ASSUMES ThemeCubit is `Cubit<AppThemeType>` with `select(AppThemeType)`.
class ProfileMenuButton extends StatelessWidget {
  final UserEntity? user;
  final VoidCallback? onLogout;

  const ProfileMenuButton({super.key, this.user, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.person_outline_rounded),
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
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
                  const SizedBox(height: AppSpacing.xs),
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
          value: 'theme',
          child: Builder(
            builder: (menuCtx) {
              final current = menuCtx.watch<ThemeCubit>().state;
              return SizedBox(
                width: 190,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.palette_outlined,
                          size: 16,
                          color: AppColors.textSecondary(menuCtx),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Theme',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(menuCtx),
                          ),
                        ),
                      ],
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<AppThemeType>(
                        value: current,
                        isExpanded: true,
                        isDense: true,
                        borderRadius: AppRadius.mdAll,
                        dropdownColor: AppColors.surface(menuCtx),
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary(menuCtx),
                        ),
                        items: AppThemeType.values
                            .map(
                              (t) => DropdownMenuItem<AppThemeType>(
                                value: t,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: t.swatch,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.outline(menuCtx),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      t.label,
                                      style: TextStyle(
                                        color: AppColors.textPrimary(menuCtx),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (type) {
                          if (type == null) return;
                          menuCtx.read<ThemeCubit>().select(type);
                          // Dropdown route is already closed here; close the menu too.
                          if (menuCtx.mounted) Navigator.of(menuCtx).pop();
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              const Icon(
                Icons.logout_rounded,
                color: AppColors.danger,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
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
