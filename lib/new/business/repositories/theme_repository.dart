// lib/business/repositories/theme_repository.dart
import 'package:dartz/dartz.dart';
import '../failures/failure.dart';

abstract class ThemeRepository {
  /// Get current theme mode (true = dark, false = light)
  Future<Either<Failure, bool>> getThemeMode();

  /// Save theme mode
  Future<Either<Failure, void>> saveThemeMode(bool isDarkMode);

  /// Toggle theme mode
  Future<Either<Failure, bool>> toggleThemeMode();
}
