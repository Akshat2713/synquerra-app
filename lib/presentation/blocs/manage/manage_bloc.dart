import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/entities/modes/mode_entity.dart';
import '../../../domain/entities/settings/settings_entity.dart';
import '../../../domain/usecases/modes/get_modes_usecase.dart';
import '../../../domain/usecases/modes/switch_mode_usecase.dart';
import '../../../domain/usecases/settings/get_settings_usecase.dart';
import '../../../domain/usecases/settings/update_phone_numbers_usecase.dart';

part 'manage_event.dart';
part 'manage_state.dart';

class ManageBloc extends Bloc<ManageEvent, ManageState> {
  final GetModesUseCase _getModesUseCase;
  final SwitchModeUseCase _switchModeUseCase;
  final GetSettingsUseCase _getSettingsUseCase;
  final UpdatePhoneNumbersUseCase _updatePhoneNumbersUseCase;

  ManageBloc({
    required GetModesUseCase getModesUseCase,
    required SwitchModeUseCase switchModeUseCase,
    required GetSettingsUseCase getSettingsUseCase,
    required UpdatePhoneNumbersUseCase updatePhoneNumbersUseCase,
  }) : _getModesUseCase = getModesUseCase,
       _switchModeUseCase = switchModeUseCase,
       _getSettingsUseCase = getSettingsUseCase,
       _updatePhoneNumbersUseCase = updatePhoneNumbersUseCase,
       super(ManageInitial()) {
    on<ManageLoadRequested>(_onLoad);
    on<ManageModeSwitchRequested>(_onModeSwitch);
    on<ManagePhoneNumbersUpdateRequested>(_onUpdatePhoneNumbers);
  }

  // ── Load Feature Data (Modes + Settings) Concurrently ───────
  Future<void> _onLoad(
    ManageLoadRequested event,
    Emitter<ManageState> emit,
  ) async {
    AppLogger.d(
      'ManageBloc',
      'Loading Manage data for device: ${event.device.id}',
    );
    emit(ManageLoading());

    // Execute both requests in parallel
    final modesFuture = _getModesUseCase();
    final settingsFuture = _getSettingsUseCase(event.device.id);

    final modesResult = await modesFuture;
    final settingsResult = await settingsFuture;

    // Evaluate Settings Result (critical for emergency numbers)
    SettingsEntity? loadedSettings;
    String? errorMessage;

    settingsResult.fold((failure) {
      AppLogger.d('ManageBloc', 'Settings fetch failed: ${failure.message}');
      errorMessage = failure.userMessage;
    }, (settings) => loadedSettings = settings);

    if (loadedSettings == null) {
      emit(ManageError(errorMessage ?? 'Failed to load device settings.'));
      return;
    }

    // Evaluate Modes Result
    final modes = modesResult.fold((failure) {
      AppLogger.d('ManageBloc', 'Modes fetch failed: ${failure.message}');
      return <ModeEntity>[];
    }, (mList) => mList);

    // Seed active mode from device entity
    String? activeModeId;
    if (modes.isNotEmpty) {
      activeModeId = modes
          .firstWhere(
            (m) =>
                m.name.toLowerCase() == event.device.currentMode.toLowerCase(),
            orElse: () => modes.first,
          )
          .id;
    }

    emit(
      ManageLoaded(
        settings: loadedSettings!,
        modes: modes,
        activeModeId: activeModeId,
      ),
    );
  }

  // ── Mode Switch Handler ──────────────────────────────────
  Future<void> _onModeSwitch(
    ManageModeSwitchRequested event,
    Emitter<ManageState> emit,
  ) async {
    if (state is! ManageLoaded) return;
    final current = state as ManageLoaded;

    AppLogger.d('ManageBloc', 'SwitchMode → ${event.modeId}');
    emit(current.copyWith(isSwitchingMode: true, modeSwitchError: null));

    final result = await _switchModeUseCase(
      deviceId: event.deviceId,
      modeId: event.modeId,
    );

    result.fold(
      (failure) {
        AppLogger.d('ManageBloc', 'SwitchMode failed: ${failure.message}');
        emit(
          current.copyWith(
            isSwitchingMode: false,
            modeSwitchError: failure.userMessage,
          ),
        );
      },
      (_) {
        AppLogger.d('ManageBloc', 'SwitchMode success');
        emit(
          current.copyWith(
            isSwitchingMode: false,
            activeModeId: event.modeId,
            modeSwitchError: null,
          ),
        );
      },
    );
  }

  // ── Phone Numbers Update Handler ─────────────────────────
  Future<void> _onUpdatePhoneNumbers(
    ManagePhoneNumbersUpdateRequested event,
    Emitter<ManageState> emit,
  ) async {
    if (state is! ManageLoaded) return;
    final current = state as ManageLoaded;

    AppLogger.d('ManageBloc', 'Updating Phone Numbers for: ${event.deviceId}');
    emit(current.copyWith(isUpdatingSettings: true, settingsUpdateError: null));

    final result = await _updatePhoneNumbersUseCase(
      deviceId: event.deviceId,
      phoneNum1: event.phoneNum1,
      phoneNum2: event.phoneNum2,
      controlRoomNum: event.controlRoomNum,
    );

    result.fold(
      (failure) {
        AppLogger.d(
          'ManageBloc',
          'Update phone numbers failed: ${failure.message}',
        );
        emit(
          current.copyWith(
            isUpdatingSettings: false,
            settingsUpdateError: failure.userMessage,
          ),
        );
      },
      (updatedSettings) {
        AppLogger.d('ManageBloc', 'Phone numbers updated successfully');
        emit(
          current.copyWith(
            settings: updatedSettings,
            isUpdatingSettings: false,
            settingsUpdateError: null,
          ),
        );
      },
    );
  }
}
