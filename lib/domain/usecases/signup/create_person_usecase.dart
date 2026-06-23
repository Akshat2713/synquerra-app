import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../repositories/signup_repository.dart';
import '../../entities/signup/signup_entity.dart';
import '../base_usecase.dart';

class CreatePersonParams {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String birthDate;
  final String gender;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;

  const CreatePersonParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.gender,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
  });
}

class CreatePersonUseCase implements UseCase<PersonEntity, CreatePersonParams> {
  final SignupRepository _repository;

  CreatePersonUseCase(this._repository);

  @override
  Future<Either<Failure, PersonEntity>> call(CreatePersonParams params) {
    return _repository.createPerson(
      firstName: params.firstName,
      lastName: params.lastName,
      email: params.email,
      phone: params.phone,
      birthDate: params.birthDate,
      gender: params.gender,
      address: params.address,
      city: params.city,
      state: params.state,
      country: params.country,
      pincode: params.pincode,
    );
  }
}
