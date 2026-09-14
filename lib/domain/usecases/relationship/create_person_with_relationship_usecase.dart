import 'package:dartz/dartz.dart';
import '../../failures/failure.dart';
import '../../repositories/relationship_repository.dart';
import '../../entities/signup/person_entity.dart';

class CreatePersonWithRelationshipParams {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String relationshipType;
  final String? middleName;
  final String? mobile;
  final String? birthDate;
  final String? gender;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;
  final bool isHead;

  const CreatePersonWithRelationshipParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.relationshipType,
    this.middleName,
    this.mobile,
    this.birthDate,
    this.gender,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.isHead = false,
  });
}

class CreatePersonWithRelationshipUseCase {
  final RelationshipRepository _repository;

  CreatePersonWithRelationshipUseCase(this._repository);

  Future<Either<Failure, PersonEntity>> call(
    CreatePersonWithRelationshipParams params,
  ) {
    return _repository.createPersonWithRelationship(
      firstName: params.firstName,
      lastName: params.lastName,
      email: params.email,
      password: params.password,
      relationshipType: params.relationshipType,
      middleName: params.middleName,
      mobile: params.mobile,
      birthDate: params.birthDate,
      gender: params.gender,
      address: params.address,
      city: params.city,
      state: params.state,
      country: params.country,
      pincode: params.pincode,
      isHead: params.isHead,
    );
  }
}
