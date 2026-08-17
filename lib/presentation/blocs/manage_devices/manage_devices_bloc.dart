import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/relationship/relationship_entity.dart';
import '../../../domain/usecases/relationship/get_relationship_list_usecase.dart';
import '../../../domain/usecases/device_assignments/assign_device_usecase.dart';
import '../../../domain/usecases/device_assignments/unassign_device_usecase.dart';
import '../device_list/device_list_bloc.dart';

part 'manage_devices_event.dart';
part 'manage_devices_state.dart';

class ManageDevicesBloc extends Bloc<ManageDevicesEvent, ManageDevicesState> {
  final GetRelationshipListUseCase _getRelationshipListUseCase;
  final AssignDeviceUseCase _assignDeviceUseCase;
  final UnassignDeviceUseCase _unassignDeviceUseCase;
  final UserHolder _userHolder;
  final DeviceListBloc _deviceListBloc;

  ManageDevicesBloc({
    required GetRelationshipListUseCase getRelationshipListUseCase,
    required AssignDeviceUseCase assignDeviceUseCase,
    required UnassignDeviceUseCase unassignDeviceUseCase,
    required UserHolder userHolder,
    required DeviceListBloc deviceListBloc,
  }) : _getRelationshipListUseCase = getRelationshipListUseCase,
       _assignDeviceUseCase = assignDeviceUseCase,
       _unassignDeviceUseCase = unassignDeviceUseCase,
       _userHolder = userHolder,
       _deviceListBloc = deviceListBloc,
       super(const ManageDevicesInitial()) {
    on<ManageDevicesLoadRequested>(_onLoad);
    on<ManageDevicesAssignRequested>(_onAssign);
    on<ManageDevicesUnassignRequested>(_onUnassign);
  }

  Future<void> _onLoad(
    ManageDevicesLoadRequested event,
    Emitter<ManageDevicesState> emit,
  ) async {
    emit(const ManageDevicesLoading());
    final personId = _userHolder.user?.personId;
    if (personId == null) {
      emit(const ManageDevicesError('User not found. Please log in again.'));
      return;
    }
    final result = await _getRelationshipListUseCase(personId);
    result.fold(
      (failure) {
        AppLogger.d(
          'ManageDevicesBloc',
          'Relationships fetch failed: ${failure.message}',
        );
        emit(ManageDevicesError(failure.userMessage));
      },
      (relationships) {
        AppLogger.d(
          'ManageDevicesBloc',
          'Loaded ${relationships.length} relationships',
        );
        emit(ManageDevicesLoaded(relationships: relationships));
      },
    );
  }

  Future<void> _onAssign(
    ManageDevicesAssignRequested event,
    Emitter<ManageDevicesState> emit,
  ) async {
    if (state is! ManageDevicesLoaded) return;
    final current = state as ManageDevicesLoaded;
    emit(current.copyWith(processingDeviceId: event.deviceId));
    final result = await _assignDeviceUseCase(
      personId: event.personId,
      deviceId: event.deviceId,
      associationType: event.associationType,
    );
    result.fold(
      (failure) {
        AppLogger.d('ManageDevicesBloc', 'Assign failed: ${failure.message}');
        emit(
          current.copyWith(
            processingDeviceId: null,
            errorMessage: failure.userMessage,
          ),
        );
      },
      (_) {
        _deviceListBloc.add(const DeviceListRefreshRequested());
        emit(current.copyWith(processingDeviceId: null, clearError: true));
      },
    );
  }

  Future<void> _onUnassign(
    ManageDevicesUnassignRequested event,
    Emitter<ManageDevicesState> emit,
  ) async {
    if (state is! ManageDevicesLoaded) return;
    final current = state as ManageDevicesLoaded;
    emit(current.copyWith(processingDeviceId: event.deviceId));

    // Passes personId (or falls back to carrier personId if required by usecase)
    final result = await _unassignDeviceUseCase(
      deviceId: event.deviceId,
      associationType: event.associationType,
      personId: event.personId!,
    );

    result.fold(
      (failure) {
        AppLogger.d('ManageDevicesBloc', 'Unassign failed: ${failure.message}');
        emit(
          current.copyWith(
            processingDeviceId: null,
            errorMessage: failure.userMessage,
          ),
        );
      },
      (_) {
        _deviceListBloc.add(const DeviceListRefreshRequested());
        emit(current.copyWith(processingDeviceId: null, clearError: true));
      },
    );
  }
}
