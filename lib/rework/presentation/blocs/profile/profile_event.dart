// lib/presentation/blocs/profile/profile_event.dart

part of 'profile_bloc.dart';

enum NotificationType { emergency, daily, movement, battery }

abstract class ProfileEvent {
  const ProfileEvent();
}

class ProfileLoadRequested extends ProfileEvent {
  final String imei;
  const ProfileLoadRequested(this.imei);
}

class ProfileModeChanged extends ProfileEvent {
  final OperatingMode mode;
  const ProfileModeChanged(this.mode);
}

class ProfileNotificationToggled extends ProfileEvent {
  final NotificationType type;
  final bool value;
  const ProfileNotificationToggled(this.type, this.value);
}

class ProfileSimSwitchRequested extends ProfileEvent {
  const ProfileSimSwitchRequested();
}
