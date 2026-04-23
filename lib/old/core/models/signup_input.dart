class SignupInput {
  final String firstName;
  final String middleName;
  final String lastName;
  final String email;
  final String mobile;
  final String password;

  SignupInput({
    required this.firstName,
    this.middleName = "", // Optional, default to empty
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.password,
  });
}
