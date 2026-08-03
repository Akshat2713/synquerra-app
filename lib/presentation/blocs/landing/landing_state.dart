part of 'landing_bloc.dart';

abstract class LandingState extends Equatable {
  const LandingState();
  @override
  List<Object?> get props => [];
}

class LandingInitial extends LandingState {
  const LandingInitial();
}

class LandingLoading extends LandingState {
  const LandingLoading();
}

class LandingLoaded extends LandingState {
  final AnalyticsEntity? latest;
  final List<AlertEntity> alerts;
  const LandingLoaded({required this.latest, required this.alerts});
  @override
  List<Object?> get props => [latest, alerts];
}

class LandingError extends LandingState {
  final String message;
  const LandingError(this.message);
  @override
  List<Object?> get props => [message];
}
