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
  final String phone;
  final String birthDate;
  final String gender;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String relationshipType;

  const ManageUsersAddRequested({
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
    required this.relationshipType,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    phone,
    birthDate,
    gender,
    address,
    city,
    state,
    country,
    pincode,
    relationshipType,
  ];
}

class ManageUsersDeleteRequested extends ManageUsersEvent {
  final String personId;
  const ManageUsersDeleteRequested(this.personId);

  @override
  List<Object?> get props => [personId];
}
