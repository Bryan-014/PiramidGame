import '../../core/patterns/result.dart';
import '../../data/repositories/student_repository.dart';
import '../models/student_model.dart';

class DeleteStudentUseCase {
  final StudentRepository _repository;

  DeleteStudentUseCase(this._repository);

  Future<Result<bool>> call(String id) async {
    final result = await _repository.loadAll();

    if (result is Success<List<Student>>) {
      final students = List<Student>.from(result.data)
        ..removeWhere((student) => student.id == id);

      return _repository.save(students);
    }

    return const Failure<bool>('Erro ao remover aluno.');
  }
}
