enum OperatingMode { normal, battery, live, private, doNotTrack }

class SimInfo {
  final String label, carrier, dataLeft;
  final int signalBars;
  const SimInfo({
    required this.label,
    required this.carrier,
    required this.dataLeft,
    required this.signalBars,
  });
}

class NotificationSettings {
  final bool emergency, daily, movement, battery;
  const NotificationSettings({
    required this.emergency,
    required this.daily,
    required this.movement,
    required this.battery,
  });
  NotificationSettings copyWith({
    bool? emergency,
    bool? daily,
    bool? movement,
    bool? battery,
  }) => NotificationSettings(
    emergency: emergency ?? this.emergency,
    daily: daily ?? this.daily,
    movement: movement ?? this.movement,
    battery: battery ?? this.battery,
  );
}

class GuardianEntity {
  final String name;
  final String phoneNumber;
  final bool isPrimary;
  const GuardianEntity({
    required this.name,
    required this.phoneNumber,
    required this.isPrimary,
  });
}

class ProfileEntity {
  final String fullName;
  final String roleBadge;
  final bool isPro;
  final OperatingMode operatingMode;
  final SimInfo sim1;
  final SimInfo sim2;
  final NotificationSettings notifications;
  final List<GuardianEntity> guardians;

  const ProfileEntity({
    required this.fullName,
    required this.roleBadge,
    required this.isPro,
    required this.operatingMode,
    required this.sim1,
    required this.sim2,
    required this.notifications,
    required this.guardians,
  });

  ProfileEntity copyWith({
    String? fullName,
    List<GuardianEntity>? guardians,
    OperatingMode? operatingMode,
    SimInfo? sim1,
    SimInfo? sim2,
    NotificationSettings? notifications,
  }) => ProfileEntity(
    fullName: fullName ?? this.fullName,
    roleBadge: roleBadge,
    isPro: isPro,
    operatingMode: operatingMode ?? this.operatingMode,
    sim1: sim1 ?? this.sim1,
    sim2: sim2 ?? this.sim2,
    notifications: notifications ?? this.notifications,
    guardians: guardians ?? this.guardians,
  );
}
