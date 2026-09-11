part of 'manage_users_bloc.dart';

sealed class ManageUsersEvent extends Equatable {
  const ManageUsersEvent();
  @override
  List<Object?> get props => [];
}

class ManageUsersLoadRequested extends ManageUsersEvent {
  const ManageUsersLoadRequested();
}

class ManageUsersAddRequested extends ManageUsersEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String mobile;
  final String birthDate;
  final String gender;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String relationshipType;
  final String? middleName;
  final bool isHead;

  const ManageUsersAddRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.mobile,
    required this.birthDate,
    required this.gender,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.relationshipType,
    this.middleName,
    this.isHead = false,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    password,
    mobile,
    birthDate,
    gender,
    address,
    city,
    state,
    country,
    pincode,
    relationshipType,
    middleName,
    isHead,
  ];
}

class ManageUsersSearchByPhoneRequested extends ManageUsersEvent {
  final String phoneNumber;
  const ManageUsersSearchByPhoneRequested(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

class ManageUsersConfirmLinkRequested extends ManageUsersEvent {
  final String relationshipType;
  const ManageUsersConfirmLinkRequested(this.relationshipType);
  @override
  List<Object?> get props => [relationshipType];
}

class ManageUsersClearFoundPerson extends ManageUsersEvent {
  const ManageUsersClearFoundPerson();
}

/// Wired but disabled in UI (see kEnableDeletePerson).
class ManageUsersDeletePersonRequested extends ManageUsersEvent {
  final String personId;
  const ManageUsersDeletePersonRequested(this.personId);
  @override
  List<Object?> get props => [personId];
}

class ManageUsersUnlinkRequested extends ManageUsersEvent {
  final String relationshipId;
  const ManageUsersUnlinkRequested(this.relationshipId);
  @override
  List<Object?> get props => [relationshipId];
}
