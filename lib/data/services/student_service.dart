import 'dart:convert';
import '../../core/storage/local_storage.dart';
import '../../domain/models/student_model.dart';
import '../../core/storage/storage_instance.dart';

class StudentService {
  static const String _storageKey = 'students';
  static const String _legacyStorageKey = 'alunos';

  final LocalStorage _storage;

  StudentService([LocalStorage? storage]) : _storage = storage ?? appStorage;

  Future<List<Student>> loadAll() async {
    final raw = await _storage.getString(_storageKey) ?? 
                await _storage.getString(_legacyStorageKey);

    if (raw == null || raw.trim().isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      return decoded
          .whereType<Map>()
          .map((item) => Student.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveAll(List<Student> students) async {
    final raw = jsonEncode(students.map((student) => student.toJson()).toList());
    return _storage.setString(_storageKey, raw);
  }

  Future<List<Student>> buscarTodos() => loadAll();
  Future<bool> salvar(List<Student> students) => saveAll(students);
}