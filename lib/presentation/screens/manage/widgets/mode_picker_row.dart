import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../domain/entities/modes/mode_entity.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/mode_icon_resolver.dart';
import '../../../utils/unit_formatter.dart';
import '../../../widgets/app_motion_widgets.dart';
import '../../../widgets/app_surfaces.dart';
import 'mode_carousel.dart';
import 'mode_details_sheet.dart';

class ModePickerRow extends StatelessWidget {
  final List<ModeEntity> modes;
  final String? activeModeId;
  final bool isSwitching;
  final bool autoModeSwitch;
  final VoidCallback onAutoModeToggle;
  final ValueChanged<String> onChanged;

  const ModePickerRow({
    super.key,
    required this.modes,
    required this.activeModeId,
    required this.isSwitching,
    required this.autoModeSwitch,
    required this.onAutoModeToggle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final active = modes.isEmpty
        ? null
        : modes.firstWhere(
            (m) => m.id == activeModeId,
            orElse: () => modes.first,
          );
    final collapsed = autoModeSwitch || modes.isEmpty;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.mdAll,
            child: _AutoModeHeader(
              value: autoModeSwitch,
              enabled: !isSwitching,
              onChanged: onAutoModeToggle,
            ),
          ),
          Padding(
            padding: AppSpacing.mdHorizontal,
            child: active == null
                ? Padding(
                    padding: AppSpacing.lgVertical,
                    child: Center(
                      child: Text(
                        'No modes available',
                        style: AppTextStyles.metaWithColor(context),
                      ),
                    ),
                  )
                : _CurrentModeHero(
                    mode: active,
                    isAuto: autoModeSwitch,
                    isSwitching: isSwitching,
                  ),
          ),
          AnimatedSize(
            duration: AppMotion.base,
            curve: AppMotion.curve,
            alignment: Alignment.topCenter,
            child: collapsed
                ? const SizedBox(width: double.infinity, height: AppSpacing.md)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md,
                          0,
                        ),
                        child: Text(
                          'Choose a mode',
                          style: AppTextStyles.sectionWithColor(context),
                        ),
                      ),
                      ModeCarousel(
                        modes: modes,
                        selectedId: activeModeId,
                        enabled: !isSwitching,
                        onSelect: (m) {
                          if (m.id != activeModeId) onChanged(m.id);
                        },
                        onDetails: (m) => showModeDetailsSheet(context, m),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _AutoModeHeader extends StatelessWidget {
  final bool value;
  final bool enabled;
  final VoidCallback onChanged;

  const _AutoModeHeader({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconTile(
          icon: Icons.auto_awesome_rounded,
          background: value
              ? AppColors.primary(context)
              : AppColors.surfaceVariant(context),
          foreground: value
              ? AppColors.onPrimary(context)
              : AppColors.textSecondary(context),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Auto Mode', style: AppTextStyles.sectionWithColor(context)),
              AnimatedText(
                value
                    ? 'Device picks the best mode for you'
                    : 'You are choosing the mode manually',
                style: AppTextStyles.metaWithColor(context),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: enabled
              ? (_) {
                  HapticFeedback.selectionClick();
                  onChanged();
                }
              : null,
        ),
      ],
    );
  }
}

class _CurrentModeHero extends StatelessWidget {
  final ModeEntity mode;
  final bool isAuto;
  final bool isSwitching;

  const _CurrentModeHero({
    required this.mode,
    required this.isAuto,
    required this.isSwitching,
  });

  @override
  Widget build(BuildContext context) {
    final on = AppColors.onPrimary(context);
    final soft = AppAlpha.withAlpha(on, AppAlpha.fill);
    final muted = AppAlpha.withAlpha(on, AppAlpha.strong);
    final desc = mode.description.isNotEmpty
        ? mode.description
        : 'Location updates every ${UnitFormatter.formatDuration(mode.normalSendingInterval)}';

    return AnimatedContainer(
      duration: AppMotion.base,
      padding: AppSpacing.mdAll,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient(context),
        borderRadius: AppRadius.lgAll,
        boxShadow: AppShadow.glow(AppColors.primary(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(
                size: AppSize.tapTarget,
                background: soft,
                foreground: on,
                child: AnimatedSwitcher(
                  duration: AppMotion.base,
                  child: isSwitching
                      ? SizedBox.square(
                          key: const ValueKey('spinner'),
                          dimension: AppSize.icon,
                          child: CircularProgressIndicator(
                            strokeWidth: AppSize.stroke,
                            color: on,
                          ),
                        )
                      : Icon(
                          ModeIconResolver.resolve(mode),
                          key: ValueKey(mode.id),
                          color: on,
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAuto ? 'Auto Mode · using now' : 'Current mode',
                      style: AppTextStyles.metaWithColor(context, color: muted),
                    ),
                    AnimatedText(
                      mode.name,
                      maxLines: 1,
                      style: AppTextStyles.titleWithColor(context, color: on),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Mode details',
                icon: Icon(Icons.info_outline_rounded, color: on),
                onPressed: () => showModeDetailsSheet(context, mode),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedSize(
            duration: AppMotion.base,
            curve: AppMotion.curve,
            alignment: Alignment.topLeft,
            child: AnimatedText(
              desc,
              maxLines: 2,
              style: AppTextStyles.bodyWithColor(context, color: on),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _HeroChip(
                icon: Icons.schedule_rounded,
                label:
                    'Every ${UnitFormatter.formatDuration(mode.normalSendingInterval)}',
                fill: soft,
                color: on,
              ),
              _HeroChip(
                icon: Icons.sos_rounded,
                label:
                    'SOS ${UnitFormatter.formatDuration(mode.sosSendingInterval)}',
                fill: soft,
                color: on,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color fill;
  final Color color;

  const _HeroChip({
    required this.icon,
    required this.label,
    required this.fill,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(color: fill, borderRadius: AppRadius.pillAll),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSize.iconSm, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyles.metaWithColor(context, color: color)),
      ],
    ),
  );
}
