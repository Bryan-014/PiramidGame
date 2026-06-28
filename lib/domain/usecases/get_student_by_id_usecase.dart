import '../../core/patterns/result.dart';
import '../../data/repositories/student_repository.dart';
import '../models/student_model.dart';

class GetStudentByIdUseCase {
  final StudentRepository _repository;

  GetStudentByIdUseCase(this._repository);

  Future<Result<Student?>> call(String id) {
    return _repository.loadById(id);
  }
}
