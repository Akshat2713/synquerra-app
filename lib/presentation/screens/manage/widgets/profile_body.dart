import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../../../domain/entities/modes/mode_entity.dart';
import '../../../../domain/entities/profile/profile_entity.dart';
import '../../../blocs/manage/manage_bloc.dart';
import 'guardians_section.dart';
import 'mode_picker_row.dart';

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

    return Column(
      // Strictly align header content to the top-left
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header Title & Subtitle ─────────────────────────────
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

        // ── Main Content Body ───────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              TrackingModeCard(
                modes: modes,
                activeModeId: activeModeId,
                isSwitching: isSwitchingMode,
                onChanged: (modeId) => bloc.add(
                  ProfileModeSwitchRequested(
                    deviceId: device.id,
                    modeId: modeId,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              EmergencyContactsSection(guardians: profile.guardians),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
