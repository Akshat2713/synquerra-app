import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/settings/settings_entity.dart';
import '../../../domain/usecases/settings/get_settings_usecase.dart';
import '../../../domain/usecases/settings/update_phone_numbers_usecase.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettingsUseCase _getSettingsUseCase;
  final UpdatePhoneNumbersUseCase _updatePhoneNumbersUseCase;

  SettingsBloc({
    required GetSettingsUseCase getSettingsUseCase,
    required UpdatePhoneNumbersUseCase updatePhoneNumbersUseCase,
  }) : _getSettingsUseCase = getSettingsUseCase,
       _updatePhoneNumbersUseCase = updatePhoneNumbersUseCase,
       super(SettingsInitial()) {
    on<SettingsLoadRequested>(_onLoadRequested);
    on<SettingsUpdatePhoneNumbersRequested>(_onUpdatePhoneNumbers);
  }

  Future<void> _onLoadRequested(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) async {
    AppLogger.d('SettingsBloc', 'LoadRequested → deviceId: ${event.deviceId}');
    emit(SettingsLoading());

    final result = await _getSettingsUseCase(event.deviceId);

    result.fold(
      (failure) {
        AppLogger.d('SettingsBloc', 'Fetch failed: ${failure.message}');
        emit(SettingsError(failure.userMessage));
      },
      (settings) {
        AppLogger.d('SettingsBloc', 'Settings loaded successfully');
        emit(SettingsLoaded(settings: settings));
      },
    );
  }

  Future<void> _onUpdatePhoneNumbers(
    SettingsUpdatePhoneNumbersRequested event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is! SettingsLoaded) return;
    final currentState = state as SettingsLoaded;

    AppLogger.d(
      'SettingsBloc',
      'Updating phone numbers for deviceId: ${event.deviceId}',
    );
    emit(currentState.copyWith(isUpdating: true, updateError: null));

    final result = await _updatePhoneNumbersUseCase(
      deviceId: event.deviceId,
      phoneNum1: event.phoneNum1,
      phoneNum2: event.phoneNum2,
    );

    result.fold(
      (failure) {
        AppLogger.d('SettingsBloc', 'Update failed: ${failure.message}');
        emit(
          currentState.copyWith(
            isUpdating: false,
            updateError: failure.userMessage,
          ),
        );
      },
      (updatedSettings) {
        AppLogger.d('SettingsBloc', 'Phone numbers updated successfully');
        emit(SettingsLoaded(settings: updatedSettings));
      },
    );
  }
}
