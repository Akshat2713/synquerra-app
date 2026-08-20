// lib/presentation/screens/manage/widgets/manage_body.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/device/device_entity.dart';
import '../../../../domain/entities/modes/mode_entity.dart';
import '../../../../domain/entities/settings/settings_entity.dart';
import '../../../blocs/manage/manage_bloc.dart';
import 'emergency_contacts_section.dart';
import 'mode_picker_row.dart';

class ManageBody extends StatelessWidget {
  final DeviceEntity device;
  final SettingsEntity settings;
  final List<ModeEntity> modes;
  final String? activeModeId;
  final bool isSwitchingMode;
  final bool isUpdatingSettings;

  const ManageBody({
    super.key,
    required this.device,
    required this.settings,
    required this.modes,
    required this.activeModeId,
    required this.isSwitchingMode,
    required this.isUpdatingSettings,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ManageBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manage',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                'Mode & SOS contacts for this tracker',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              TrackingModeCard(
                modes: modes,
                activeModeId: activeModeId,
                isSwitching: isSwitchingMode,
                autoModeSwitch: settings.autoModeSwitch,
                onChanged: (modeId) => bloc.add(
                  ManageModeSwitchRequested(
                    deviceId: device.id,
                    modeId: modeId,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              EmergencyContactsSection(
                deviceId: device.id,
                settings: settings,
                isUpdating: isUpdatingSettings,
                onSaveContacts: (phoneNum1, phoneNum2) => bloc.add(
                  ManagePhoneNumbersUpdateRequested(
                    deviceId: device.id,
                    phoneNum1: phoneNum1,
                    phoneNum2: phoneNum2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
