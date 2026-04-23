// lib/data/repositories_impl/theme_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../business/repositories/theme_repository.dart';
import '../../business/failures/failure.dart';
import '../datasources/local/theme_local_datasource.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource _localDataSource;

  ThemeRepositoryImpl({required ThemeLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, bool>> getThemeMode() async {
    try {
      final isDarkMode = await _localDataSource.getThemeMode();
      return Right(isDarkMode);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to get theme: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveThemeMode(bool isDarkMode) async {
    try {
      await _localDataSource.saveThemeMode(isDarkMode);
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to save theme: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> toggleThemeMode() async {
    try {
      final currentMode = await _localDataSource.getThemeMode();
      final newMode = !currentMode;
      await _localDataSource.saveThemeMode(newMode);
      return Right(newMode);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to toggle theme: ${e.toString()}'),
      );
    }
  }
}
