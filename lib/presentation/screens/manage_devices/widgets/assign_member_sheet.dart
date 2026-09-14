// lib/presentation/screens/manage_devices/widgets/assign_member_sheet.dart

import 'package:flutter/material.dart';
import '../../../../../domain/entities/device/device_entity.dart';
import '../../../../../domain/entities/relationship/related_user_entity.dart';
import '../../../../../domain/entities/relationship/relationship_entity.dart';
import '../../../themes/colors.dart';

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
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
      for (final a in widget.device.associations)
        if (a.person != null) a.person!.id,
    };

    _availablePersons = <RelatedUserEntity>[];

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

  @override
  Widget build(BuildContext context) {
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
            'Assign Device to Person',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Select a role and a person to assign to this device.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedRole,
            decoration: InputDecoration(
              labelText: 'Role / Association Type',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant(
                context,
              ).withValues(alpha: 0.3),
            ),
            items: _availableRoles.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedRole = val);
              }
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Select Person',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: _availablePersons.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'All available contacts are already assigned.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: _availablePersons.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final person = _availablePersons[index];
                      final hasPhoto =
                          person.profilePhoto != null &&
                          person.profilePhoto!.isNotEmpty;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryContainer
                              .withValues(alpha: 0.5),
                          backgroundImage: hasPhoto
                              ? NetworkImage(person.profilePhoto!)
                              : null,
                          child: !hasPhoto
                              ? Icon(
                                  Icons.person_outline_rounded,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                        title: Text(
                          person.fullName.isEmpty
                              ? 'Unnamed Member'
                              : person.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.pop(context);
                          widget.onAssign(person.id, _selectedRole);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
