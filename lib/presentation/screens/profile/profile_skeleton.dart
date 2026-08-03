import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/entities/modes/mode_entity.dart';
import '../../../domain/entities/profile/profile_entity.dart';
import 'widgets/profile_body.dart';

// ── Dummy Profile Entity for Skeletonizer Placeholders ───────────────────
const fakeProfileEntity = ProfileEntity(
  fullName: 'Meera Sharma',
  roleBadge: 'Guardian',
  isPro: true,
  operatingMode: OperatingMode.normal,
  sim1: SimInfo(
    label: 'S1 · Active',
    carrier: 'Airtel 4G',
    dataLeft: '2.4 GB left',
    signalBars: 4,
  ),
  sim2: SimInfo(
    label: 'S2 · Switch',
    carrier: 'Jio 5G',
    dataLeft: '8.1 GB left',
    signalBars: 3,
  ),
  notifications: NotificationSettings(
    emergency: true,
    daily: true,
    movement: false,
    battery: true,
  ),
  guardians: [
    GuardianEntity(
      name: 'Primary Contact',
      phoneNumber: '9934303749',
      isPrimary: true,
    ),
    GuardianEntity(
      name: 'Secondary Contact',
      phoneNumber: '9835960843',
      isPrimary: false,
    ),
  ],
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

class ProfileSkeleton extends StatelessWidget {
  final DeviceEntity device;
  const ProfileSkeleton({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        highlightColor: Theme.of(context).colorScheme.surface,
      ),
      child: ProfileBody(
        profile: fakeProfileEntity,
        device: device,
        modes: fakeModes, // Passes fake modes so Skeletonizer draws mode chips
        activeModeId: 'fake_0',
        isSwitchingMode: false,
      ),
    );
  }
}
