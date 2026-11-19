import 'package:flutter/material.dart';

import '../../../../domain/entities/geofence/geofence_entity.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/app_icons.dart';
import '../../../widgets/app_surfaces.dart';

/// Lists cloud-synced geofences and returns the one the user picks (or null).
Future<GeofenceEntity?> showSelectCloudGeofenceDialog(
  BuildContext context, {
  required List<GeofenceEntity> cloudGeofences,
  required String slotNumber,
}) {
  return showDialog<GeofenceEntity>(
    context: context,
    builder: (_) => SelectCloudGeofenceDialog(
      cloudGeofences: cloudGeofences,
      slotNumber: slotNumber,
    ),
  );
}

class SelectCloudGeofenceDialog extends StatefulWidget {
  final List<GeofenceEntity> cloudGeofences;
  final String slotNumber;

  const SelectCloudGeofenceDialog({
    super.key,
    required this.cloudGeofences,
    required this.slotNumber,
  });

  @override
  State<SelectCloudGeofenceDialog> createState() =>
      _SelectCloudGeofenceDialogState();
}

class _SelectCloudGeofenceDialogState extends State<SelectCloudGeofenceDialog> {
  GeofenceEntity? _selected;

  @override
  Widget build(BuildContext context) {
    final items = widget.cloudGeofences;

    return AlertDialog(
      title: Text('Assign to slot ${widget.slotNumber}'),
      content: SizedBox(
        width: double.maxFinite,
        child: items.isEmpty
            ? Text(
                'No cloud geofences available to assign.',
                style: AppTextStyles.bodyWithColor(context),
              )
            : ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                      MediaQuery.sizeOf(context).height *
                      AppSize.dialogListFactor,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final g = items[i];
                    final selected = _selected?.id == g.id;

                    return Semantics(
                      button: true,
                      selected: selected,
                      child: InsetRow(
                        onTap: () => setState(() => _selected = g),
                        child: Row(
                          spacing: AppSpacing.smd,
                          children: [
                            IconTile(
                              icon: AppIcons.geofence,
                              size: AppSize.avatarSm,
                              iconSize: AppSize.iconSm,
                              circle: true,
                              background: selected
                                  ? AppColors.primary(context)
                                  : AppColors.primaryContainer(context),
                              foreground: selected
                                  ? AppColors.onPrimary(context)
                                  : AppColors.onPrimaryContainer(context),
                            ),
                            Expanded(
                              child: Text(
                                g.geofenceName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyWithColor(
                                  context,
                                  color: AppColors.textPrimary(context),
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Icon(
                              selected ? AppIcons.radioOn : AppIcons.radioOff,
                              size: AppSize.icon,
                              color: selected
                                  ? AppColors.primary(context)
                                  : AppColors.iconSecondary(context),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selected == null
              ? null
              : () => Navigator.pop(context, _selected),
          child: const Text('Assign'),
        ),
      ],
    );
  }
}
