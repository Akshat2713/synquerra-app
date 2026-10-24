import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/device/device_entity.dart';
import '../../../blocs/manage/manage_bloc.dart';
import '../../../themes/app_tokens.dart';
import '../../../widgets/app_motion_widgets.dart';
import 'emergency_contacts_section.dart';
import 'mode_picker_row.dart';

class ManageBody extends StatelessWidget {
  final DeviceEntity device;
  final ManageLoaded state;

  const ManageBody({super.key, required this.device, required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ManageBloc>();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: AppSpacing.mdAll,
      children: [
        ModePickerRow(
          modes: state.modes,
          activeModeId: state.activeModeId,
          isSwitching: state.isSwitchingMode,
          autoModeSwitch: state.settings.autoModeSwitch,
          onAutoModeToggle: () =>
              bloc.add(ManageAutoModeToggleRequested(device.id)),
          onChanged: (modeId) => bloc.add(
            ManageModeSwitchRequested(deviceId: device.id, modeId: modeId),
          ),
        ).entrance(context),
        const SizedBox(height: AppSpacing.lg),
        EmergencyContactsSection(
          deviceId: device.id,
          settings: state.settings,
          isUpdating: state.isUpdatingSettings,
          onSaveContacts: (p1, p2) => bloc.add(
            ManagePhoneNumbersUpdateRequested(
              deviceId: device.id,
              phoneNum1: p1,
              phoneNum2: p2,
            ),
          ),
        ).entrance(context, index: 1),
      ],
    );
  }
}
