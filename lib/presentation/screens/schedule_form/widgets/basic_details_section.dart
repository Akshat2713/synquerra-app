import 'package:flutter/material.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../widgets/app_text_field.dart';

import '../../../../domain/entities/device/device_entity.dart';
import '../../../../domain/entities/geofence/geofence_entity.dart';
import '../../../themes/app_text_styles.dart';
import '../../../utils/app_icons.dart';
import '../../../widgets/app_dropdown_field.dart';
import '../../../widgets/app_surfaces.dart';
import 'section_header.dart';

class BasicDetailsSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descController;

  // Retained for compatibility with the parent screen while the dropdowns
  // are temporarily hidden.
  final List<DeviceEntity> devices;
  final String currentUserFullName;
  final String? selectedDeviceId;
  final ValueChanged<String?> onDeviceChanged;

  final List<GeofenceEntity> geofences;
  final bool geofenceLoading;
  final String? geofenceError;
  final String? selectedGeofenceId;
  final ValueChanged<String?> onGeofenceChanged;

  final String selectedPriority;
  final ValueChanged<String> onPriorityChanged;

  const BasicDetailsSection({
    super.key,
    required this.titleController,
    required this.descController,
    required this.devices,
    required this.currentUserFullName,
    required this.selectedDeviceId,
    required this.onDeviceChanged,
    required this.geofences,
    required this.geofenceLoading,
    required this.geofenceError,
    required this.selectedGeofenceId,
    required this.onGeofenceChanged,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  @override
  Widget build(BuildContext context) {
    final motion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.base;

    final geofenceReady =
        !geofenceLoading &&
        selectedDeviceId != null &&
        geofenceError == null &&
        geofences.isNotEmpty;

    Widget geofenceDropdown() => AppDropdownField<String>(
      label: 'Geofence Zone',
      value: selectedGeofenceId,
      items: [for (final z in geofences) z.id],
      itemLabel: (id) => geofences.firstWhere((z) => z.id == id).geofenceName,
      onChanged: onGeofenceChanged,
      validator: (v) => v == null ? 'Please select a geofence zone' : null,
    );

    Widget priorityDropdown() => AppDropdownField<String>(
      label: 'Priority',
      value: selectedPriority,
      // TODO(logic): priority values belong in an enum/constants.
      items: const ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'],
      itemLabel: (p) => p,
      onChanged: (v) {
        if (v != null) onPriorityChanged(v);
      },
    );

    Widget geofenceStatus() {
      if (geofenceLoading) {
        return const Center(
          key: ValueKey('geofence-loading'),
          child: SizedBox(
            width: AppSize.icon,
            height: AppSize.icon,
            child: CircularProgressIndicator(strokeWidth: AppSize.stroke),
          ),
        );
      }
      if (selectedDeviceId == null) {
        return const _StatusRow(
          key: ValueKey('geofence-no-device'),
          message: 'Select a device first',
        );
      }
      if (geofenceError != null) {
        return _StatusRow(
          key: const ValueKey('geofence-error'),
          message: geofenceError!,
          icon: AppIcons.error,
          color: AppColors.danger,
        );
      }
      return const _StatusRow(
        key: ValueKey('geofence-empty'),
        message: 'No zones available',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Basic Details'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.md,
            children: [
              AppTextField(
                controller: titleController,
                label: 'Schedule Title',
                prefixIcon: AppIcons.title,
              ),
              AppTextField(
                controller: descController,
                label: 'Description',
                prefixIcon: AppIcons.description,
              ),
              // Assigned To / Target Device dropdowns removed. Re-add with
              // AppDropdownField (AppIcons.person / AppIcons.devices) when
              // assignment is supported. Old code is in git history.
              if (geofenceReady)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.smd,
                  children: [
                    Expanded(child: geofenceDropdown()),
                    Expanded(child: priorityDropdown()),
                  ],
                )
              else ...[
                AnimatedSwitcher(
                  duration: motion,
                  switchInCurve: AppMotion.curve,
                  switchOutCurve: AppMotion.curve,
                  child: geofenceStatus(),
                ),
                priorityDropdown(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? color;

  const _StatusRow({
    super.key,
    required this.message,
    this.icon = AppIcons.info,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InsetRow(
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          Icon(icon, size: AppSize.iconSm, color: color ?? AppColors.offline),
          Expanded(
            child: Text(message, style: AppTextStyles.metaWithColor(context)),
          ),
        ],
      ),
    );
  }
}
