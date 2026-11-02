import 'package:flutter/material.dart';
import '../../../../../domain/entities/device/device_association_entity.dart';
import '../../../../../domain/entities/device/device_entity.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/app_icons.dart';
import '../../../widgets/app_overlays.dart';
import '../../../widgets/app_surfaces.dart';
import '../../../widgets/user_avatar.dart';

class UnassignConfirmSheet extends StatelessWidget {
  final DeviceEntity device;
  final void Function(String personId, String associationType) onUnassign;

  const UnassignConfirmSheet({
    super.key,
    required this.device,
    required this.onUnassign,
  });

  static Future<void> show(
    BuildContext context, {
    required DeviceEntity device,
    required void Function(String personId, String associationType) onUnassign,
  }) {
    return showAppBottomSheet<void>(
      context,
      builder: (_) =>
          UnassignConfirmSheet(device: device, onUnassign: onUnassign),
    );
  }

  // TODO(logic): duplicated in assign_member_sheet.dart. Move role labels to
  // one place (entity or util).
  static const Map<String, String> _roleLabels = {
    'carrier': 'Carrier',
    'manager': 'Manager',
    'viewer': 'Viewer',
  };

  String _roleLabelFor(String roleKey) =>
      _roleLabels[roleKey] ??
      (roleKey.isEmpty
          ? 'Unknown Role'
          : roleKey[0].toUpperCase() + roleKey.substring(1));

  @override
  Widget build(BuildContext context) {
    final assignments = device.assignments;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.xs,
            children: [
              Text(
                'Unassign Member',
                style: AppTextStyles.titleWithColor(context),
              ),
              Text(
                'Select an assigned person to remove from this device.',
                style: AppTextStyles.bodyWithColor(context),
              ),
            ],
          ),
          Flexible(
            child: assignments.isEmpty
                ? Padding(
                    padding: AppSpacing.lgVertical,
                    child: Center(
                      child: Text(
                        'No one is currently assigned to this device.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyWithColor(context),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final a in assignments)
                          _AssignmentRow(
                            assignment: a,
                            roleLabel: _roleLabelFor(a.assignmentType),
                            onTap: () {
                              Navigator.pop(context);
                              onUnassign(a.userId, a.assignmentType);
                            },
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentRow extends StatelessWidget {
  final DeviceAssociationEntity assignment;
  final String roleLabel;
  final VoidCallback onTap;

  const _AssignmentRow({
    required this.assignment,
    required this.roleLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = assignment.name.trim().isEmpty
        ? 'Unnamed Member'
        : assignment.name.trim();

    return InsetRow(
      onTap: onTap,
      child: Row(
        spacing: AppSpacing.smd,
        children: [
          UserAvatar(
            name: name,
            photoUrl: assignment.profile,
            radius: AppSize.tile / 2,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xs,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyWithColor(
                    context,
                    color: AppColors.textPrimary(context),
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                InfoPill(
                  label: roleLabel,
                  background: AppColors.primaryContainer(context),
                  foreground: AppColors.onPrimaryContainer(context),
                ),
              ],
            ),
          ),
          IconTile(
            size: AppSize.avatarSm,
            iconSize: AppSize.iconSm,
            icon: AppIcons.personRemove,
            background: AppColors.dangerContainer,
            foreground: AppColors.danger,
          ),
        ],
      ),
    );
  }
}
