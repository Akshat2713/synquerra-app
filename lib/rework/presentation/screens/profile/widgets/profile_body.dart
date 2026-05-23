// lib/presentation/pages/profile/widgets/profile_body.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../../../domain/entities/profile/profile_entity.dart';
import '../../../blocs/profile/profile_bloc.dart';
import 'profile_header.dart';
import 'section_label.dart';
import 'operating_mode_row.dart';
import 'network_card.dart';
import 'battery_section.dart';
import 'notifications_section.dart';
import 'guardians_section.dart';

class ProfileBody extends StatelessWidget {
  final ProfileEntity profile;
  final VoidCallback onSignOut;
  final DeviceEntity device; // DeviceEntity

  const ProfileBody({
    super.key,
    required this.profile,
    required this.onSignOut,
    required this.device,
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
        OperatingModeRow(
          selected: profile.operatingMode,
          onChanged: (mode) => bloc.add(ProfileModeChanged(mode)),
        ),
        const SizedBox(height: 20),
        const SectionLabel(text: 'NETWORK · DUAL ESIM'),
        const SizedBox(height: 8),
        NetworkCard(
          sim1Label: profile.sim1Label,
          sim1Carrier: profile.sim1Carrier,
          sim1DataLeft: profile.sim1DataLeft,
          sim1SignalBars: profile.sim1SignalBars,
          sim2Label: profile.sim2Label,
          sim2Carrier: profile.sim2Carrier,
          sim2DataLeft: profile.sim2DataLeft,
          sim2SignalBars: profile.sim2SignalBars,
          onSwitchSim: () => bloc.add(const ProfileSimSwitchRequested()),
        ),
        const SizedBox(height: 20),
        const SectionLabel(text: 'BATTERY'),
        const SizedBox(height: 8),
        BatterySection(
          percent: int.parse(device.battery!), // Use battery from DeviceEntity
          chargeByTime: profile.batteryChargeByTime,
          statusText: profile.batteryStatus,
        ),
        const SizedBox(height: 20),
        const SectionLabel(text: 'NOTIFICATIONS'),
        const SizedBox(height: 8),
        NotificationsSection(
          emergency: profile.notifyEmergency,
          daily: profile.notifyDaily,
          movement: profile.notifyMovement,
          battery: profile.notifyBattery,
          onChanged: (type, value) =>
              bloc.add(ProfileNotificationToggled(type, value)),
        ),
        const SizedBox(height: 20),
        const SectionLabel(text: 'GUARDIANS'),
        const SizedBox(height: 8),
        GuardiansSection(guardians: profile.guardians, onSignOut: onSignOut),
        const SizedBox(height: 32),
      ],
    );
  }
}
