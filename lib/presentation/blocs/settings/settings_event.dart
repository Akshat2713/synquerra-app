part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsLoadRequested extends SettingsEvent {
  final String deviceId;

  const SettingsLoadRequested(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class SettingsUpdatePhoneNumbersRequested extends SettingsEvent {
  final String deviceId;
  final String? phoneNum1;
  final String? phoneNum2;
  final String? controlRoomNum;

  const SettingsUpdatePhoneNumbersRequested({
    required this.deviceId,
    this.phoneNum1,
    this.phoneNum2,
    this.controlRoomNum,
  });

  @override
  List<Object?> get props => [deviceId, phoneNum1, phoneNum2, controlRoomNum];
}
