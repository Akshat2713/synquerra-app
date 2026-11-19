import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../domain/entities/geofence/geofence_entity.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/app_icons.dart';
import '../../../utils/colour_util.dart';
import '../../../widgets/app_surfaces.dart';

class GeofenceListTile extends StatelessWidget {
  final GeofenceEntity geofence;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Opens the "Configure trigger mode" dialog. Mode row is hidden when null
  /// and no mode is attached.
  final VoidCallback? onMode;

  /// Unassigns the geofence from its device slot. Cross icon is hidden when null.
  final VoidCallback? onUnassign;

  /// Name of the mode already attached to this geofence, if any.
  final String? modeName;

  const GeofenceListTile({
    super.key,
    required this.geofence,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onMode,
    this.onUnassign,
    this.modeName,
  });

  @override
  Widget build(BuildContext context) {
    final hasMode = modeName != null;
    final synced = geofence.isSyncToDevice;
    final tileColor = colorFromHex(geofence.geofenceColor);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        borderRadius: AppRadius.lgAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Padding(
            padding: AppSpacing.mdAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  spacing: AppSpacing.smd,
                  children: [
                    IconTile(
                      icon: AppIcons.geofence,
                      size: AppSize.avatarSm,
                      iconSize: AppSize.iconSm,
                      background: tileColor,
                      foreground: onGeofenceColor(tileColor),
                    ),
                    Expanded(
                      child: Text(
                        geofence.geofenceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.sectionWithColor(context),
                      ),
                    ),
                    IconButton(
                      onPressed: onEdit,
                      tooltip: 'Edit',
                      visualDensity: VisualDensity.compact,
                      padding: AppSpacing.xsAll,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        AppIcons.edit,
                        size: AppSize.icon,
                        color: AppColors.primary(context),
                      ),
                    ),
                    if (!synced)
                      IconButton(
                        onPressed: onDelete,
                        tooltip: 'Delete',
                        visualDensity: VisualDensity.compact,
                        padding: AppSpacing.xsAll,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          AppIcons.delete,
                          size: AppSize.icon,
                          color: AppColors.danger,
                        ),
                      ),
                    if (onUnassign != null)
                      IconButton(
                        onPressed: onUnassign,
                        tooltip: 'Unassign from device',
                        visualDensity: VisualDensity.compact,
                        padding: AppSpacing.xsAll,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          AppIcons.close,
                          size: AppSize.icon,
                          color: AppColors.iconSecondary(context),
                        ),
                      ),
                  ],
                ),
                if (onMode != null || hasMode) ...[
                  const SizedBox(height: AppSpacing.sm),
                  InsetRow(
                    onTap: onMode,
                    child: Row(
                      spacing: AppSpacing.sm,
                      children: [
                        Expanded(
                          child: Text(
                            hasMode ? 'Mode: $modeName' : 'No trigger mode',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyWithColor(
                              context,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                        if (onMode != null)
                          Icon(
                            AppIcons.chevron,
                            size: AppSize.icon,
                            color: AppColors.primary(context),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
