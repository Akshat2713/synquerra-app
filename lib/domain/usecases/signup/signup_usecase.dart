import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../repositories/signup_repository.dart';
import '../../entities/signup/person_entity.dart';
import '../base_usecase.dart';

class SignUpParams {
  final String firstName;
  final String email;
  final String password;
  final String? lastName;
  final String? phone;
  final String? userClass;
  final String? birthDate;
  final String? gender;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;
  final String? profilePhoto;

  const SignUpParams({
    required this.firstName,
    required this.email,
    required this.password,
    this.lastName,
    this.phone,
    this.userClass,
    this.birthDate,
    this.gender,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.profilePhoto,
  });
}

class SignUpUseCase implements UseCase<PersonEntity, SignUpParams> {
  final SignupRepository _repository;

  SignUpUseCase(this._repository);

  @override
  Future<Either<Failure, PersonEntity>> call(SignUpParams params) {
    return _repository.signUp(
      firstName: params.firstName,
      email: params.email,
      password: params.password,
      lastName: params.lastName,
      phone: params.phone,
      userClass: params.userClass,
      birthDate: params.birthDate,
      gender: params.gender,
      address: params.address,
      city: params.city,
      state: params.state,
      country: params.country,
      pincode: params.pincode,
      profilePhoto: params.profilePhoto,
    );
  }
}
