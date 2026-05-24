// lib/domain/entities/profile/profile_entity.dart

enum OperatingMode { normal, battery, live, private, doNotTrack }

class GuardianEntity {
  final String name;
  final bool isPrimary;
  const GuardianEntity({required this.name, required this.isPrimary});
}

class ProfileEntity {
  final String fullName;
  final String roleBadge;
  final bool isPro;
  final OperatingMode operatingMode;

  // SIM
  final String sim1Label;
  final String sim1Carrier;
  final String sim1DataLeft;
  final int sim1SignalBars;
  final String sim2Label;
  final String sim2Carrier;
  final String sim2DataLeft;
  final int sim2SignalBars;

  // Battery
  final int batteryPercent;
  final String batteryChargeByTime;
  final String batteryStatus;

  // Notifications
  final bool notifyEmergency;
  final bool notifyDaily;
  final bool notifyMovement;
  final bool notifyBattery;

  final List<GuardianEntity> guardians;

  const ProfileEntity({
    required this.fullName,
    required this.roleBadge,
    required this.isPro,
    required this.operatingMode,
    required this.sim1Label,
    required this.sim1Carrier,
    required this.sim1DataLeft,
    required this.sim1SignalBars,
    required this.sim2Label,
    required this.sim2Carrier,
    required this.sim2DataLeft,
    required this.sim2SignalBars,
    required this.batteryPercent,
    required this.batteryChargeByTime,
    required this.batteryStatus,
    required this.notifyEmergency,
    required this.notifyDaily,
    required this.notifyMovement,
    required this.notifyBattery,
    required this.guardians,
  });

  ProfileEntity copyWith({
    OperatingMode? operatingMode,
    bool? notifyEmergency,
    bool? notifyDaily,
    bool? notifyMovement,
    bool? notifyBattery,
  }) {
    return ProfileEntity(
      fullName: fullName,
      roleBadge: roleBadge,
      isPro: isPro,
      operatingMode: operatingMode ?? this.operatingMode,
      sim1Label: sim1Label,
      sim1Carrier: sim1Carrier,
      sim1DataLeft: sim1DataLeft,
      sim1SignalBars: sim1SignalBars,
      sim2Label: sim2Label,
      sim2Carrier: sim2Carrier,
      sim2DataLeft: sim2DataLeft,
      sim2SignalBars: sim2SignalBars,
      batteryPercent: batteryPercent,
      batteryChargeByTime: batteryChargeByTime,
      batteryStatus: batteryStatus,
      notifyEmergency: notifyEmergency ?? this.notifyEmergency,
      notifyDaily: notifyDaily ?? this.notifyDaily,
      notifyMovement: notifyMovement ?? this.notifyMovement,
      notifyBattery: notifyBattery ?? this.notifyBattery,
      guardians: guardians,
    );
  }
}
