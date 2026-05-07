import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/analytics/analytics_entity.dart';
import '../../../domain/failures/failure.dart';
import '../../../domain/usecases/analytics/get_analytics_usecase.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetAnalyticsUseCase _getAnalyticsUseCase;

  AnalyticsBloc({required GetAnalyticsUseCase getAnalyticsUseCase})
    : _getAnalyticsUseCase = getAnalyticsUseCase,
      super(AnalyticsInitial()) {
    on<AnalyticsLoadDefault>(_onLoadDefault);
    on<AnalyticsFilterChanged>(_onFilterChanged);
    on<AnalyticsCustomRangeSelected>(_onCustomRange);
    on<AnalyticsSliderChanged>(_onSliderChanged);
  }

  Future<void> _onLoadDefault(
    AnalyticsLoadDefault event,
    Emitter<AnalyticsState> emit,
  ) async {
    debugPrint('[AnalyticsBloc] LoadDefault → imei: ${event.imei}');
    emit(AnalyticsLoading());
    await _fetch(
      emit: emit,
      imei: event.imei,
      filter: AnalyticsFilter.latest,
      limit: 1,
    );
  }

  Future<void> _onFilterChanged(
    AnalyticsFilterChanged event,
    Emitter<AnalyticsState> emit,
  ) async {
    debugPrint('[AnalyticsBloc] FilterChanged → ${event.filter}');
    emit(AnalyticsLoading());

    final now = DateTime.now().toUtc();
    DateTime startDate;

    switch (event.filter) {
      case AnalyticsFilter.latest:
        return; // handled by AnalyticsLoadDefault
      case AnalyticsFilter.lastHour:
        startDate = now.subtract(const Duration(hours: 1));
        break;
      case AnalyticsFilter.last24Hours:
        startDate = now.subtract(const Duration(hours: 24));
        break;
      case AnalyticsFilter.lastWeek:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case AnalyticsFilter.custom:
        return; // handled by AnalyticsCustomRangeSelected
    }

    await _fetch(
      emit: emit,
      imei: event.imei,
      filter: event.filter,
      startDate: startDate,
      endDate: now,
    );
  }

  Future<void> _onCustomRange(
    AnalyticsCustomRangeSelected event,
    Emitter<AnalyticsState> emit,
  ) async {
    debugPrint(
      '[AnalyticsBloc] CustomRange → '
      '${event.startDate} to ${event.endDate}',
    );
    emit(AnalyticsLoading());
    await _fetch(
      emit: emit,
      imei: event.imei,
      filter: AnalyticsFilter.custom,
      startDate: event.startDate.toUtc(),
      endDate: event.endDate.toUtc(),
      startDateDt: event.startDate,
      endDateDt: event.endDate,
    );
  }

  void _onSliderChanged(
    AnalyticsSliderChanged event,
    Emitter<AnalyticsState> emit,
  ) {
    if (state is! AnalyticsLoaded) return;
    final current = state as AnalyticsLoaded;
    debugPrint('[AnalyticsBloc] Slider → index: ${event.index}');
    emit(current.copyWith(sliderIndex: event.index));
  }

  Future<void> _fetch({
    required Emitter<AnalyticsState> emit,
    required String imei,
    required AnalyticsFilter filter,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? startDateDt,
    DateTime? endDateDt,
    int? limit,
  }) async {
    final result = await _getAnalyticsUseCase(
      AnalyticsParams(
        imei: imei,
        startDate: startDate != null ? _toIso(startDate) : null,
        endDate: endDate != null ? _toIso(endDate) : null,
        limit: limit,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('[AnalyticsBloc] Fetch failed: ${failure.message}');
        emit(AnalyticsError(_mapFailure(failure)));
      },
      (points) {
        debugPrint('[AnalyticsBloc] Fetched ${points.length} points');
        emit(
          AnalyticsLoaded(
            points: points,
            activeFilter: filter,
            startDate: startDateDt,
            endDate: endDateDt,
            sliderIndex: 0,
          ),
        );
      },
    );
  }

  String _toIso(DateTime dt) => '${dt.toIso8601String().split('.').first}Z';

  String _mapFailure(Failure failure) {
    if (failure is NetworkFailure) return 'No internet connection.';
    if (failure is ServerFailure)
      return failure.message.isNotEmpty ? failure.message : 'Server error.';
    return 'Something went wrong.';
  }
}
