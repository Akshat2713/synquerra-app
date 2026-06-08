// presentation/blocs/mode/mode_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/modes/mode_entity.dart';
import '../../../domain/usecases/modes/get_modes_usecase.dart';
import '../../../domain/usecases/modes/switch_mode_usecase.dart';

part 'mode_event.dart';
part 'mode_state.dart';

class ModeBloc extends Bloc<ModeEvent, ModeState> {
  final GetModesUseCase _getModesUseCase;
  final SwitchModeUseCase _switchModeUseCase;

  ModeBloc({
    required GetModesUseCase getModesUseCase,
    required SwitchModeUseCase switchModeUseCase,
  }) : _getModesUseCase = getModesUseCase,
       _switchModeUseCase = switchModeUseCase,
       super(const ModeInitial()) {
    on<ModeLoad>(_onLoad);
    on<ModeSelect>(_onSelect);
    on<ModeSwitchSubmit>(_onSwitchSubmit);
  }

  Future<void> _onLoad(ModeLoad event, Emitter<ModeState> emit) async {
    debugPrint('[ModeBloc] Load');
    emit(const ModeLoading());
    final result = await _getModesUseCase();
    result.fold(
      (failure) {
        debugPrint('[ModeBloc] Load failed: ${failure.message}');
        emit(ModeError(failure.userMessage));
      },
      (modes) {
        debugPrint('[ModeBloc] Loaded ${modes.length} modes');
        final preselected = modes
            .where(
              (m) =>
                  m.name.toLowerCase() == event.currentModeName.toLowerCase(),
            )
            .map((m) => m.id)
            .firstOrNull;

        emit(ModeLoaded(modes: modes, selectedModeId: preselected));
      },
    );
  }

  void _onSelect(ModeSelect event, Emitter<ModeState> emit) {
    final current = state;
    if (current is! ModeLoaded) return;
    debugPrint('[ModeBloc] Selected: ${event.modeId}');
    emit(ModeLoaded(modes: current.modes, selectedModeId: event.modeId));
  }

  Future<void> _onSwitchSubmit(
    ModeSwitchSubmit event,
    Emitter<ModeState> emit,
  ) async {
    final current = state;
    if (current is! ModeLoaded) return;

    debugPrint('[ModeBloc] Switch → modeId: ${event.modeId}');
    emit(ModeSwitching(modes: current.modes, selectedModeId: event.modeId));

    final result = await _switchModeUseCase(
      imei: event.imei,
      modeId: event.modeId,
    );

    result.fold(
      (failure) {
        debugPrint('[ModeBloc] Switch failed: ${failure.message}');
        emit(
          ModeSwitchFailure(
            modes: current.modes,
            selectedModeId: event.modeId,
            message: failure.userMessage,
          ),
        );
      },
      (_) {
        debugPrint('[ModeBloc] Switch success');
        emit(
          ModeSwitchSuccess(modes: current.modes, activeModeId: event.modeId),
        );
      },
    );
  }
}
