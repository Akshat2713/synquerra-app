import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import '../../../../domain/entities/geofence/geofence_entity.dart';

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
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final items = widget.cloudGeofences;

    return AlertDialog(
      title: Text('Assign to slot ${widget.slotNumber}'),
      content: SizedBox(
        width: double.maxFinite,
        child: items.isEmpty
            ? Text(
                'No cloud geofences available to assign.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              )
            : ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (_, i) {
                    final g = items[i];
                    final selected = _selected?.id == g.id;

                    return InkWell(
                      borderRadius: AppRadius.mdAll,
                      onTap: () => setState(() => _selected = g),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface(context),
                          borderRadius: AppRadius.mdAll,
                          border: Border.all(
                            color: selected
                                ? scheme.primary
                                : AppColors.outlineVariant(context),
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                g.geofenceName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              selected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              size: 20,
                              color: selected
                                  ? scheme.primary
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
          child: const Text('OK'),
        ),
      ],
    );
  }
}
