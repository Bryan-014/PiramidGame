import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/student_model.dart';

class StudentService {
  static const String _storageKey = 'students';
  static const String _legacyStorageKey = 'alunos';

  Future<List<Student>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_storageKey) ?? prefs.getString(_legacyStorageKey);
    if (raw == null || raw.trim().isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map>()
        .map((item) => Student.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<bool> saveAll(List<Student> students) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(students.map((student) => student.toJson()).toList());
    return prefs.setString(_storageKey, raw);
  }

  // Aliases em português para compatibilidade com código antigo.
  Future<List<Student>> buscarTodos() => loadAll();
  Future<bool> salvar(List<Student> students) => saveAll(students);
}
