// Small data holder in the data layer
import '../../../domain/entities/signup/signup_progress_entity.dart';

class SignupProgressModel {
  final int step;
  final String personId;
  final String email;

  const SignupProgressModel({
    required this.step,
    required this.personId,
    required this.email,
  });

  /// Converts the data-layer model into a domain-layer entity
  SignupProgressEntity toEntity() =>
      SignupProgressEntity(step: step, personId: personId, email: email);
}
