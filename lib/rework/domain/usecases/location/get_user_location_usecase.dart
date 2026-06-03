import 'package:dartz/dartz.dart';
import 'package:latlong2/latlong.dart';
import '../../failures/failure.dart';
import '../../repositories/location_repository.dart';

class GetUserLocationUseCase {
  final LocationRepository repository;

  GetUserLocationUseCase(this.repository);

  Future<Either<Failure, LatLng>> call() async {
    return await repository.getCurrentUserLocation();
  }
}
