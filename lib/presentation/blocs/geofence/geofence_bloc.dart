import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/geofence/geofence_entity.dart';
import '../../../domain/usecases/geofence/create_geofence_usecase.dart';
import '../../../domain/usecases/geofence/edit_geofence_usecase.dart';
import '../../../domain/usecases/geofence/delete_geofence_usecase.dart';
import '../../../domain/usecases/geofence/get_geofences_usecase.dart';
import '../../../core/utils/app_logger.dart';

part 'geofence_event.dart';
part 'geofence_state.dart';

class GeofenceBloc extends Bloc<GeofenceEvent, GeofenceState> {
  final GetGeofencesUseCase _getGeofencesUseCase;
  final CreateGeofenceUseCase _createGeofenceUseCase;
  final EditGeofenceUseCase _editGeofenceUseCase;
  final DeleteGeofenceUseCase _deleteGeofenceUseCase;

  GeofenceBloc({
    required GetGeofencesUseCase getGeofencesUseCase,
    required CreateGeofenceUseCase createGeofenceUseCase,
    required EditGeofenceUseCase editGeofenceUseCase,
    required DeleteGeofenceUseCase deleteGeofenceUseCase,
  }) : _getGeofencesUseCase = getGeofencesUseCase,
       _createGeofenceUseCase = createGeofenceUseCase,
       _editGeofenceUseCase = editGeofenceUseCase,
       _deleteGeofenceUseCase = deleteGeofenceUseCase,
       super(const GeofenceInitial()) {
    on<GeofenceLoad>(_onLoad);
    on<GeofenceCreate>(_onCreate);
    on<GeofenceEdit>(_onEdit);
    on<GeofenceDelete>(_onDelete);
  }

  Future<void> _onLoad(GeofenceLoad event, Emitter<GeofenceState> emit) async {
    AppLogger.d('GeofenceBloc', 'Load → deviceId: ${event.deviceId}');
    emit(const GeofenceLoading());
    final result = await _getGeofencesUseCase(event.deviceId);
    result.fold(
      (failure) {
        AppLogger.d('GeofenceBloc', 'Load failed: ${failure.message}');
        emit(GeofenceError(failure.userMessage));
      },
      (geofences) {
        AppLogger.d('GeofenceBloc', 'Loaded ${geofences.length} geofences');
        emit(GeofenceLoaded(geofences));
      },
    );
  }

  Future<void> _onCreate(
    GeofenceCreate event,
    Emitter<GeofenceState> emit,
  ) async {
    AppLogger.d('GeofenceBloc', 'Create → deviceId: ${event.deviceId}');
    emit(const GeofenceOperationLoading());
    final result = await _createGeofenceUseCase(
      deviceId: event.deviceId,
      name: event.name,
      isActive: event.isActive,
      coordinates: event.coordinates,
      color: event.color,
      locality: event.locality,
      block: event.block,
      district: event.district,
      state: event.state,
      postcode: event.postcode,
      country: event.country,
      landmark: event.landmark,
      address: event.address,
    );
    result.fold(
      (failure) => emit(GeofenceOperationError(failure.userMessage)),
      (geofence) {
        AppLogger.d('GeofenceBloc', 'Created: ${geofence.geofenceName}');
        emit(GeofenceCreated(geofence));
        add(GeofenceLoad(event.deviceId));
      },
    );
  }

  Future<void> _onEdit(GeofenceEdit event, Emitter<GeofenceState> emit) async {
    AppLogger.d('GeofenceBloc', 'Edit → geofenceId: ${event.geofenceId}');
    emit(const GeofenceOperationLoading());
    final result = await _editGeofenceUseCase(
      deviceId: event.deviceId,
      geofenceId: event.geofenceId,
      name: event.name,
      isActive: event.isActive,
      coordinates: event.coordinates,
      color: event.color,
      geofenceNumber: event.geofenceNumber,
      locality: event.locality,
      block: event.block,
      district: event.district,
      state: event.state,
      postcode: event.postcode,
      country: event.country,
      landmark: event.landmark,
      address: event.address,
    );
    result.fold(
      (failure) => emit(GeofenceOperationError(failure.userMessage)),
      (geofence) {
        AppLogger.d('GeofenceBloc', 'Edited: ${geofence.geofenceName}');
        emit(GeofenceEdited(geofence));
        add(GeofenceLoad(event.deviceId));
      },
    );
  }

  Future<void> _onDelete(
    GeofenceDelete event,
    Emitter<GeofenceState> emit,
  ) async {
    AppLogger.d('GeofenceBloc', 'Delete → geofenceId: ${event.geofenceId}');
    emit(const GeofenceOperationLoading());
    final result = await _deleteGeofenceUseCase(
      deviceId: event.deviceId,
      geofenceId: event.geofenceId,
    );
    result.fold(
      (failure) => emit(GeofenceOperationError(failure.userMessage)),
      (_) {
        AppLogger.d('GeofenceBloc', 'Deleted: ${event.geofenceId}');
        emit(const GeofenceDeleted());
        add(GeofenceLoad(event.deviceId));
      },
    );
  }
}
