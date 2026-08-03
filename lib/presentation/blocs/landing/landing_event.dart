part of 'landing_bloc.dart';

abstract class LandingEvent extends Equatable {
  const LandingEvent();
  @override
  List<Object?> get props => [];
}

class LandingLoadRequested extends LandingEvent {
  final DeviceEntity device;
  const LandingLoadRequested(this.device);
  @override
  List<Object?> get props => [device];
}

class LandingRefreshRequested extends LandingEvent {
  final DeviceEntity device;
  const LandingRefreshRequested(this.device);
  @override
  List<Object?> get props => [device];
}
