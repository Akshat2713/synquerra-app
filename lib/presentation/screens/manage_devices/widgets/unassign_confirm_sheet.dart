// lib/presentation/screens/manage_devices/widgets/unassign_confirm_sheet.dart

import 'package:flutter/material.dart';
import '../../../../../domain/entities/device/device_entity.dart';
import '../../../../../domain/entities/signup/person_entity.dart';
import '../../../themes/colors.dart';

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

  @override
  Widget build(BuildContext context) {
    final carrierAssoc = device.associationFor('carrier');
    final managerAssoc = device.associationFor('manager');
    final viewerAssoc = device.associationFor('viewer');

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
            'Unassign Role',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Select an assigned person or role to remove.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildRoleSection(
                  context: context,
                  roleTitle: 'Carrier',
                  roleKey: 'carrier',
                  person: carrierAssoc?.person,
                  icon: Icons.directions_walk_rounded,
                ),
                const Divider(height: 16),
                _buildRoleSection(
                  context: context,
                  roleTitle: 'Manager',
                  roleKey: 'manager',
                  person: managerAssoc?.person,
                  icon: Icons.admin_panel_settings_outlined,
                ),
                const Divider(height: 16),
                _buildRoleSection(
                  context: context,
                  roleTitle: 'Viewer',
                  roleKey: 'viewer',
                  person: viewerAssoc?.person,
                  icon: Icons.visibility_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSection({
    required BuildContext context,
    required String roleTitle,
    required String roleKey,
    required PersonEntity? person,
    required IconData icon,
  }) {
    final isAssignedToRole = person != null;
    final personName = isAssignedToRole
        ? '${person.firstName} ${person.lastName}'.trim()
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              roleTitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: CircleAvatar(
            backgroundColor: isAssignedToRole
                ? AppColors.dangerContainer.withValues(alpha: 0.4)
                : AppColors.surfaceVariant(context),
            child: Icon(
              Icons.person_outline_rounded,
              color: isAssignedToRole
                  ? AppColors.danger
                  : AppColors.textSecondary(context),
            ),
          ),
          title: Text(
            personName ?? 'No $roleTitle Assigned',
            style: TextStyle(
              fontWeight: isAssignedToRole
                  ? FontWeight.w600
                  : FontWeight.normal,
              color: isAssignedToRole
                  ? AppColors.textPrimary(context)
                  : AppColors.textSecondary(context),
              fontSize: 14,
            ),
          ),
          trailing: isAssignedToRole
              ? IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: AppColors.danger,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onUnassign(person.personId, roleKey);
                  },
                )
              : null,
          onTap: isAssignedToRole
              ? () {
                  Navigator.pop(context);
                  onUnassign(person.personId, roleKey);
                }
              : null,
        ),
      ],
    );
  }
}
