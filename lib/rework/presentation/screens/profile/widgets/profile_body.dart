// lib/presentation/pages/profile/widgets/profile_body.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../../../domain/entities/modes/mode_entity.dart';
import '../../../../domain/entities/profile/profile_entity.dart';
import '../../../blocs/profile/profile_bloc.dart';
import 'mode_picker_row.dart';
import 'profile_header.dart';
import 'section_label.dart';
import 'network_card.dart';
import 'battery_section.dart';
import 'notifications_section.dart';
import 'guardians_section.dart';

class ProfileBody extends StatelessWidget {
  final ProfileEntity profile;
  final DeviceEntity device;
  final List<ModeEntity> modes;
  final String? activeModeId;
  final bool isSwitchingMode;

  const ProfileBody({
    super.key,
    required this.profile,
    required this.device,
    required this.modes,
    required this.activeModeId,
    required this.isSwitchingMode,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProfileBloc>();
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        ProfileHeader(
          fullName: profile.fullName,
          roleBadge: profile.roleBadge,
          isPro: profile.isPro,
        ),
        const SizedBox(height: 20),
        const SectionLabel(text: 'OPERATING MODE'),
        const SizedBox(height: 8),

        // ← replaces OperatingModeRow
        ModePickerRow(
          modes: modes,
          activeModeId: activeModeId,
          isSwitching: isSwitchingMode,
          onChanged: (modeId) => bloc.add(
            ProfileModeSwitchRequested(imei: device.imei, modeId: modeId),
          ),
        ),

        const SizedBox(height: 20),
        const SectionLabel(text: 'NETWORK · DUAL ESIM'),
        const SizedBox(height: 8),
        NetworkCard(
          sim1: profile.sim1,
          sim2: profile.sim2,
          onSwitchSim: () => bloc.add(const ProfileSimSwitchRequested()),
        ),
        const SizedBox(height: 20),
        const SectionLabel(text: 'BATTERY'),
        const SizedBox(height: 8),
        BatterySection(
          percent: device.battery ?? 0,
          chargeByTime: 'Charge before 4:00 am',
          statusText: 'Discharging',
        ),
        const SizedBox(height: 20),
        const SectionLabel(text: 'NOTIFICATIONS'),
        const SizedBox(height: 8),
        NotificationsSection(
          emergency: profile.notifications.emergency,
          daily: profile.notifications.daily,
          movement: profile.notifications.movement,
          battery: profile.notifications.battery,
          onChanged: (type, value) =>
              bloc.add(ProfileNotificationToggled(type, value)),
        ),
        const SizedBox(height: 20),
        const SectionLabel(text: 'GUARDIANS'),
        const SizedBox(height: 8),
        GuardiansSection(guardians: profile.guardians),
        const SizedBox(height: 32),
      ],
    );
  }
}
