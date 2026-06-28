import '../../core/patterns/result.dart';
import '../../data/repositories/student_repository.dart';
import '../models/student_model.dart';

class UpdateStudentUseCase {
  final StudentRepository _repository;

  UpdateStudentUseCase(this._repository);

  Future<Result<bool>> call(Student updatedStudent) async {
    if (updatedStudent.name.trim().isEmpty) {
      return const Failure<bool>('O nome do aluno é obrigatório.');
    }

    final result = await _repository.loadAll();

    if (result is Success<List<Student>>) {
      final students = List<Student>.from(result.data);
      final index = students.indexWhere(
        (student) => student.id == updatedStudent.id,
      );

      if (index == -1) {
        return const Failure<bool>('Aluno não encontrado.');
      }

      students[index] = updatedStudent;
      return _repository.save(students);
    }

    return const Failure<bool>('Erro ao processar a alteração.');
  }
}
