import 'package:flutter/material.dart';
import '../../../../../domain/entities/device/device_entity.dart';
import '../../../../../domain/entities/relationship/relationship_entity.dart';
import '../../../../domain/entities/signup/person_entity.dart';

class ManageDeviceCard extends StatelessWidget {
  final DeviceEntity device;
  final String currentUserFullName;
  final String currentUserId;
  final List<RelationshipEntity> relationships;
  final Function(String personId, String associationType) onAssign;
  final Function(String personId, String associationType) onUnassign;
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: colors.onSurfaceVariant.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Device Info & Status Tag
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.devices_rounded,
                    color: colors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.displayOwnerName(currentUserFullName),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'S/N: ${device.serialNo}',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(colors),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Bottom Action Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Carrier / Assigned To',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isAssigned
                            ? '${device.carrier!.firstName} ${device.carrier!.lastName}'
                                  .trim()
                            : 'Unassigned',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _isAssigned ? colors.onSurface : colors.error,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isProcessing)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else ...[
                  // If assigned, show both Unassign and Assign buttons
                  if (_isAssigned) ...[
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.error,
                        side: BorderSide(
                          color: colors.error.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () => _showUnassignModal(context),
                      icon: const Icon(Icons.person_remove_rounded, size: 15),
                      label: const Text(
                        'Unassign',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Assign Button (Always available to add more assignments)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onPressed: () => _showAssignModal(context),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 15),
                    label: const Text(
                      'Assign',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _isAssigned
            ? colors.primary.withValues(alpha: 0.1)
            : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _isAssigned ? 'ASSIGNED' : 'UNASSIGNED',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _isAssigned ? colors.primary : colors.onSurfaceVariant,
        ),
      ),
    );
  }

  void _showAssignModal(BuildContext context) {
    final assignedPersonIds = <String>{
      for (final a in device.associations)
        if (a.person != null) a.person!.personId,
    };

    final availablePersons = <PersonEntity>[];

    // Add current user option (Myself) only if not already assigned
    if (!assignedPersonIds.contains(currentUserId)) {
      availablePersons.add(
        PersonEntity(
          personId: currentUserId,
          firstName: currentUserFullName,
          lastName: '(Myself)',
          isActive: true,
        ),
      );
    }

    // Add related persons (Person B) only if not already assigned
    for (final rel in relationships) {
      if (rel.personB != null &&
          !assignedPersonIds.contains(rel.personB!.personId)) {
        availablePersons.add(rel.personB!);
      }
    }

    const allRoles = {
      'carrier': 'Carrier',
      'manager': 'Manager',
      'viewer': 'Viewer',
    };

    final availableRoles = Map.fromEntries(
      allRoles.entries.where((entry) => !_isAssigned || entry.key != 'carrier'),
    );

    String selectedRole = availableRoles.containsKey('carrier')
        ? 'carrier'
        : availableRoles.keys.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final colors = Theme.of(modalContext).colorScheme;

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                top: 20,
                right: 16,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assign Device to Person',
                    style: Theme.of(modalContext).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select a role and a person to assign to this device.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Role Dropdown Selection
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
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
                      fillColor: colors.surfaceContainerHighest.withValues(
                        alpha: 0.3,
                      ),
                    ),
                    items: availableRoles.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedRole = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Select Person',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Person List
                  // Person List or Empty State
                  Flexible(
                    child: availablePersons.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                'All available contacts are already assigned.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: availablePersons.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final person = availablePersons[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: colors.primaryContainer
                                      .withValues(alpha: 0.5),
                                  child: Icon(
                                    Icons.person_outline_rounded,
                                    color: colors.primary,
                                  ),
                                ),
                                title: Text(
                                  '${person.firstName} ${person.lastName}'
                                      .trim(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                ),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  onAssign(person.personId, selectedRole);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showUnassignModal(BuildContext context) {
    final carrierAssoc = device.associationFor('carrier');
    final managerAssoc = device.associationFor('manager');
    final viewerAssoc = device.associationFor('viewer');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final colors = Theme.of(ctx).colorScheme;

        final carrierName = device.carrier != null
            ? '${device.carrier!.firstName} ${device.carrier!.lastName}'.trim()
            : null;

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            top: 20,
            right: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unassign Role',
                style: Theme.of(
                  ctx,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Select an assigned person or role to remove.',
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),

              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    // 1. Carrier Section
                    _buildRoleSection(
                      context: ctx,
                      roleTitle: 'Carrier',
                      roleKey: 'carrier',
                      person: carrierAssoc?.person,
                      icon: Icons.directions_walk_rounded,
                    ),
                    const Divider(height: 16),

                    // 2. Manager Section
                    _buildRoleSection(
                      context: ctx,
                      roleTitle: 'Manager',
                      roleKey: 'manager',
                      person: managerAssoc?.person,
                      icon: Icons.admin_panel_settings_outlined,
                    ),
                    const Divider(height: 16),

                    // 3. Viewer Section
                    _buildRoleSection(
                      context: ctx,
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
      },
    );
  }

  Widget _buildRoleSection({
    required BuildContext context,
    required String roleTitle,
    required String roleKey,
    required PersonEntity? person,
    required IconData icon,
  }) {
    final colors = Theme.of(context).colorScheme;
    final isAssignedToRole = person != null;
    final personName = isAssignedToRole
        ? '${person.firstName} ${person.lastName}'.trim()
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: colors.primary),
            const SizedBox(width: 6),
            Text(
              roleTitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.primary,
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
                ? colors.errorContainer.withValues(alpha: 0.4)
                : colors.surfaceContainerHighest,
            child: Icon(
              Icons.person_outline_rounded,
              color: isAssignedToRole ? colors.error : colors.onSurfaceVariant,
            ),
          ),
          title: Text(
            // isAssignedToRole ? personName : 'No $roleTitle Assigned',
            personName ?? 'No $roleTitle Assigned',
            style: TextStyle(
              fontWeight: isAssignedToRole
                  ? FontWeight.w600
                  : FontWeight.normal,
              color: isAssignedToRole
                  ? colors.onSurface
                  : colors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          trailing: isAssignedToRole
              ? IconButton(
                  icon: Icon(Icons.remove_circle_outline, color: colors.error),
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
