import 'package:dartz/dartz.dart';

import '../entities/signup/person_entity.dart';
import '../failures/failure.dart';

abstract class SignupRepository {
  Future<Either<Failure, PersonEntity>> signUp({
    required String firstName,
    required String email,
    required String password,
    String? lastName,
    String? phone,
    String? userClass,
    String? birthDate,
    String? gender,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
    String? profilePhoto,
  });

  Future<Either<Failure, void>> deletePerson(String personId);
}
