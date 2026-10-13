import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import '../../../../domain/entities/geofence/geofence_entity.dart';
import '../../../../domain/entities/geofence/geofence_slot.dart';
import 'geofence_list_tile.dart';

/// Fixed 3-slot "Synced to device" section.
/// Empty slot -> plus tile. Filled slot -> regular geofence tile.
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
    final used = slots.where((s) => !s.isEmpty).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Text(
            'Synced to device ($used/${GeofenceSlot.totalSlots})',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
        for (final slot in slots)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: slot.isEmpty
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
          ),
        const SizedBox(height: 6),
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
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          border: Border.all(color: AppColors.outlineVariant(context)),
          borderRadius: AppRadius.mdAll,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 28, color: scheme.primary),
            const SizedBox(height: 2),
            Text(
              'Slot ${slot.index}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
