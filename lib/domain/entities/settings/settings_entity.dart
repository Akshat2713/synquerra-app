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
