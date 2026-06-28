import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _storageKey = 'isDarkMode';

  Future<bool> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_storageKey) ?? false;
  }

  Future<bool> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_storageKey, isDark);
  }

  // Aliases em português para manter compatibilidade com main.dart/código antigo.
  Future<bool> carregarTema() => loadTheme();
  Future<bool> salvarTema(bool isDark) => saveTheme(isDark);
}
