// lib/presentation/screens/manage_devices/widgets/assign_member_sheet.dart

import 'package:flutter/material.dart';
import '../../../../../domain/entities/device/device_entity.dart';
import '../../../../../domain/entities/relationship/related_user_entity.dart';
import '../../../../../domain/entities/relationship/relationship_entity.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/colors.dart';
import '../../../themes/app_tokens.dart';

import '../../../utils/app_icons.dart';
import '../../../widgets/app_overlays.dart';
import '../../../widgets/app_surfaces.dart';
import '../../../widgets/user_avatar.dart';

class AssignMemberSheet extends StatefulWidget {
  final DeviceEntity device;
  final String currentUserId;
  final String currentUserFullName;
  final List<RelationshipEntity> relationships;
  final void Function(String personId, String associationType) onAssign;

  const AssignMemberSheet({
    super.key,
    required this.device,
    required this.currentUserId,
    required this.currentUserFullName,
    required this.relationships,
    required this.onAssign,
  });

  static Future<void> show(
    BuildContext context, {
    required DeviceEntity device,
    required String currentUserId,
    required String currentUserFullName,
    required List<RelationshipEntity> relationships,
    required void Function(String personId, String associationType) onAssign,
  }) {
    return showAppBottomSheet<void>(
      context,
      builder: (_) => AssignMemberSheet(
        device: device,
        currentUserId: currentUserId,
        currentUserFullName: currentUserFullName,
        relationships: relationships,
        onAssign: onAssign,
      ),
    );
  }

  @override
  State<AssignMemberSheet> createState() => _AssignMemberSheetState();
}

class _AssignMemberSheetState extends State<AssignMemberSheet> {
  late String _selectedRole;
  late final Map<String, String> _availableRoles;
  late final List<RelatedUserEntity> _availablePersons;

  @override
  void initState() {
    super.initState();

    final isAssigned = widget.device.carrier != null;
    const allRoles = {
      'carrier': 'Carrier',
      'manager': 'Manager',
      'viewer': 'Viewer',
    };

    _availableRoles = Map.fromEntries(
      allRoles.entries.where((entry) => !isAssigned || entry.key != 'carrier'),
    );

    _selectedRole = _availableRoles.containsKey('carrier')
        ? 'carrier'
        : _availableRoles.keys.first;

    // Collect IDs of members already associated with this device
    final assignedPersonIds = <String>{
      for (final a in widget.device.assignments)
        if (a.userId.isNotEmpty) a.userId,
    };

    _availablePersons = <RelatedUserEntity>[];

    // TODO(logic): the "(Myself)" label is faked through lastName. Give the
    // picker its own model (name + isSelf) instead of a RelatedUserEntity.

    // Add current user as a choice if not already assigned
    if (!assignedPersonIds.contains(widget.currentUserId)) {
      _availablePersons.add(
        RelatedUserEntity(
          id: widget.currentUserId,
          uniqueId: widget.currentUserId,
          firstName: widget.currentUserFullName,
          lastName: '(Myself)',
        ),
      );
    }

    // Add related contacts if they are not already assigned
    for (final rel in widget.relationships) {
      final user = rel.relatedUser;
      if (user != null && !assignedPersonIds.contains(user.id)) {
        _availablePersons.add(user);
      }
    }
  }

  Future<void> _confirmAssignment(RelatedUserEntity person) async {
    final roleLabel = _availableRoles[_selectedRole] ?? _selectedRole;
    final personName = person.fullName.isEmpty
        ? 'Unnamed Member'
        : person.fullName;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Assignment'),
        content: Text('Assign $personName as $roleLabel for this device?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.pop(context); // close the bottom sheet
      widget.onAssign(person.id, _selectedRole);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.viewInsetsOf(context).bottom,
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
                'Assign Device to Person',
                style: AppTextStyles.titleWithColor(context),
              ),
              Text(
                'Select a role and a person to assign to this device.',
                style: AppTextStyles.bodyWithColor(context),
              ),
            ],
          ),
          DropdownButtonFormField<String>(
            initialValue: _selectedRole,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Role / Association Type',
              prefixIcon: Icon(
                AppIcons.relationship,
                size: AppSize.icon,
                color: AppColors.textSecondary(context),
              ),
            ),
            items: [
              for (final e in _availableRoles.entries)
                DropdownMenuItem(value: e.key, child: Text(e.value)),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedRole = val);
            },
          ),
          Text('Select person', style: AppTextStyles.sectionWithColor(context)),
          Flexible(
            child: _availablePersons.isEmpty
                ? Padding(
                    padding: AppSpacing.lgVertical,
                    child: Center(
                      child: Text(
                        'All available contacts are already assigned.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyWithColor(context),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final person in _availablePersons)
                          _personRow(context, person),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _personRow(BuildContext context, RelatedUserEntity person) {
    final isSelf = person.id == widget.currentUserId;
    return InsetRow(
      onTap: () => _confirmAssignment(person),
      child: Row(
        spacing: AppSpacing.smd,
        children: [
          UserAvatar(
            name: isSelf ? widget.currentUserFullName : person.fullName,
            photoUrl: person.profilePhoto,
            radius: AppSize.tile / 2,
          ),
          Expanded(
            child: Text(
              person.fullName.isEmpty ? 'Unnamed Member' : person.fullName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyWithColor(
                context,
                color: AppColors.textPrimary(context),
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Icon(AppIcons.chevron, color: AppColors.primary(context)),
        ],
      ),
    );
  }
}
