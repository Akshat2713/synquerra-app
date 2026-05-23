// lib/presentation/blocs/profile/profile_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/profile/profile_entity.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileModeChanged>(_onModeChanged);
    on<ProfileNotificationToggled>(_onNotificationToggled);
    on<ProfileSimSwitchRequested>(_onSimSwitch);
  }

  Future<void> _onLoad(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      // TODO: replace with real use-case call
      // final profile = await sl<GetProfileUseCase>().call(event.imei);
      await Future.delayed(const Duration(milliseconds: 800)); // simulate fetch
      const mock = ProfileEntity(
        fullName: 'Meera Sharma',
        roleBadge: 'Guardian',
        isPro: true,
        operatingMode: OperatingMode.normal,
        sim1Label: 'S1 · Active',
        sim1Carrier: 'Airtel 4G',
        sim1DataLeft: '2.4 GB left',
        sim1SignalBars: 4,
        sim2Label: 'S2 · Switch',
        sim2Carrier: 'Jio 5G',
        sim2DataLeft: '8.1 GB left',
        sim2SignalBars: 3,
        batteryPercent: 78,
        batteryChargeByTime: 'Charge before 4:00 am',
        batteryStatus: 'Discharging ~14 hrs remaining',
        notifyEmergency: true,
        notifyDaily: true,
        notifyMovement: false,
        notifyBattery: true,
        guardians: [
          GuardianEntity(name: 'Meera Sharma', isPrimary: true),
          GuardianEntity(name: 'Raj Sharma', isPrimary: false),
        ],
      );
      emit(ProfileLoaded(mock));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  void _onModeChanged(ProfileModeChanged event, Emitter<ProfileState> emit) {
    if (state is! ProfileLoaded) return;
    final current = (state as ProfileLoaded).profile;
    emit(ProfileLoaded(current.copyWith(operatingMode: event.mode)));
    // TODO: sl<UpdateOperatingModeUseCase>().call(event.mode)
  }

  void _onNotificationToggled(
    ProfileNotificationToggled event,
    Emitter<ProfileState> emit,
  ) {
    if (state is! ProfileLoaded) return;
    final current = (state as ProfileLoaded).profile;
    emit(
      ProfileLoaded(
        current.copyWith(
          notifyEmergency: event.type == NotificationType.emergency
              ? event.value
              : null,
          notifyDaily: event.type == NotificationType.daily
              ? event.value
              : null,
          notifyMovement: event.type == NotificationType.movement
              ? event.value
              : null,
          notifyBattery: event.type == NotificationType.battery
              ? event.value
              : null,
        ),
      ),
    );
    // TODO: sl<UpdateNotificationSettingsUseCase>().call(...)
  }

  void _onSimSwitch(
    ProfileSimSwitchRequested event,
    Emitter<ProfileState> emit,
  ) {
    // TODO: sl<SwitchSimUseCase>().call()
  }
}
