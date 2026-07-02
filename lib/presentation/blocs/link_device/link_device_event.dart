part of 'link_device_bloc.dart';

abstract class LinkDeviceEvent extends Equatable {
  const LinkDeviceEvent();
  @override
  List<Object?> get props => [];
}

class LinkDeviceSubmitted extends LinkDeviceEvent {
  final String ownerType;
  final String deviceSerialNo;
  const LinkDeviceSubmitted({
    required this.ownerType,
    required this.deviceSerialNo,
  });
  @override
  List<Object?> get props => [ownerType, deviceSerialNo];
}
