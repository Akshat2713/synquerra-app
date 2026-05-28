// lib/presentation/blocs/profile/profile_bloc.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/analytics/analytics_entity.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/entities/profile/profile_entity.dart';
import '../../../presentation/screens/profile/profile_skeleton.dart';

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
      // final result = await _getProfileUseCase(event.device.imei);
      // await Future.delayed(const Duration(milliseconds: 800));
      final phone1 = event.analytics!.phone1;

      debugPrint('Using phone1: $phone1');

      final phone2 = event.analytics!.phone2;
      // final mock = ProfileEntity(
      //   fullName: event.device.studentName, // ← pull from real device
      //   roleBadge: 'Guardian',
      //   isPro: true,
      //   operatingMode: OperatingMode.normal,
      //   sim1: const SimInfo(
      //     label: 'S1 · Active',
      //     carrier: 'Airtel 4G',
      //     dataLeft: '2.4 GB left',
      //     signalBars: 4,
      //   ),
      //   sim2: const SimInfo(
      //     label: 'S2 · Switch',
      //     carrier: 'Jio 5G',
      //     dataLeft: '8.1 GB left',
      //     signalBars: 3,
      //   ),
      //   notifications: const NotificationSettings(
      //     emergency: true,
      //     daily: true,
      //     movement: false,
      //     battery: true,
      //   ),
      //   guardians: [
      //     GuardianEntity(
      //       name: 'Meera Sharma',
      //       phoneNumber: phone1!,
      //       isPrimary: true,
      //     ),
      //     GuardianEntity(
      //       name: 'Raj Sharma',
      //       phoneNumber: phone2!,
      //       isPrimary: false,
      //     ),
      //   ],
      // );

      final mock = fakeProfileEntity.copyWith(
        fullName: event.device.studentName,
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
    final n = current.notifications;
    emit(
      ProfileLoaded(
        current.copyWith(
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
    final current = (state as ProfileLoaded).profile;

    // Swap the SIMs
    emit(
      ProfileLoaded(current.copyWith(sim1: current.sim2, sim2: current.sim1)),
    );
    // TODO: sl<SwitchSimUseCase>().call()
  }
}
