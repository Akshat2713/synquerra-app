// presentation/blocs/sos/sos_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/sos_alarm_service.dart';
import '../../../domain/usecases/sos/acknowledge_sos_usecase.dart';
import '../../../domain/usecases/sos/stop_sos_usecase.dart';
import '../../../core/utils/app_logger.dart';
import '../base/base_state.dart';

part 'sos_event.dart';
part 'sos_state.dart';

class SosBloc extends Bloc<SosEvent, SosState> {
  final AcknowledgeSosUseCase _acknowledgeSosUseCase;
  final StopSosUseCase _stopSosUseCase;
  final SosAlarmService _sosAlarmService;

  SosBloc({
    required AcknowledgeSosUseCase acknowledgeSosUseCase,
    required StopSosUseCase stopSosUseCase,
    required SosAlarmService sosAlarmService,
  }) : _acknowledgeSosUseCase = acknowledgeSosUseCase,
       _stopSosUseCase = stopSosUseCase,
       _sosAlarmService = sosAlarmService,
       super(const SosInitial()) {
    on<SosAcknowledgeSubmit>(_onAcknowledgeSubmit);
    on<SosStopSubmit>(_onStopSubmit);
    on<SosReset>(_onReset);
    on<SosClear>(_onClear);
  }

  Future<void> _onAcknowledgeSubmit(
    SosAcknowledgeSubmit event,
    Emitter<SosState> emit,
  ) async {
    if (state is SosProcessing) return;

    final active = state.activeDeviceId;
    AppLogger.d('SosBloc', 'Acknowledge → alertId: ${event.alertId}');
    emit(SosProcessing(action: SosAction.acknowledge, activeDeviceId: active));

    final result = await _acknowledgeSosUseCase(alertId: event.alertId);

    result.fold(
      (failure) {
        AppLogger.d('SosBloc', 'Acknowledge failed: ${failure.message}');
        emit(
          SosFailure(
            action: SosAction.acknowledge,
            message: failure.userMessage,
            activeDeviceId: active,
          ),
        );
      },
      (_) {
        AppLogger.d('SosBloc', 'Acknowledge success');
        _sosAlarmService.stop();
        emit(
          SosSuccess(
            action: SosAction.acknowledge,
            activeDeviceId: event.deviceId,
          ),
        );
      },
    );
  }

  Future<void> _onStopSubmit(
    SosStopSubmit event,
    Emitter<SosState> emit,
  ) async {
    if (state is SosProcessing) return;

    AppLogger.d('SosBloc', 'Stop → deviceId: ${event.deviceId}');
    emit(SosProcessing(action: SosAction.stop, activeDeviceId: event.deviceId));

    final result = await _stopSosUseCase(deviceId: event.deviceId);

    result.fold(
      (failure) {
        AppLogger.d('SosBloc', 'Stop failed: ${failure.message}');
        emit(
          SosFailure(
            action: SosAction.stop,
            message: failure.userMessage,
            activeDeviceId: event.deviceId,
          ),
        );
      },
      (_) {
        AppLogger.d('SosBloc', 'Stop success');
        _sosAlarmService.stop();
        emit(const SosSuccess(action: SosAction.stop));
      },
    );
  }

  void _onReset(SosReset event, Emitter<SosState> emit) {
    emit(SosInitial(activeDeviceId: state.activeDeviceId));
  }

  void _onClear(SosClear event, Emitter<SosState> emit) {
    _sosAlarmService.stop();
    emit(const SosInitial());
  }
}
