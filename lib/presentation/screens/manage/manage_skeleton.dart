import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/entities/modes/mode_entity.dart';
import '../../../domain/entities/settings/settings_entity.dart';
import '../../themes/colors.dart';
import 'widgets/manage_body.dart';

// ── Dummy Settings Entity for Skeletonizer Placeholders ──────────────────
final fakeSettingsEntity = SettingsEntity(
  phoneNum1: '9576113111',
  phoneNum2: '9576263111',
  controlRoomNum: '9576000000',
  currentProfile: 'Airtel',
  incomingCallEnabled: true,
  outgoingCallEnabled: true,
  autoModeSwitch: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// ── Dummy Mode Entities for Skeletonizer Scroll Row ──────────────────────
final fakeModes = List.generate(
  5,
  (index) => ModeEntity(
    id: 'fake_$index',
    name: 'Mode $index',
    description: 'Loading mode description...',
    normalSendingInterval: 10,
    sosSendingInterval: 4,
    normalScanningInterval: 300,
    airplaneInterval: 30,
    temperatureLimit: 50,
    speedLimit: 70,
    lowbatLimit: 20,
    categories: const ['auto'],
    note: '',
    priority: 1,
    reconfirmationTime: 60,
    airplaneMode: false,
    ambientListeningStatus: 'Off',
    ledStatus: false,
    isActive: true,
    isDefault: false,
    createdAt: "8465",
    updatedAt: "8465",
  ),
);

class ManageSkeleton extends StatelessWidget {
  final DeviceEntity device;

  const ManageSkeleton({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: AppColors.surfaceVariant(context),
        highlightColor: AppColors.surface(context),
      ),
      child: ManageBody(
        device: device,
        settings: fakeSettingsEntity,
        modes: fakeModes,
        activeModeId: 'fake_0',
        isSwitchingMode: false,
        isUpdatingSettings: false,
      ),
    );
  }
}
