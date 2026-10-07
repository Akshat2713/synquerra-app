import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/entities/modes/mode_entity.dart';
import '../../../domain/entities/settings/settings_entity.dart';
import '../../../domain/usecases/modes/get_modes_usecase.dart';
import '../../../domain/usecases/modes/switch_mode_usecase.dart';
import '../../../domain/usecases/modes/toggle_auto_mode_switch_usecase.dart';
import '../../../domain/usecases/settings/get_settings_usecase.dart';
import '../../../domain/usecases/settings/update_phone_numbers_usecase.dart';
import '../base/base_state.dart';

part 'manage_event.dart';
part 'manage_state.dart';

class ManageBloc extends Bloc<ManageEvent, ManageState> {
  final GetModesUseCase _getModesUseCase;
  final SwitchModeUseCase _switchModeUseCase;
  final GetSettingsUseCase _getSettingsUseCase;
  final ToggleAutoModeSwitchUseCase _toggleAutoModeSwitchUseCase;
  final UpdatePhoneNumbersUseCase _updatePhoneNumbersUseCase;

  ManageBloc({
    required GetModesUseCase getModesUseCase,
    required SwitchModeUseCase switchModeUseCase,
    required GetSettingsUseCase getSettingsUseCase,
    required ToggleAutoModeSwitchUseCase toggleAutoModeSwitchUseCase,
    required UpdatePhoneNumbersUseCase updatePhoneNumbersUseCase,
  }) : _getModesUseCase = getModesUseCase,
       _switchModeUseCase = switchModeUseCase,
       _getSettingsUseCase = getSettingsUseCase,
       _toggleAutoModeSwitchUseCase = toggleAutoModeSwitchUseCase,
       _updatePhoneNumbersUseCase = updatePhoneNumbersUseCase,
       super(ManageInitial()) {
    on<ManageLoadRequested>(_onLoad);
    on<ManageModeSwitchRequested>(_onModeSwitch);
    on<ManageAutoModeToggleRequested>(_onAutoModeToggle);
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

  Future<void> _onAutoModeToggle(
    ManageAutoModeToggleRequested event,
    Emitter<ManageState> emit,
  ) async {
    if (state is! ManageLoaded) return;
    final current = state as ManageLoaded;

    emit(current.copyWith(isSwitchingMode: true, modeSwitchError: null));

    final result = await _toggleAutoModeSwitchUseCase(deviceId: event.deviceId);

    if (emit.isDone || isClosed) return;
    final latest = state;
    if (latest is! ManageLoaded) return;

    result.fold(
      (failure) => emit(
        latest.copyWith(
          isSwitchingMode: false,
          modeSwitchError: failure.userMessage,
        ),
      ),
      (_) => emit(
        latest.copyWith(
          isSwitchingMode: false,
          settings: latest.settings.copyWith(
            autoModeSwitch: !latest.settings.autoModeSwitch,
          ),
        ),
      ),
    );
  }

  Future<void> _onUpdatePhoneNumbers(
    ManagePhoneNumbersUpdateRequested event,
    Emitter<ManageState> emit,
  ) async {
    if (state is! ManageLoaded) return;
    final current = state as ManageLoaded;

    // Empty input keeps the existing number
    final phone1 = _resolveNumber(event.phoneNum1, current.settings.phoneNum1);
    final phone2 = _resolveNumber(event.phoneNum2, current.settings.phoneNum2);

    emit(current.copyWith(isUpdatingSettings: true));

    final result = await _updatePhoneNumbersUseCase(
      deviceId: event.deviceId,
      phoneNum1: phone1,
      phoneNum2: phone2,
    );

    if (emit.isDone || isClosed) return;

    // Re-read state in case something changed during the API call
    final latest = state;
    if (latest is! ManageLoaded) return;

    result.fold(
      (failure) {
        AppLogger.d('ManageBloc', 'Update failed: ${failure.message}');
        emit(
          latest.copyWith(
            isUpdatingSettings: false,
            settingsUpdateError: failure.userMessage,
          ),
        );
      },
      (_) {
        // Ignore the returned entity and use the values we sent
        emit(
          latest.copyWith(
            settings: latest.settings.copyWith(
              phoneNum1: phone1.isEmpty ? null : phone1,
              phoneNum2: phone2.isEmpty ? null : phone2,
            ),
            isUpdatingSettings: false,
          ),
        );
      },
    );
  }

  String _resolveNumber(String? input, String? existing) {
    final v = input?.trim() ?? '';
    if (v.isNotEmpty) return v;
    final e = existing ?? '';
    return (e == 'No Primary Number' || e == 'No Secondary Number') ? '' : e;
  }
}
