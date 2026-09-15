part of 'profile_bloc.dart';

abstract class ProfileState extends BaseState {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState with LoadingState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final PersonEntity user;

  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileError extends ProfileState with ErrorState {
  @override
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
