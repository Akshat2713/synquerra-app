import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import '../../../../domain/entities/geofence/geofence_entity.dart';
import 'geofence_status_chip.dart';

class GeofenceListTile extends StatelessWidget {
  final GeofenceEntity geofence;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Opens the "Configure trigger mode" dialog. Icon is hidden when null.
  final VoidCallback? onMode;

  /// Name of the mode already attached to this geofence, if any.
  final String? modeName;

  const GeofenceListTile({
    super.key,
    required this.geofence,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onMode,
    this.modeName,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasMode = modeName != null;

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
                          color: AppColors.success,
                        ),
                      ],
                    ],
                  ),
                  if (hasMode) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Mode: $modeName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onMode != null)
              IconButton(
                onPressed: onMode,
                icon: Icon(
                  hasMode ? Icons.tune_rounded : Icons.add_task_rounded,
                  size: 20,
                  color: hasMode
                      ? Theme.of(context).colorScheme.primary
                      : AppColors.iconSecondary(context),
                ),
                visualDensity: VisualDensity.compact,
                tooltip: hasMode ? 'Edit trigger mode' : 'Set trigger mode',
              ),
            IconButton(
              onPressed: onEdit,
              icon: Icon(
                Icons.edit_outlined,
                size: 20,
                color: AppColors.iconSecondary(context),
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
