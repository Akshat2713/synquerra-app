// lib/domain/repositories/user_repository.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:synquerra/domain/entities/signup/person_entity.dart';
import '../failures/failure.dart';

abstract class UserRepository {
  Future<Either<Failure, PersonEntity>> getUserProfile();
  Future<Either<Failure, PersonEntity>> updateUserProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? password,
    String? relationshipType,
    bool? isHead,
    String? middleName,
    String? mobile,
    String? birthDate,
    String? gender,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
    File? profileImage,
  });
}
