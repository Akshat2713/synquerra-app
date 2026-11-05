import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../domain/entities/geofence/geofence_entity.dart';
import '../../../../domain/entities/geofence/geofence_slot.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/app_icons.dart';
import '../../../widgets/app_surfaces.dart';
import 'geofence_list_tile.dart';

/// Fixed 3-slot "Synced to device" section.
/// Empty slot -> assign tile. Filled slot -> regular geofence tile.
class DeviceGeofenceSlots extends StatelessWidget {
  final List<GeofenceSlot> slots;
  final String? Function(GeofenceEntity) modeNameFor;
  final void Function(GeofenceSlot slot) onAddToSlot;
  final void Function(GeofenceEntity) onTap;
  final void Function(GeofenceEntity) onEdit;
  final void Function(GeofenceEntity) onDelete;
  final void Function(GeofenceEntity) onMode;
  final void Function(GeofenceSlot slot) onUnassign;

  const DeviceGeofenceSlots({
    super.key,
    required this.slots,
    required this.modeNameFor,
    required this.onAddToSlot,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onMode,
    required this.onUnassign,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.smd,
      children: [
        for (final slot in slots)
          slot.isEmpty
              ? _EmptySlotTile(slot: slot, onTap: () => onAddToSlot(slot))
              : GeofenceListTile(
                  geofence: slot.geofence!,
                  modeName: modeNameFor(slot.geofence!),
                  onTap: () => onTap(slot.geofence!),
                  onEdit: () => onEdit(slot.geofence!),
                  onDelete: () => onDelete(slot.geofence!),
                  onMode: () => onMode(slot.geofence!),
                  onUnassign: () => onUnassign(slot),
                ),
      ],
    );
  }
}

class _EmptySlotTile extends StatelessWidget {
  final GeofenceSlot slot;
  final VoidCallback onTap;

  const _EmptySlotTile({required this.slot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      // tint: AppColors.primarySubtle(context),
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
            child: Row(
              spacing: AppSpacing.smd,
              children: [
                IconTile(
                  icon: AppIcons.add,
                  circle: true,
                  background: AppColors.primary(context),
                  foreground: AppColors.onPrimary(context),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Slot ${slot.index}',
                        style: AppTextStyles.sectionWithColor(context),
                      ),
                      Text(
                        'Tap to assign a geofence',
                        style: AppTextStyles.metaWithColor(context),
                      ),
                    ],
                  ),
                ),
                Icon(
                  AppIcons.chevron,
                  size: AppSize.icon,
                  color: AppColors.primary(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
