class SignupProgressEntity {
  final int step;
  final String personId;
  final String email;

  const SignupProgressEntity({
    required this.step,
    required this.personId,
    required this.email,
  });
}
