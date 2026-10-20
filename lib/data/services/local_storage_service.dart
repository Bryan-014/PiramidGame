import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _uidKey = 'pyramidgame_usuario_uid';

  Future<void> salvarUsuario(String uid) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_uidKey, uid);
  }

  Future<String?> carregarUidUsuario() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_uidKey);
  }

  Future<void> limparUsuario() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_uidKey);
  }
}
