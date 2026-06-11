import 'package:dartz/dartz.dart';
import 'package:latlong2/latlong.dart';
import '../failures/failure.dart';

abstract class LocationRepository {
  Future<Either<Failure, LatLng>> getCurrentUserLocation();
}
