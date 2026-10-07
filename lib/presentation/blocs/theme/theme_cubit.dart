// lib/presentation/blocs/theme/theme_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/theme_repository.dart';
import '../../../core/utils/app_logger.dart';
import '../../themes/app_palette.dart';

class ThemeCubit extends Cubit<AppThemeType> {
  final ThemeRepository _themeRepository;

  ThemeCubit(this._themeRepository) : super(AppThemeType.cleanCalm) {
    _init();
  }

  Future<void> _init() async {
    final saved = await _themeRepository.getSavedTheme();
    final type = AppThemeType.fromName(
      saved,
    ); // old 'light'/'system' -> cleanCalm
    emit(type);
    AppLogger.d('ThemeCubit', 'init → $type');
  }

  Future<void> select(AppThemeType type) async {
    if (type == state) return;
    emit(type);
    await _themeRepository.saveTheme(type.name);
    AppLogger.d('ThemeCubit', 'selected → $type');
  }

  bool get isDark => state == AppThemeType.dark;
}
