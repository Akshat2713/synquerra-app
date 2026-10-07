import 'package:equatable/equatable.dart';

class SettingsEntity extends Equatable {
  final String? topic;
  final String? imei;
  final int? normalSendingInterval;
  final int? sosSendingInterval;
  final int? normalScanningInterval;
  final int? airplaneInterval;
  final double? temperatureLimit;
  final double? speedLimit;
  final int? lowbatLimit;
  final String? phoneNum1;
  final String? phoneNum2;
  final String? controlRoomNum;
  final String? currentProfile;
  final bool incomingCallEnabled;
  final bool outgoingCallEnabled;
  final String? ambientListeningStatus;
  final bool autoModeSwitch;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SettingsEntity({
    this.topic,
    this.imei,
    this.normalSendingInterval,
    this.sosSendingInterval,
    this.normalScanningInterval,
    this.airplaneInterval,
    this.temperatureLimit,
    this.speedLimit,
    this.lowbatLimit,
    this.phoneNum1,
    this.phoneNum2,
    this.controlRoomNum,
    this.currentProfile,
    this.incomingCallEnabled = false,
    this.outgoingCallEnabled = false,
    this.ambientListeningStatus,
    this.autoModeSwitch = false,
    this.createdAt,
    this.updatedAt,
  });

  static const Object _unset = Object();

  SettingsEntity copyWith({
    String? topic,
    String? imei,
    int? normalSendingInterval,
    int? sosSendingInterval,
    int? normalScanningInterval,
    int? airplaneInterval,
    double? temperatureLimit,
    double? speedLimit,
    int? lowbatLimit,
    Object? phoneNum1 = _unset, // String? or null; omit to keep current
    Object? phoneNum2 = _unset, // String? or null; omit to keep current
    String? controlRoomNum,
    String? currentProfile,
    bool? incomingCallEnabled,
    bool? outgoingCallEnabled,
    String? ambientListeningStatus,
    bool? autoModeSwitch,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SettingsEntity(
      topic: topic ?? this.topic,
      imei: imei ?? this.imei,
      normalSendingInterval:
          normalSendingInterval ?? this.normalSendingInterval,
      sosSendingInterval: sosSendingInterval ?? this.sosSendingInterval,
      normalScanningInterval:
          normalScanningInterval ?? this.normalScanningInterval,
      airplaneInterval: airplaneInterval ?? this.airplaneInterval,
      temperatureLimit: temperatureLimit ?? this.temperatureLimit,
      speedLimit: speedLimit ?? this.speedLimit,
      lowbatLimit: lowbatLimit ?? this.lowbatLimit,
      phoneNum1: identical(phoneNum1, _unset)
          ? this.phoneNum1
          : phoneNum1 as String?,
      phoneNum2: identical(phoneNum2, _unset)
          ? this.phoneNum2
          : phoneNum2 as String?,
      controlRoomNum: controlRoomNum ?? this.controlRoomNum,
      currentProfile: currentProfile ?? this.currentProfile,
      incomingCallEnabled: incomingCallEnabled ?? this.incomingCallEnabled,
      outgoingCallEnabled: outgoingCallEnabled ?? this.outgoingCallEnabled,
      ambientListeningStatus:
          ambientListeningStatus ?? this.ambientListeningStatus,
      autoModeSwitch: autoModeSwitch ?? this.autoModeSwitch,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    topic,
    imei,
    normalSendingInterval,
    sosSendingInterval,
    normalScanningInterval,
    airplaneInterval,
    temperatureLimit,
    speedLimit,
    lowbatLimit,
    phoneNum1,
    phoneNum2,
    controlRoomNum,
    currentProfile,
    incomingCallEnabled,
    outgoingCallEnabled,
    ambientListeningStatus,
    autoModeSwitch,
    createdAt,
    updatedAt,
  ];
}
