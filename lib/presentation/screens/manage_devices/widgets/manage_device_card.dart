// lib/presentation/screens/manage_devices/widgets/manage_device_card.dart

import 'package:flutter/material.dart';
import '../../../../../domain/entities/device/device_entity.dart';
import '../../../../../domain/entities/relationship/relationship_entity.dart';
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
                      onPressed: () => UnassignConfirmSheet.show(
                        context,
                        device: device,
                        onUnassign: onUnassign,
                      ),
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
                    onPressed: () => AssignMemberSheet.show(
                      context,
                      device: device,
                      currentUserId: currentUserId,
                      currentUserFullName: currentUserFullName,
                      relationships: relationships,
                      onAssign: onAssign,
                    ),
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
}
