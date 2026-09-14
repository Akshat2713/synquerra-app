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

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is double) return value.toInt();
      return null;
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return SettingsModel(
      topic: json['topic'] as String?,
      imei: json['imei'] as String?,
      normalSendingInterval: parseInt(json['normal_sending_interval']),
      sosSendingInterval: parseInt(json['sos_sending_interval']),
      normalScanningInterval: parseInt(json['normal_scanning_interval']),
      airplaneInterval: parseInt(json['airplane_interval']),
      temperatureLimit: parseDouble(json['temperature_limit']),
      speedLimit: parseDouble(json['speed_limit']),
      lowbatLimit: parseInt(json['lowbat_limit']),
      phoneNum1: json['phone_num1']?.toString(),
      phoneNum2: json['phone_num2']?.toString(),
      controlRoomNum: json['control_room_num']?.toString(),
      currentProfile: json['current_profile'] as String?,
      incomingCallEnabled: json['incoming_call_enabled'] as bool?,
      outgoingCallEnabled: json['outgoing_call_enabled'] as bool?,
      ambientListeningStatus: json['ambient_listening_status'] as String?,
      autoModeSwitch: json['auto_mode_switch'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

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
