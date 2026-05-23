// lib/presentation/pages/profile/profile_skeleton.dart

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/entities/profile/profile_entity.dart';
import 'widgets/profile_body.dart'; // ← public widget, no show/_Private needed

const _fakeProfile = ProfileEntity(
  fullName: 'Meera Sharma',
  roleBadge: 'Guardian',
  isPro: true,
  operatingMode: OperatingMode.normal,
  sim1Label: 'S1 · Active',
  sim1Carrier: 'Airtel 4G',
  sim1DataLeft: '2.4 GB left',
  sim1SignalBars: 4,
  sim2Label: 'S2 · Switch',
  sim2Carrier: 'Jio 5G',
  sim2DataLeft: '8.1 GB left',
  sim2SignalBars: 3,
  batteryPercent: 78,
  batteryChargeByTime: 'Charge before 4:00 am',
  batteryStatus: 'Discharging ~14 hrs remaining',
  notifyEmergency: true,
  notifyDaily: true,
  notifyMovement: false,
  notifyBattery: true,
  guardians: [
    GuardianEntity(name: 'Meera Sharma', isPrimary: true),
    GuardianEntity(name: 'Raj Sharma', isPrimary: false),
  ],
);
const _fakeDevice = DeviceEntity(
  topic: '862942074957887/pub',
  imei: '862942074957887',
  interval: 30,
  geoid: 'School Zone',
  packet: 'N',
  latitude: '28.613939',
  longitude: '77.209021',
  speed: '12.5',
  temperature: '36.5',
  currentMode: 'Normal',
  ledStatus: 'On',
  timestamp: '2026-05-23T11:30:00Z',
  battery: '78',
  signal: '85',
  gpsStrength: 'Strong',
  studentName: 'Aarav Sharma',
  studentId: 'STU-2024-089',
  isActive: true,
  isSubscribed: true,
  createdAt: '2025-08-15T09:00:00Z',
  updatedAt: '2026-05-23T11:35:00Z',
);

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        highlightColor: Theme.of(context).colorScheme.surface,
      ),
      child: ProfileBody(
        profile: _fakeProfile,
        onSignOut: () {},
        device: _fakeDevice,
      ),
    );
  }
}
