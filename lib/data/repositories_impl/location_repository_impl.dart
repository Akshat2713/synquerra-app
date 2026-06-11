import 'package:dartz/dartz.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/location_repository.dart';
import '../../core/error/app_exceptions.dart';
import '../mappers/failure_mapper.dart';

class LocationRepositoryImpl implements LocationRepository {
  final Location _location;

  LocationRepositoryImpl({Location? location})
    : _location = location ?? Location();

  @override
  Future<Either<Failure, LatLng>> getCurrentUserLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          // Throw your custom exception instead of hardcoding a Failure
          throw const AppException(message: 'Location services are disabled.');
        }
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          throw const PermissionException(
            message: 'Location permissions were denied.',
          );
        }
      }

      final locationData = await _location.getLocation();
      if (locationData.latitude == null || locationData.longitude == null) {
        throw const ServerException(
          message: 'Could not determine device coordinates.',
        );
      }

      return Right(LatLng(locationData.latitude!, locationData.longitude!));
    } catch (e) {
      // Funnel all exceptions through your centralized mapper
      return Left(mapExceptionToFailure(e));
    }
  }
}
