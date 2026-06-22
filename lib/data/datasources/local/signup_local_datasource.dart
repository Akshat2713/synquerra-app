import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/error/app_exceptions.dart';

class SignupLocalDataSource {
  final FlutterSecureStorage _storage;

  static const _keyStep = 'signup_step';
  static const _keyPersonId = 'signup_person_id';
  static const _keyEmail = 'signup_email';

  SignupLocalDataSource(this._storage);

  // ── Save ──────────────────────────────────────────────────
  Future<void> saveProgress({
    required int step,
    required String personId,
    required String email,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _keyStep, value: step.toString()),
        _storage.write(key: _keyPersonId, value: personId),
        _storage.write(key: _keyEmail, value: email),
      ]);
    } catch (_) {
      throw const CacheException(message: 'Failed to save signup progress.');
    }
  }

  // ── Read ──────────────────────────────────────────────────
  Future<SignupProgress?> getProgress() async {
    try {
      final stepRaw = await _storage.read(key: _keyStep);
      if (stepRaw == null) return null;

      final personId = await _storage.read(key: _keyPersonId);
      final email = await _storage.read(key: _keyEmail);

      // If any critical field is missing, treat as no progress
      if (personId == null || email == null) {
        await clearProgress();
        return null;
      }

      return SignupProgress(
        step: int.parse(stepRaw),
        personId: personId,
        email: email,
      );
    } catch (_) {
      throw const CacheException(message: 'Failed to read signup progress.');
    }
  }

  // ── Clear ─────────────────────────────────────────────────
  Future<void> clearProgress() async {
    try {
      await Future.wait([
        _storage.delete(key: _keyStep),
        _storage.delete(key: _keyPersonId),
        _storage.delete(key: _keyEmail),
      ]);
    } catch (_) {
      throw const CacheException(message: 'Failed to clear signup progress.');
    }
  }
}

// Small data holder — no need for a full model class
class SignupProgress {
  final int step;
  final String personId;
  final String email;

  const SignupProgress({
    required this.step,
    required this.personId,
    required this.email,
  });
}
