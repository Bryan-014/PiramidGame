import '../../core/patterns/result.dart';
import '../../data/services/theme_service.dart';
import '../usecases/update_theme_usecase.dart';

class ThemeFacade {
  final LoadThemeUseCase _load;
  final UpdateThemeUseCase _update;

  ThemeFacade({
    required LoadThemeUseCase load,
    required UpdateThemeUseCase update,
  })  : _load = load,
        _update = update;

  factory ThemeFacade.create(ThemeService service) {
    return ThemeFacade(
      load: LoadThemeUseCase(service),
      update: UpdateThemeUseCase(service),
    );
  }

  Future<Result<bool>> loadTheme() => _load();
  Future<Result<bool>> updateTheme(bool isDark) => _update(isDark);

  Future<Result<bool>> carregarTema() => loadTheme();
  Future<Result<bool>> alterarTema(bool isDark) => updateTheme(isDark);
}
