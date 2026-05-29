import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/geofence/geofence_entity.dart';
import '../../../domain/failures/failure_extentions.dart';
import '../../../domain/usecases/geofence/create_geofence_usecase.dart';
import '../../../domain/usecases/geofence/delete_geofence_usecase.dart';
import '../../../domain/usecases/geofence/get_geofences_usecase.dart';

part 'geofence_event.dart';
part 'geofence_state.dart';

class GeofenceBloc extends Bloc<GeofenceEvent, GeofenceState> {
  final GetGeofencesUseCase _getGeofencesUseCase;
  final CreateGeofenceUseCase _createGeofenceUseCase;
  final DeleteGeofenceUseCase _deleteGeofenceUseCase;

  GeofenceBloc({
    required GetGeofencesUseCase getGeofencesUseCase,
    required CreateGeofenceUseCase createGeofenceUseCase,
    required DeleteGeofenceUseCase deleteGeofenceUseCase,
  }) : _getGeofencesUseCase = getGeofencesUseCase,
       _createGeofenceUseCase = createGeofenceUseCase,
       _deleteGeofenceUseCase = deleteGeofenceUseCase,
       super(GeofenceInitial()) {
    on<GeofenceLoad>(_onLoad);
    on<GeofenceCreate>(_onCreate);
    on<GeofenceDelete>(_onDelete);
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

  Future<void> _onCreate(
    GeofenceCreate event,
    Emitter<GeofenceState> emit,
  ) async {
    debugPrint('[GeofenceBloc] Create → imei: ${event.imei}');
    emit(const GeofenceOperationLoading());
    final result = await _createGeofenceUseCase(
      imei: event.imei,
      name: event.name,
      isActive: event.isActive,
      coordinates: event.coordinates,
    );
    result.fold(
      (failure) => emit(GeofenceOperationError(mapFailureToMessage(failure))),
      (geofence) {
        debugPrint('[GeofenceBloc] Created: ${geofence.geofenceName}');
        emit(GeofenceCreated(geofence));
        // Refresh the list so map updates
        add(GeofenceLoad(event.imei));
      },
    );
  }

  Future<void> _onDelete(
    GeofenceDelete event,
    Emitter<GeofenceState> emit,
  ) async {
    debugPrint('[GeofenceBloc] Delete → geofenceId: ${event.geofenceId}');
    emit(const GeofenceOperationLoading());
    final result = await _deleteGeofenceUseCase(
      imei: event.imei,
      geofenceId: event.geofenceId,
    );
    result.fold(
      (failure) => emit(GeofenceOperationError(mapFailureToMessage(failure))),
      (_) {
        debugPrint('[GeofenceBloc] Deleted: ${event.geofenceId}');
        emit(const GeofenceDeleted());
        // Refresh the list so map updates
        add(GeofenceLoad(event.imei));
      },
    );
  }
}
