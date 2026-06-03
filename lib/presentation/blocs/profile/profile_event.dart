// lib/presentation/blocs/profile/profile_event.dart

part of 'profile_bloc.dart';

enum NotificationType { emergency, daily, movement, battery }

abstract class ProfileEvent {
  const ProfileEvent();
}

class ProfileLoadRequested extends ProfileEvent {
  final DeviceEntity device;
  final AnalyticsEntity? analytics; // ← new field
  const ProfileLoadRequested(this.device, this.analytics);
}

class ProfileModeChanged extends ProfileEvent {
  final OperatingMode mode;
  const ProfileModeChanged(this.mode);
}

class ProfileModeSwitchRequested extends ProfileEvent {
  final String imei;
  final String modeId;
  const ProfileModeSwitchRequested({required this.imei, required this.modeId});
}

class ProfileNotificationToggled extends ProfileEvent {
  final NotificationType type;
  final bool value;
  const ProfileNotificationToggled(this.type, this.value);
}

class ProfileSimSwitchRequested extends ProfileEvent {
  const ProfileSimSwitchRequested();
}
