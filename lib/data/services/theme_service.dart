import '../../core/storage/local_storage.dart';
import '../../core/storage/storage_instance.dart';

class ThemeService {
  static const String _storageKey = 'isDarkMode';
  final LocalStorage _storage;

  ThemeService([LocalStorage? storage]) : _storage = storage ?? appStorage;

  Future<bool> loadTheme() async {
    final isDark = await _storage.getBool(_storageKey);
    return isDark ?? false;
  }

  Future<bool> saveTheme(bool isDark) async {
    return _storage.setBool(_storageKey, isDark);
  }

  Future<bool> carregarTema() => loadTheme();
  Future<bool> salvarTema(bool isDark) => saveTheme(isDark);
}