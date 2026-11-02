import 'package:flutter/material.dart';
import '../../../../../domain/entities/device/device_entity.dart';
import '../../../../../domain/entities/relationship/relationship_entity.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/app_icons.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_surfaces.dart';
import 'assign_member_sheet.dart';
import 'unassign_confirm_sheet.dart';

class ManageDeviceCard extends StatelessWidget {
  final DeviceEntity device;
  final String currentUserFullName;
  final String currentUserId;
  final List<RelationshipEntity> relationships;
  final void Function(String personId, String associationType) onAssign;
  final void Function(String personId, String associationType) onUnassign;
  final bool isProcessing;

  const ManageDeviceCard({
    super.key,
    required this.device,
    required this.currentUserFullName,
    required this.currentUserId,
    required this.relationships,
    required this.onAssign,
    required this.onUnassign,
    this.isProcessing = false,
  });

  bool get _isAssigned => device.carrier != null;
  bool get _hasAnyAssignment => device.assignments.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final assignedCount = device.assignments.length;

    return AppCard(
      // tint: _isAssigned ? null : AppColors.warningContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.smd,
        children: [
          Row(
            spacing: AppSpacing.smd,
            children: [
              IconTile(
                icon: AppIcons.devices,
                background: _isAssigned ? AppColors.success : AppColors.warning,
                foreground: _isAssigned
                    ? AppColors.onSuccess
                    : AppColors.onWarning,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.xs,
                  children: [
                    Text(
                      device.displayOwnerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sectionWithColor(context),
                    ),
                    Text(
                      'S/N: ${device.serialNo}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.mono.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              InfoPill(
                label: _isAssigned ? 'Assigned' : 'Unassigned',
                dotColor: _isAssigned ? AppColors.success : AppColors.warning,
                background: _isAssigned
                    ? AppColors.successContainer
                    : AppColors.warningContainer,
                foreground: AppColors.textPrimary(context),
              ),
            ],
          ),
          InsetRow(
            child: Row(
              spacing: AppSpacing.md,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.xs,
                    children: [
                      Text(
                        'Carrier',
                        style: AppTextStyles.metaWithColor(context),
                      ),
                      Text(
                        _isAssigned ? device.carrier!.name : 'Not assigned',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyWithColor(
                          context,
                          color: AppColors.textPrimary(context),
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                if (assignedCount > 0)
                  InfoPill(
                    label: '$assignedCount',
                    icon: AppIcons.person,
                    background: AppColors.primaryContainer(context),
                    foreground: AppColors.onPrimaryContainer(context),
                  ),
              ],
            ),
          ),
          Row(
            spacing: AppSpacing.sm,
            children: [
              if (_hasAnyAssignment)
                Expanded(
                  child: SizedBox(
                    height: AppSize.tapTarget,
                    child: OutlinedButton.icon(
                      onPressed: isProcessing
                          ? null
                          : () => UnassignConfirmSheet.show(
                              context,
                              device: device,
                              onUnassign: onUnassign,
                            ),
                      icon: Icon(AppIcons.personRemove, size: AppSize.iconSm),
                      label: const Text('Unassign'),
                    ),
                  ),
                ),
              Expanded(
                child: AppButton(
                  label: 'Assign',
                  isLoading: isProcessing,
                  onPressed: () => AssignMemberSheet.show(
                    context,
                    device: device,
                    currentUserId: currentUserId,
                    currentUserFullName: currentUserFullName,
                    relationships: relationships,
                    onAssign: onAssign,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
