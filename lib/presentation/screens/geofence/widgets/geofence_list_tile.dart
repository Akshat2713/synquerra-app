import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import '../../../../domain/entities/geofence/geofence_entity.dart';
import 'geofence_status_chip.dart';

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
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          border: Border.all(color: AppColors.outlineVariant(context)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
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
                      GeofenceStatusChip(isActive: geofence.isActive),
                      if (geofence.isSyncToDevice) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.sync_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: Icon(
                Icons.edit_outlined,
                size: 20,
                color: AppColors.darkIconSecondary,
              ),
              visualDensity: VisualDensity.compact,
              tooltip: 'Edit',
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.danger,
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
