import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/analytics/analytics_entity.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/entities/modes/mode_entity.dart';
import '../../../domain/entities/profile/profile_entity.dart';
import '../../../domain/usecases/modes/get_modes_usecase.dart';
import '../../../domain/usecases/modes/switch_mode_usecase.dart';
import '../../screens/profile/profile_skeleton.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetModesUseCase _getModesUseCase;
  final SwitchModeUseCase _switchModeUseCase;

  ProfileBloc({
    required GetModesUseCase getModesUseCase,
    required SwitchModeUseCase switchModeUseCase,
  }) : _getModesUseCase = getModesUseCase,
       _switchModeUseCase = switchModeUseCase,
       super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileModeSwitchRequested>(_onModeSwitch);
    on<ProfileNotificationToggled>(_onNotificationToggled);
    on<ProfileSimSwitchRequested>(_onSimSwitch);
  }

  Future<void> _onLoad(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final phone1 = event.analytics!.phone1;
      final phone2 = event.analytics!.phone2;

      // Fetch modes in parallel — failure just gives empty list, not a crash
      final modesResult = await _getModesUseCase();
      final modes = modesResult.fold((_) => <ModeEntity>[], (m) => m);

      final profile = fakeProfileEntity.copyWith(
        fullName: event.device.serialNo,
        guardians: [
          GuardianEntity(
            name: 'Meera Sharma',
            phoneNumber: phone1!,
            isPrimary: true,
          ),
          GuardianEntity(
            name: 'Raj Sharma',
            phoneNumber: phone2!,
            isPrimary: false,
          ),
        ],
      );

      emit(
        ProfileLoaded(
          profile: profile,
          modes: modes,
          activeModeId: modes
              .firstWhere(
                (m) =>
                    m.name.toLowerCase() ==
                    event.device.currentMode.toLowerCase(),
                orElse: () => modes.first,
              )
              .id, // seed from device
        ),
      );
    } catch (e) {
      debugPrint('[ProfileBloc] Load error: $e');
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onModeSwitch(
    ProfileModeSwitchRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;
    final current = state as ProfileLoaded;

    debugPrint('[ProfileBloc] SwitchMode → ${event.modeId}');
    emit(current.copyWith(isSwitchingMode: true, modeSwitchError: null));

    final result = await _switchModeUseCase(
      imei: event.imei,
      modeId: event.modeId,
    );

    result.fold(
      (failure) {
        debugPrint('[ProfileBloc] SwitchMode failed: ${failure.message}');
        emit(
          current.copyWith(
            isSwitchingMode: false,
            modeSwitchError: failure.userMessage,
          ),
        );
      },
      (_) {
        debugPrint('[ProfileBloc] SwitchMode success');
        emit(
          current.copyWith(
            isSwitchingMode: false,
            activeModeId: event.modeId,
            modeSwitchError: null, // sentinel clears it
          ),
        );
      },
    );
  }

  void _onNotificationToggled(
    ProfileNotificationToggled event,
    Emitter<ProfileState> emit,
  ) {
    if (state is! ProfileLoaded) return;
    final current = (state as ProfileLoaded).profile;
    final n = current.notifications;
    emit(
      (state as ProfileLoaded).copyWith(
        profile: current.copyWith(
          notifications: n.copyWith(
            emergency: event.type == NotificationType.emergency
                ? event.value
                : null,
            daily: event.type == NotificationType.daily ? event.value : null,
            movement: event.type == NotificationType.movement
                ? event.value
                : null,
            battery: event.type == NotificationType.battery
                ? event.value
                : null,
          ),
        ),
      ),
    );
  }

  void _onSimSwitch(
    ProfileSimSwitchRequested event,
    Emitter<ProfileState> emit,
  ) {
    if (state is! ProfileLoaded) return;
    final current = (state as ProfileLoaded);
    emit(
      current.copyWith(
        profile: current.profile.copyWith(
          sim1: current.profile.sim2,
          sim2: current.profile.sim1,
        ),
      ),
    );
  }
}
