import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/signup/signup_usecase.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final SignUpUseCase _signUpUseCase;

  SignupBloc({required SignUpUseCase signUpUseCase})
    : _signUpUseCase = signUpUseCase,
      super(const SignupState()) {
    on<SignupSubmitted>(_onSubmitted);
    on<SignupReset>(_onReset);
  }

  Future<void> _onSubmitted(
    SignupSubmitted event,
    Emitter<SignupState> emit,
  ) async {
    emit(state.copyWith(status: SignupStatus.loading, errorMessage: null));
    final result = await _signUpUseCase(
      SignUpParams(
        firstName: event.firstName,
        email: event.email,
        password: event.password,
        lastName: event.lastName,
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
      (person) =>
          emit(state.copyWith(status: SignupStatus.done, personId: person.id)),
    );
  }

  void _onReset(SignupReset event, Emitter<SignupState> emit) {
    emit(const SignupState());
  }
}
