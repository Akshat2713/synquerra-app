// lib/presentation/blocs/landing/landing_state.dart

part of 'landing_bloc.dart';

abstract class LandingState extends BaseState {
  const LandingState();
}

class LandingInitial extends LandingState {
  const LandingInitial();
}

class LandingLoading extends LandingState with LoadingState {
  const LandingLoading();
}

class LandingLoaded extends LandingState {
  final AnalyticsEntity? latest;
  final List<AlertEntity> alerts;

  const LandingLoaded({this.latest, required this.alerts});

  @override
  List<Object?> get props => [latest, alerts];
}

class LandingError extends LandingState with ErrorState {
  @override
  final String message;

  const LandingError(this.message);

  @override
  List<Object?> get props => [message];
}
