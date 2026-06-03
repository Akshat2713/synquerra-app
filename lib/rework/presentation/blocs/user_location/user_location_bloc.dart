import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../../../domain/usecases/location/get_user_location_usecase.dart';
import '../../../domain/failures/failure_extentions.dart';

part 'user_location_event.dart';
part 'user_location_state.dart';

class UserLocationBloc extends Bloc<UserLocationEvent, UserLocationState> {
  final GetUserLocationUseCase _getUserLocationUseCase;

  UserLocationBloc({required GetUserLocationUseCase getUserLocationUseCase})
    : _getUserLocationUseCase = getUserLocationUseCase,
      super(UserLocationInitial()) {
    on<FetchUserLocation>((event, emit) async {
      emit(UserLocationLoading());
      final result = await _getUserLocationUseCase();
      result.fold(
        (failure) => emit(UserLocationError(mapFailureToMessage(failure))),
        (position) => emit(UserLocationLoaded(position)),
      );
    });
  }
}
