import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../domain/entities/signup/person_entity.dart';
import '../../../../domain/usecases/base_usecase.dart';
import '../../../../domain/usecases/user/get_user_profile_usecase.dart';
import '../base/base_state.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase _getUserProfileUseCase;

  ProfileBloc({required GetUserProfileUseCase getUserProfileUseCase})
    : _getUserProfileUseCase = getUserProfileUseCase,
      super(const ProfileInitial()) {
    on<FetchUserProfile>(_onFetchUserProfile);
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
}
