// lib/domain/repositories/theme_repository.dart
// Stores the theme as a plain String so domain/data stay free of presentation types.
abstract class ThemeRepository {
  Future<String?> getSavedTheme();
  Future<void> saveTheme(String name);
}
