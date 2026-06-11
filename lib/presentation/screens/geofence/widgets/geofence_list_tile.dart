import 'package:flutter/material.dart';
import '../../../../domain/entities/geofence/geofence_entity.dart';

class GeofenceListTile extends StatelessWidget {
  final GeofenceEntity geofence;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GeofenceListTile({
    super.key,
    required this.geofence,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // final zoneColor = _hexToColor(geofence.geofenceColor);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: colors.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // ── Name + status ──────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    geofence.geofenceName,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: geofence.isActive
                              ? colors.primaryContainer
                              : colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          geofence.isActive ? 'Active' : 'Inactive',
                          style: textTheme.labelSmall?.copyWith(
                            color: geofence.isActive
                                ? colors.onPrimaryContainer
                                : colors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (geofence.isSyncToDevice) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.sync_rounded,
                          size: 14,
                          color: colors.primary,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // ── Edit + Delete icons ────────────────
            IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, size: 20, color: colors.primary),
              visualDensity: VisualDensity.compact,
              tooltip: 'Edit',
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: colors.error,
              ),
              visualDensity: VisualDensity.compact,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}
