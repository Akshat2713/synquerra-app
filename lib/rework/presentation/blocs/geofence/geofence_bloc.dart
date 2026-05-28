import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/geofence/geofence_entity.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/failures/failure_extentions.dart';
import '../../../domain/usecases/geofence/get_geofences_usecase.dart';

part 'geofence_event.dart';
part 'geofence_state.dart';

class GeofenceBloc extends Bloc<GeofenceEvent, GeofenceState> {
  final GetGeofencesUseCase _getGeofencesUseCase;

  GeofenceBloc({required GetGeofencesUseCase getGeofencesUseCase})
    : _getGeofencesUseCase = getGeofencesUseCase,
      super(GeofenceInitial()) {
    on<GeofenceLoad>(_onLoad);
  }

  Future<void> _onLoad(GeofenceLoad event, Emitter<GeofenceState> emit) async {
    debugPrint('[GeofenceBloc] Load → imei: ${event.imei}');
    emit(GeofenceLoading());

    final result = await _getGeofencesUseCase(event.imei);

    result.fold(
      (failure) {
        debugPrint('[GeofenceBloc] Load failed: ${failure.message}');
        emit(GeofenceError(mapFailureToMessage(failure)));
      },
      (geofences) {
        debugPrint('[GeofenceBloc] Loaded ${geofences.length} geofences');
        emit(GeofenceLoaded(geofences));
      },
    );
  }
}
