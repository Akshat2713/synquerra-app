// lib/presentation/screens/profile/profile_skeleton.dart

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/entities/profile/profile_entity.dart';
import 'widgets/profile_body.dart';

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
      name: 'Meera Sharma',
      phoneNumber: '9876543210',
      isPrimary: true,
    ),
    GuardianEntity(
      name: 'Raj Sharma',
      phoneNumber: '9876543211',
      isPrimary: false,
    ),
  ],
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
        modes: const [], // skeleton — no real modes yet
        activeModeId: null, // nothing selected
        isSwitchingMode: false, // not switching
      ),
    );
  }
}
