import '../../core/patterns/result.dart';
import '../../data/repositories/student_repository.dart';
import '../models/student_model.dart';

class CalculateRankingUseCase {
  final StudentRepository _repository;

  CalculateRankingUseCase(this._repository);

  Future<Result<List<Student>>> call() async {
    final result = await _repository.loadAll();

    if (result is Success<List<Student>>) {
      final students = List<Student>.from(result.data);
      students.sort((a, b) => b.legendLevel.compareTo(a.legendLevel));
      return Success<List<Student>>(students);
    }

    return const Failure<List<Student>>('Erro ao gerar ranking.');
  }
}
