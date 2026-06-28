import '../../core/patterns/result.dart';
import '../../data/repositories/student_repository.dart';
import '../models/student_model.dart';

class GetStudentsUseCase {
  final StudentRepository _repository;

  GetStudentsUseCase(this._repository);

  Future<Result<List<Student>>> call() {
    return _repository.loadAll();
  }
}
