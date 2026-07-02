import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/usecases/link_device/link_device_usecase.dart';

part 'link_device_event.dart';
part 'link_device_state.dart';

class LinkDeviceBloc extends Bloc<LinkDeviceEvent, LinkDeviceState> {
  final LinkDeviceUseCase _linkDeviceUseCase;

  LinkDeviceBloc({required LinkDeviceUseCase linkDeviceUseCase})
    : _linkDeviceUseCase = linkDeviceUseCase,
      super(const LinkDeviceState()) {
    on<LinkDeviceSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    LinkDeviceSubmitted event,
    Emitter<LinkDeviceState> emit,
  ) async {
    final personId = sl<UserHolder>().user?.personId;
    if (personId == null) {
      emit(
        state.copyWith(
          status: LinkDeviceStatus.error,
          errorMessage: 'User not found. Please log in again.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: LinkDeviceStatus.loading, errorMessage: null));

    final result = await _linkDeviceUseCase(
      LinkDeviceParams(
        ownerId: personId,
        ownerType: event.ownerType,
        deviceSerialNo: event.deviceSerialNo,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: LinkDeviceStatus.error,
          errorMessage: failure.userMessage,
        ),
      ),
      (_) => emit(state.copyWith(status: LinkDeviceStatus.success)),
    );
  }
}
