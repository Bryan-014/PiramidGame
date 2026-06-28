import '../../core/patterns/result.dart';
import '../../data/repositories/student_repository.dart';
import '../models/student_model.dart';

class RegisterStudentUseCase {
  final StudentRepository _repository;

  RegisterStudentUseCase(this._repository);

  Future<Result<bool>> call(Student newStudent) async {
    if (newStudent.name.trim().isEmpty) {
      return const Failure<bool>('O nome do aluno é obrigatório.');
    }

    final result = await _repository.loadAll();

    if (result is Success<List<Student>>) {
      final students = List<Student>.from(result.data);
      students.add(newStudent);

      return _repository.save(students);
    }

    return const Failure<bool>('Erro ao processar o cadastro.');
  }
}
