// lib/data/repositories_impl/theme_repository_impl.dart
import '../../domain/repositories/theme_repository.dart';
import '../datasources/local/theme_local_datasource.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource _localDataSource;
  ThemeRepositoryImpl(this._localDataSource);

  @override
  Future<String?> getSavedTheme() => _localDataSource.getLastTheme();

  @override
  Future<void> saveTheme(String name) => _localDataSource.cacheTheme(name);
}
