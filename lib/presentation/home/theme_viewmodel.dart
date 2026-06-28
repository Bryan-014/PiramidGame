import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart';
import '../../domain/facades/theme_facade.dart';
import '../../main.dart';

class ThemeViewModel {
  final ThemeFacade _facade;

  ThemeViewModel(this._facade) {
    toggleThemeCommand = Command0(_toggleTheme);
    loadThemeCommand = Command0(_loadTheme);
  }

  get isDarkMode => globalIsDarkMode;

  late final Command0<bool> toggleThemeCommand;
  late final Command0<bool> loadThemeCommand;

  Future<Result<bool>> _loadTheme() async {
    final result = await _facade.loadTheme();
    if (result is Success) {
      globalIsDarkMode.value = (result as Success<bool>).data;
    }
    return result;
  }

  Future<Result<bool>> _toggleTheme() async {
    final newValue = !globalIsDarkMode.value;
    final result = await _facade.updateTheme(newValue);
    if (result is Success) {
      globalIsDarkMode.value = newValue;
    }
    return result;
  }
}
