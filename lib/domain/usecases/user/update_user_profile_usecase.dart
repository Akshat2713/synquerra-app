// lib/domain/usecases/user/update_user_profile_usecase.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:synquerra/domain/entities/signup/person_entity.dart';
import '../../failures/failure.dart';
import '../../repositories/user_repository.dart';
import '../base_usecase.dart';

class UpdateUserProfileParams {
  final String firstName;
  final String lastName;
  final String email;
  final String? password;
  final String? relationshipType;
  final bool? isHead;
  final String? middleName;
  final String? mobile;
  final String? birthDate;
  final String? gender;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;
  final File? profileImage;

  UpdateUserProfileParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.password,
    this.relationshipType,
    this.isHead,
    this.middleName,
    this.mobile,
    this.birthDate,
    this.gender,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.profileImage,
  });
}

class UpdateUserProfileUseCase
    implements UseCase<PersonEntity, UpdateUserProfileParams> {
  final UserRepository _repository;

  UpdateUserProfileUseCase(this._repository);

  @override
  Future<Either<Failure, PersonEntity>> call(UpdateUserProfileParams params) {
    return _repository.updateUserProfile(
      firstName: params.firstName,
      lastName: params.lastName,
      email: params.email,
      password: params.password,
      relationshipType: params.relationshipType,
      isHead: params.isHead,
      middleName: params.middleName,
      mobile: params.mobile,
      birthDate: params.birthDate,
      gender: params.gender,
      address: params.address,
      city: params.city,
      state: params.state,
      country: params.country,
      pincode: params.pincode,
      profileImage: params.profileImage,
    );
  }
}
