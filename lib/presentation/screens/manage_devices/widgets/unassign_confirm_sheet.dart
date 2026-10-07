// lib/presentation/screens/manage_devices/widgets/unassign_confirm_sheet.dart

import 'package:flutter/material.dart';
import '../../../../../domain/entities/device/device_association_entity.dart';
import '../../../../../domain/entities/device/device_entity.dart';
import '../../../themes/colors.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';

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
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          UnassignConfirmSheet(device: device, onUnassign: onUnassign),
    );
  }

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
      padding: EdgeInsets.only(
        left: 16,
        top: 20,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unassign Member',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Select an assigned person to remove from this device.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: assignments.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Center(
                      child: Text(
                        'No one is currently assigned to this device.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: assignments.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final assignment = assignments[index];
                      return _buildAssignmentTile(context, assignment);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentTile(
    BuildContext context,
    DeviceAssociationEntity assignment,
  ) {
    final hasPhoto =
        assignment.profile != null && assignment.profile!.isNotEmpty;
    final displayName = assignment.name.trim().isEmpty
        ? 'Unnamed Member'
        : assignment.name.trim();

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: CircleAvatar(
        backgroundColor: AppColors.dangerContainer.withValues(alpha: AppAlpha.border),
        backgroundImage: hasPhoto ? NetworkImage(assignment.profile!) : null,
        child: !hasPhoto
            ? Icon(Icons.person_outline_rounded, color: AppColors.danger)
            : null,
      ),
      title: Text(
        displayName,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        _roleLabelFor(assignment.assignmentType),
        style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
      ),
      trailing: IconButton(
        icon: Icon(Icons.remove_circle_outline, color: AppColors.danger),
        onPressed: () {
          Navigator.pop(context);
          onUnassign(assignment.userId, assignment.assignmentType);
        },
      ),
      onTap: () {
        Navigator.pop(context);
        onUnassign(assignment.userId, assignment.assignmentType);
      },
    );
  }
}
