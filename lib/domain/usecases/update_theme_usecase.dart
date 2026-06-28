import '../../core/patterns/result.dart';
import '../../data/services/theme_service.dart';

class UpdateThemeUseCase {
  final ThemeService _service;

  UpdateThemeUseCase(this._service);

  Future<Result<bool>> call(bool isDark) async {
    try {
      await _service.saveTheme(isDark);
      return Success<bool>(isDark);
    } catch (_) {
      return const Failure<bool>('Erro ao salvar tema.');
    }
  }
}

class LoadThemeUseCase {
  final ThemeService _service;

  LoadThemeUseCase(this._service);

  Future<Result<bool>> call() async {
    try {
      final isDark = await _service.loadTheme();
      return Success<bool>(isDark);
    } catch (_) {
      return const Failure<bool>('Erro ao carregar tema.');
    }
  }
}
