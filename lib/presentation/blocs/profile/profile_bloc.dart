import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../domain/entities/signup/person_entity.dart';
import '../../../../domain/usecases/base_usecase.dart';
import '../../../../domain/usecases/user/get_user_profile_usecase.dart';
import '../../../../domain/usecases/user/update_user_profile_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;

  ProfileBloc({
    required GetUserProfileUseCase getUserProfileUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
  }) : _getUserProfileUseCase = getUserProfileUseCase,
       _updateUserProfileUseCase = updateUserProfileUseCase,
       super(const ProfileInitial()) {
    on<FetchUserProfile>(_onFetchUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
  }

  Future<void> _onFetchUserProfile(
    FetchUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    AppLogger.d('ProfileBloc', 'FetchUserProfile called');
    emit(const ProfileLoading());

    final result = await _getUserProfileUseCase(NoParams());

    result.fold(
      (failure) {
        AppLogger.d('ProfileBloc', 'Fetch failed: ${failure.userMessage}');
        emit(ProfileError(failure.userMessage));
      },
      (user) {
        AppLogger.d(
          'ProfileBloc',
          'Fetched: ${user.firstName} ${user.lastName}',
        );
        emit(ProfileLoaded(user));
      },
    );
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    // Updating only makes sense once a profile is already loaded (the
    // update screen is pre-filled from it). Bail out defensively otherwise
    // instead of emitting a confusing state.
    if (current is! ProfileLoaded) {
      AppLogger.d(
        'ProfileBloc',
        'UpdateUserProfile ignored: no profile loaded yet',
      );
      return;
    }

    AppLogger.d('ProfileBloc', 'UpdateUserProfile called');
    emit(current.copyWith(isUpdating: true, clearError: true));

    final result = await _updateUserProfileUseCase(
      UpdateUserProfileParams(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        password: event.password,
        relationshipType: event.relationshipType,
        isHead: event.isHead,
        middleName: event.middleName,
        mobile: event.mobile,
        birthDate: event.birthDate,
        gender: event.gender,
        address: event.address,
        city: event.city,
        state: event.state,
        country: event.country,
        pincode: event.pincode,
        profileImage: event.profileImage,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.d('ProfileBloc', 'Update failed: ${failure.userMessage}');
        emit(
          current.copyWith(
            isUpdating: false,
            errorMessage: failure.userMessage,
          ),
        );
      },
      (updatedUser) {
        AppLogger.d(
          'ProfileBloc',
          'Updated: ${updatedUser.firstName} ${updatedUser.lastName}',
        );
        emit(ProfileLoaded(updatedUser));
      },
    );
  }
}
