import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/base_usecase.dart';
import '../../../domain/usecases/signup/clear_saved_signup_progress_usecase.dart';
import '../../../domain/usecases/signup/create_person_usecase.dart';
import '../../../domain/usecases/signup/create_credentials_usecase.dart';
import '../../../domain/usecases/signup/get_saved_signup_progress_usecase.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final CreatePersonUseCase _createPersonUseCase;
  final CreateCredentialsUseCase _createCredentialsUseCase;
  final GetSavedSignupProgressUseCase _getSavedProgressUseCase;
  final ClearSavedSignupProgressUseCase _clearSavedProgressUseCase;

  SignupBloc({
    required CreatePersonUseCase createPersonUseCase,
    required CreateCredentialsUseCase createCredentialsUseCase,
    required GetSavedSignupProgressUseCase getSavedProgressUseCase,
    required ClearSavedSignupProgressUseCase clearSavedProgressUseCase,
  }) : _createPersonUseCase = createPersonUseCase,
       _createCredentialsUseCase = createCredentialsUseCase,
       _getSavedProgressUseCase = getSavedProgressUseCase,
       _clearSavedProgressUseCase = clearSavedProgressUseCase,
       super(const SignupState()) {
    on<SignupProfileSubmitted>(_onProfileSubmitted);
    on<SignupCredentialsSubmitted>(_onCredentialsSubmitted);
    on<SignupStepBack>(_onStepBack);
    on<SignupReset>(_onReset);
    on<SignupProgressRestored>(_onProgressRestored);
  }

  // ── Step 1 ────────────────────────────────────────────────
  Future<void> _onProfileSubmitted(
    SignupProfileSubmitted event,
    Emitter<SignupState> emit,
  ) async {
    emit(state.copyWith(status: SignupStatus.loading, errorMessage: null));
    final result = await _createPersonUseCase(
      CreatePersonParams(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        phone: event.phone,
        birthDate: event.birthDate,
        gender: event.gender,
        address: event.address,
        city: event.city,
        state: event.state,
        country: event.country,
        pincode: event.pincode,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SignupStatus.error,
          errorMessage: failure.userMessage,
        ),
      ),
      (person) => emit(
        state.copyWith(
          status: SignupStatus.stepSuccess,
          step: 2,
          personId: person.personId,
          email: person.email,
        ),
      ),
    );
  }

  // ── Step 2 (now final step) ─────────────────────────────────
  Future<void> _onCredentialsSubmitted(
    SignupCredentialsSubmitted event,
    Emitter<SignupState> emit,
  ) async {
    emit(state.copyWith(status: SignupStatus.loading, errorMessage: null));
    final result = await _createCredentialsUseCase(
      CreateCredentialsParams(
        personId: state.personId!,
        email: event.email,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SignupStatus.error,
          errorMessage: failure.userMessage,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: SignupStatus.done, // ← was stepSuccess; see question #1 below
          credentialsEmail: event.email,
        ),
      ),
    );
  }

  Future<void> _onProgressRestored(
    SignupProgressRestored event,
    Emitter<SignupState> emit,
  ) async {
    emit(state.copyWith(status: SignupStatus.loading));
    final result = await _getSavedProgressUseCase(NoParams());
    result.fold((_) => emit(state.copyWith(status: SignupStatus.idle)), (
      progress,
    ) {
      if (progress == null) {
        emit(state.copyWith(status: SignupStatus.idle));
      } else {
        emit(
          state.copyWith(
            status: SignupStatus.idle,
            step: progress.step,
            personId: progress.personId,
            email: progress.email,
          ),
        );
      }
    });
  }

  // ── Back ──────────────────────────────────────────────────
  void _onStepBack(SignupStepBack event, Emitter<SignupState> emit) {
    if (state.step > 1) {
      emit(
        state.copyWith(
          step: state.step - 1,
          status: SignupStatus.idle,
          errorMessage: null,
        ),
      );
    }
  }

  // ── Reset ─────────────────────────────────────────────────
  Future<void> _onReset(SignupReset event, Emitter<SignupState> emit) async {
    await _clearSavedProgressUseCase(NoParams());
    emit(const SignupState());
  }
}
