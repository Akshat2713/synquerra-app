part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final PersonEntity user;

  /// True while a save-profile request is in flight, so the Update screen
  /// can show a spinner without losing the currently-displayed data.
  final bool isUpdating;

  /// Set when an update attempt fails; the profile data itself is kept so
  /// the form stays filled in and the user can just retry.
  final String? errorMessage;

  const ProfileLoaded(this.user, {this.isUpdating = false, this.errorMessage});

  ProfileLoaded copyWith({
    PersonEntity? user,
    bool? isUpdating,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileLoaded(
      user ?? this.user,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [user, isUpdating, errorMessage];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
