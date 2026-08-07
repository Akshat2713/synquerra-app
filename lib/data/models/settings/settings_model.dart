import '../../../domain/entities/settings/settings_entity.dart';

class SettingsModel {
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
  final bool? incomingCallEnabled;
  final bool? outgoingCallEnabled;
  final String? ambientListeningStatus;
  final bool? autoModeSwitch;
  final String? createdAt;
  final String? updatedAt;

  const SettingsModel({
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
    this.incomingCallEnabled,
    this.outgoingCallEnabled,
    this.ambientListeningStatus,
    this.autoModeSwitch,
    this.createdAt,
    this.updatedAt,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
    topic: json['topic'] as String?,
    imei: json['imei'] as String?,
    normalSendingInterval: json['normal_sending_interval'] as int?,
    sosSendingInterval: json['sos_sending_interval'] as int?,
    normalScanningInterval: json['normal_scanning_interval'] as int?,
    airplaneInterval: json['airplane_interval'] as int?,
    temperatureLimit: (json['temperature_limit'] as num?)?.toDouble(),
    speedLimit: (json['speed_limit'] as num?)?.toDouble(),
    lowbatLimit: json['lowbat_limit'] as int?,
    phoneNum1: json['phone_num1'] as String?,
    phoneNum2: json['phone_num2'] as String?,
    controlRoomNum: json['control_room_num'] as String?,
    currentProfile: json['current_profile'] as String?,
    incomingCallEnabled: json['incoming_call_enabled'] as bool?,
    outgoingCallEnabled: json['outgoing_call_enabled'] as bool?,
    ambientListeningStatus: json['ambient_listening_status'] as String?,
    autoModeSwitch: json['auto_mode_switch'] as bool?,
    createdAt: json['created_at'] as String?,
    updatedAt: json['updated_at'] as String?,
  );

  SettingsEntity toEntity() => SettingsEntity(
    topic: topic,
    imei: imei,
    normalSendingInterval: normalSendingInterval,
    sosSendingInterval: sosSendingInterval,
    normalScanningInterval: normalScanningInterval,
    airplaneInterval: airplaneInterval,
    temperatureLimit: temperatureLimit,
    speedLimit: speedLimit,
    lowbatLimit: lowbatLimit,
    phoneNum1: (phoneNum1 == null || phoneNum1!.isEmpty)
        ? 'No Primary Number'
        : phoneNum1,
    phoneNum2: (phoneNum2 == null || phoneNum2!.isEmpty)
        ? 'No Secondary Number'
        : phoneNum2,
    controlRoomNum: controlRoomNum,
    currentProfile: currentProfile,
    incomingCallEnabled: incomingCallEnabled ?? false,
    outgoingCallEnabled: outgoingCallEnabled ?? false,
    ambientListeningStatus: ambientListeningStatus,
    autoModeSwitch: autoModeSwitch ?? false,
    createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
  );
}
