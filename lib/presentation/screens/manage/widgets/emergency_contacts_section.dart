import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../domain/entities/settings/settings_entity.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/unit_formatter.dart';
import '../../../widgets/app_motion_widgets.dart';
import '../../../widgets/app_surfaces.dart';
import 'edit_contacts_sheet.dart';

const _kNoPrimary = 'No Primary Number';
const _kNoSecondary = 'No Secondary Number';

String _value(String? n) =>
    (n == null || n == _kNoPrimary || n == _kNoSecondary) ? '' : n;

class EmergencyContactsSection extends StatelessWidget {
  final String deviceId;
  final SettingsEntity settings;
  final bool isUpdating;
  final void Function(String phoneNum1, String phoneNum2)? onSaveContacts;

  const EmergencyContactsSection({
    super.key,
    required this.deviceId,
    required this.settings,
    this.isUpdating = false,
    this.onSaveContacts,
  });

  void _edit(BuildContext context) {
    if (isUpdating) return;
    showEditContactsSheet(
      context,
      primary: _value(settings.phoneNum1),
      secondary: _value(settings.phoneNum2),
      onSave: (p1, p2) => onSaveContacts?.call(p1, p2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconTile(
                icon: Icons.emergency_rounded,
                background: AppColors.dangerContainer,
                foreground: AppColors.danger,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency contacts',
                      style: AppTextStyles.sectionWithColor(context),
                    ),
                    Text(
                      'Called when this device sends SOS',
                      style: AppTextStyles.metaWithColor(context),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: AppSize.tapTarget,
                child: AnimatedSwitcher(
                  duration: AppMotion.base,
                  child: isUpdating
                      ? Padding(
                          key: const ValueKey('loading'),
                          padding: AppSpacing.mdAll,
                          child: SizedBox.square(
                            dimension: AppSize.icon,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: AppSize.stroke,
                            ),
                          ),
                        )
                      : TextButton.icon(
                          key: const ValueKey('edit'),
                          onPressed: () => _edit(context),
                          icon: const Icon(
                            Icons.edit_rounded,
                            size: AppSize.iconSm,
                          ),
                          label: const Text('Edit'),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedOpacity(
            duration: AppMotion.base,
            opacity: isUpdating ? AppAlpha.disabled : 1,
            child: Column(
              children: [
                _ContactTile(
                  role: 'Primary',
                  badge: 'Called first',
                  number: _value(settings.phoneNum1),
                  emptyText: _kNoPrimary,
                  isPrimary: true,
                  onTap: () => _edit(context),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ContactTile(
                  role: 'Secondary',
                  badge: 'Backup',
                  number: _value(settings.phoneNum2),
                  emptyText: _kNoSecondary,
                  isPrimary: false,
                  onTap: () => _edit(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final String role;
  final String badge;
  final String number;
  final String emptyText;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ContactTile({
    required this.role,
    required this.badge,
    required this.number,
    required this.emptyText,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final empty = number.isEmpty;
    final primary = AppColors.primary(context);

    return Material(
      color: AppColors.surfaceVariant(context),
      borderRadius: AppRadius.lgAll,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: AppSpacing.mdAll,
          child: Row(
            children: [
              IconTile(
                circle: true,
                icon: empty
                    ? Icons.add_rounded
                    : (isPrimary
                          ? Icons.phone_in_talk_rounded
                          : Icons.phone_rounded),
                background: empty
                    ? AppColors.surface(context)
                    : AppColors.primaryContainer(context),
                foreground: empty ? AppColors.textTertiary(context) : primary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(role, style: AppTextStyles.metaWithColor(context)),
                        const SizedBox(width: AppSpacing.sm),
                        _Pill(
                          label: badge,
                          background: isPrimary
                              ? AppColors.successContainer
                              : AppColors.offlineContainer,
                          foreground: isPrimary
                              ? AppColors.success
                              : AppColors.offline,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AnimatedText(
                      empty ? emptyText : UnitFormatter.formatPhone(number),
                      style: empty
                          ? AppTextStyles.bodyWithColor(
                              context,
                              color: AppColors.textTertiary(context),
                            )
                          : AppTextStyles.sectionWithColor(context),
                    ),
                  ],
                ),
              ),
              empty
                  ? Text(
                      'Add',
                      style: AppTextStyles.sectionWithColor(
                        context,
                        color: primary,
                      ),
                    )
                  : Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textTertiary(context),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: background,
      borderRadius: AppRadius.pillAll,
    ),
    child: Text(
      label,
      style: AppTextStyles.microWithColor(context, color: foreground),
    ),
  );
}
