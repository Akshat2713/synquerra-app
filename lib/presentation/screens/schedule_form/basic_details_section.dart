import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import 'package:synquerra/presentation/widgets/app_text_field.dart';

import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/entities/geofence/geofence_entity.dart';
import 'section_card.dart';
import 'section_header.dart';

class BasicDetailsSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descController;

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
  Widget build(BuildContext context) {
    final inputTextStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary(context),
    );

    // Guard against a stale selected id no longer present in a fresh list
    // (e.g. device unassigned elsewhere while this form was open).
    final deviceValue = devices.any((d) => d.id == selectedDeviceId)
        ? selectedDeviceId
        : null;
    final geofenceValue = geofences.any((g) => g.id == selectedGeofenceId)
        ? selectedGeofenceId
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Basic Details'),
        SectionCard(
          children: [
            AppTextField(
              controller: titleController,
              label: 'Schedule Title',
              prefixIcon: Icons.title_rounded,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: descController,
              label: 'Description',
              prefixIcon: Icons.description_rounded,
            ),
            const SizedBox(height: 12),
            // Only "Myself" exists for now; kept as a dropdown so wiring in
            // more target users later is a one-line change (items list only).
            DropdownButtonFormField<String>(
              initialValue: 'self',
              style: inputTextStyle,
              dropdownColor: AppColors.surface(context),
              decoration: InputDecoration(
                labelText: 'Assigned To',
                prefixIcon: Icon(
                  Icons.person_outline_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: 'self',
                  child: Text(
                    'Myself ($currentUserFullName)',
                    style: inputTextStyle,
                  ),
                ),
              ],
              onChanged: null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: deviceValue,
              style: inputTextStyle,
              dropdownColor: AppColors.surface(context),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary(context),
              ),
              decoration: InputDecoration(
                labelText: 'Target Device',
                prefixIcon: Icon(
                  Icons.devices_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              items: devices.map((device) {
                return DropdownMenuItem<String?>(
                  value: device.id,
                  child: Text(
                    '${device.serialNo} · ${device.displayOwnerName(currentUserFullName)}',
                    style: inputTextStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onDeviceChanged,
              validator: (val) => val == null ? 'Please select a device' : null,
            ),
            const SizedBox(height: 12),
            if (geofenceLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (selectedDeviceId == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Select a device to load its geofence zones',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              )
            else if (geofenceError != null)
              Text(
                geofenceError!,
                style: TextStyle(fontSize: 12, color: AppColors.danger),
              )
            else if (geofences.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'No geofence zones found for this device',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              )
            else
              DropdownButtonFormField<String>(
                initialValue: geofenceValue,
                style: inputTextStyle,
                dropdownColor: AppColors.surface(context),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary(context),
                ),
                decoration: InputDecoration(
                  labelText: 'Target Geofence Zone',
                  prefixIcon: Icon(
                    Icons.shield_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                items: geofences.map((zone) {
                  return DropdownMenuItem<String>(
                    value: zone.id,
                    child: Text(zone.geofenceName, style: inputTextStyle),
                  );
                }).toList(),
                onChanged: onGeofenceChanged,
                validator: (val) =>
                    val == null ? 'Please select a geofence zone' : null,
              ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedPriority,
              style: inputTextStyle,
              dropdownColor: AppColors.surface(context),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary(context),
              ),
              decoration: InputDecoration(
                labelText: 'Priority',
                prefixIcon: Icon(
                  Icons.flag_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              items: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'].map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text(p, style: inputTextStyle),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onPriorityChanged(val);
              },
            ),
          ],
        ),
      ],
    );
  }
}
