part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchUserProfile extends ProfileEvent {
  const FetchUserProfile();
}

/// NOTE: field-for-field mirror of UpdateUserProfileParams, minus the
/// business logic — the bloc just forwards these into the usecase.
class UpdateUserProfile extends ProfileEvent {
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

  const UpdateUserProfile({
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

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    password,
    relationshipType,
    isHead,
    middleName,
    mobile,
    birthDate,
    gender,
    address,
    city,
    state,
    country,
    pincode,
    profileImage,
  ];
}
