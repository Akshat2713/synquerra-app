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
  final Function(String associationType) onUnassign;
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
                else
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAssigned
                          ? colors.errorContainer
                          : colors.primary,
                      foregroundColor: _isAssigned
                          ? colors.onErrorContainer
                          : colors.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                    ),
                    onPressed: () {
                      if (_isAssigned) {
                        onUnassign('carrier');
                      } else {
                        _showAssignModal(context);
                      }
                    },
                    icon: Icon(
                      _isAssigned
                          ? Icons.person_remove_rounded
                          : Icons.person_add_alt_1_rounded,
                      size: 16,
                    ),
                    label: Text(
                      _isAssigned ? 'Unassign' : 'Assign',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
    final availablePersons = <PersonEntity>[];

    // Add current user option (Myself)
    availablePersons.add(
      PersonEntity(
        personId: currentUserId,
        firstName: currentUserFullName,
        lastName: '(Myself)',
        isActive: true,
      ),
    );

    // Add related persons (Person B)
    for (final rel in relationships) {
      if (rel.personB != null) {
        availablePersons.add(rel.personB!);
      }
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assign Device to Person',
                style: Theme.of(
                  ctx,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Select a related person to assign to this device as carrier.',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: availablePersons.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final person = availablePersons[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          ctx,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: Theme.of(ctx).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        '${person.firstName} ${person.lastName}'.trim(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pop(ctx);
                        onAssign(person.personId, 'carrier');
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
  }
}
