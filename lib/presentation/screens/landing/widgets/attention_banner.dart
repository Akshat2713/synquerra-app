import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/colour_util.dart';
import '../../../widgets/app_surfaces.dart';
import '../../../widgets/user_avatar.dart';
import '../../../../domain/entities/alerts/alert_entity.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../../../domain/utils/alert_device_matcher.dart';

class AttentionBanner extends StatelessWidget {
  final List<DeviceEntity> devices;
  final List<AlertEntity> alerts;
  final VoidCallback onTap;
  const AttentionBanner({
    super.key,
    required this.devices,
    required this.alerts,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // TODO(logic): move to domain/utils/alert_device_matcher.dart as
    // `devicesNeedingAttention(devices, alerts)`.
    final attention = devices
        .where(
          (d) => alertsForDevice(
            d,
            alerts,
          ).any((a) => a.isCritical && !a.isAcknowledged),
        )
        .toList();
    final ordered = [
      ...attention,
      ...devices.where((d) => !attention.contains(d)),
    ];

    final count = attention.length;
    final allClear = count == 0;
    final tone = allClear ? AppColors.success : AppColors.danger;
    final onTone = allClear ? AppColors.onSuccess : AppColors.onDanger;
    final toneBg = allClear
        ? AppColors.successContainer
        : AppColors.dangerContainer;

    return AppCard(
      tint: toneBg,
      padding: EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        borderRadius: AppRadius.lgAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Padding(
            padding: AppSpacing.mdAll,
            child: Row(
              children: [
                IconTile(
                  icon: allClear
                      ? Icons.verified_user_rounded
                      : Icons.warning_amber_rounded,
                  background: tone,
                  foreground: onTone,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        allClear
                            ? 'All devices are fine'
                            : '$count ${count == 1 ? 'device needs' : 'devices need'} attention',
                        style: AppTextStyles.bodyWithColor(
                          context,
                          color: AppColors.textPrimary(context),
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Of ${devices.length} ${devices.length == 1 ? 'device' : 'devices'}',
                        style: AppTextStyles.metaWithColor(context),
                      ),
                    ],
                  ),
                ),
                _AvatarStack(devices: ordered, alerts: alerts),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.chevron_right_rounded,
                  size: AppSize.icon,
                  color: AppColors.textSecondary(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  final List<DeviceEntity> devices;
  final List<AlertEntity> alerts;
  const _AvatarStack({required this.devices, required this.alerts});

  static const _maxShown = 3;
  static const _step = AppSize.avatarSm - AppSpacing.sm;

  @override
  Widget build(BuildContext context) {
    final shown = devices.take(_maxShown).toList();
    final extra = devices.length - shown.length;
    final slots = shown.length + (extra > 0 ? 1 : 0);
    if (slots == 0) return const SizedBox.shrink();

    return SizedBox(
      width: AppSize.avatarSm + (slots - 1) * _step,
      height: AppSize.avatarSm,
      child: Stack(
        children: [
          for (final (i, d) in shown.indexed)
            Positioned(
              left: i * _step,
              child: Container(
                width: AppSize.avatarSm,
                height: AppSize.avatarSm,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface(context),
                  border: Border.all(
                    color: deviceSeverityColor(
                      alertsForDevice(
                        d,
                        alerts,
                      ).where((a) => !a.isAcknowledged).toList(),
                    ),
                    width: AppSize.stroke,
                  ),
                ),
                child: UserAvatar(
                  name: d.displayOwnerName,
                  photoUrl: d.displayProfilePhoto,
                  radius: (AppSize.avatarSm - 2 * AppSize.stroke) / 2,
                ),
              ),
            ),
          if (extra > 0)
            Positioned(
              left: shown.length * _step,
              child: Container(
                width: AppSize.avatarSm,
                height: AppSize.avatarSm,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceVariant(context),
                  border: Border.all(
                    color: AppColors.surface(context),
                    width: AppSize.stroke,
                  ),
                ),
                child: Text(
                  '+$extra',
                  style: AppTextStyles.microWithColor(
                    context,
                    color: AppColors.textSecondary(context),
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
