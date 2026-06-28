import '../../core/patterns/result.dart';
import '../../domain/models/student_model.dart';
import '../services/student_service.dart';

class StudentRepository {
  final StudentService _service;

  StudentRepository(this._service);

  Future<Result<List<Student>>> loadAll() async {
    try {
      final students = await _service.loadAll();
      return Success<List<Student>>(students);
    } catch (_) {
      return const Failure<List<Student>>('Erro ao carregar alunos.');
    }
  }

  Future<Result<Student?>> loadById(String id) async {
    try {
      final students = await _service.loadAll();
      final matches = students.where((student) => student.id == id);
      return Success<Student?>(matches.isEmpty ? null : matches.first);
    } catch (_) {
      return const Failure<Student?>('Erro ao buscar aluno.');
    }
  }

  Future<Result<bool>> save(List<Student> students) async {
    try {
      final saved = await _service.saveAll(students);
      return Success<bool>(saved);
    } catch (_) {
      return const Failure<bool>('Erro ao salvar alunos.');
    }
  }

  // Aliases em português para compatibilidade com código antigo.
  Future<Result<List<Student>>> buscarTodos() => loadAll();
  Future<Result<Student?>> buscarPorId(String id) => loadById(id);
  Future<Result<bool>> salvar(List<Student> students) => save(students);
}
