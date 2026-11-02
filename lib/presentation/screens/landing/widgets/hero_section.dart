import 'package:flutter/material.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/unit_formatter.dart';
import '../../../widgets/app_surfaces.dart';
import '../../../widgets/user_avatar.dart';
import '../../../../domain/entities/analytics/analytics_entity.dart';
import '../../../../domain/entities/device/device_entity.dart';

class HeroSection extends StatelessWidget {
  final DeviceEntity device;
  final AnalyticsEntity? latest;

  const HeroSection({super.key, required this.device, this.latest});

  @override
  Widget build(BuildContext context) {
    final name = device.displayOwnerName;
    final isOnline = device.isOnline ?? false;
    final onP = AppColors.onPrimary(context);
    final soft = AppAlpha.withAlpha(onP, AppAlpha.strong);
    final pillBg = AppAlpha.withAlpha(onP, AppAlpha.fill);
    final speed = latest?.speed;
    final moving = (speed ?? 0) > 0;
    final alert = latest?.alert;
    final hasAlert = alert != null && alert.isNotEmpty;

    return AnimatedOpacity(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AppMotion.base,
      opacity: isOnline ? 1 : 1 - AppAlpha.disabled,
      child: Container(
        padding: AppSpacing.mdAll,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient(context),
          borderRadius: AppRadius.lgAll,
          boxShadow: AppShadow.glow(AppColors.primary(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: AppSpacing.xsAll,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: pillBg, width: AppSize.stroke),
                  ),
                  child: UserAvatar(
                    name: name,
                    photoUrl: device.displayProfilePhoto,
                    radius: AppSize.avatarLg / 2,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name — online status (top-right corner)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.titleWithColor(
                                context,
                                color: onP,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Icon(
                            Icons.circle,
                            size: AppSize.dot,
                            color: isOnline ? AppColors.success : soft,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            isOnline ? 'Online' : 'Offline',
                            style: AppTextStyles.metaWithColor(
                              context,
                              color: onP,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      // Mode, plain text
                      Text(
                        device.currentMode,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyWithColor(
                          context,
                          color: soft,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Speed — movement
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          InfoPill(
                            label: speed != null
                                ? UnitFormatter.formatSpeed(speed, decimals: 0)
                                : '—',
                            icon: Icons.speed_rounded,
                            background: pillBg,
                            foreground: onP,
                          ),
                          InfoPill(
                            label: moving ? 'Travelling' : 'Stationary',
                            icon: moving
                                ? Icons.directions_walk_rounded
                                : Icons.pause_circle_outline_rounded,
                            background: pillBg,
                            foreground: onP,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Alert: full width, starts under the avatar
            Row(
              children: [
                Icon(
                  hasAlert
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline_rounded,
                  size: AppSize.icon,
                  color: soft,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    hasAlert ? alert : 'No recent alerts',
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyWithColor(context, color: onP),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
