part of 'landing_bloc.dart';

abstract class LandingEvent extends Equatable {
  const LandingEvent();

  @override
  List<Object?> get props => [];
}

class LandingLoadRequested extends LandingEvent {
  const LandingLoadRequested();
}

class LandingRefreshRequested extends LandingEvent {
  const LandingRefreshRequested();
}

class LandingMemberSelected extends LandingEvent {
  final String memberId;
  const LandingMemberSelected(this.memberId);

  @override
  List<Object?> get props => [memberId];
}
