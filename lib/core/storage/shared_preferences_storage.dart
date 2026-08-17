import 'package:shared_preferences/shared_preferences.dart';
import 'local_storage.dart';

class SharedPreferencesStorage implements LocalStorage {
  final SharedPreferences _prefs;

  SharedPreferencesStorage(this._prefs);

  @override
  Future<String?> getString(String key) async => _prefs.getString(key);

  @override
  Future<bool> setString(String key, String value) async => _prefs.setString(key, value);

  @override
  Future<bool?> getBool(String key) async => _prefs.getBool(key);

  @override
  Future<bool> setBool(String key, bool value) async => _prefs.setBool(key, value);

  @override
  Future<bool> remove(String key) async => _prefs.remove(key);
}