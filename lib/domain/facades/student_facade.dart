import '../../core/patterns/result.dart';
import '../../data/repositories/student_repository.dart';
import '../models/student_model.dart';
import '../usecases/calculate_ranking_usecase.dart';
import '../usecases/delete_student_usecase.dart';
import '../usecases/get_student_by_id_usecase.dart';
import '../usecases/get_students_usecase.dart';
import '../usecases/register_student_usecase.dart';
import '../usecases/update_student_usecase.dart';

class StudentFacade {
  final RegisterStudentUseCase _register;
  final UpdateStudentUseCase _update;
  final DeleteStudentUseCase _delete;
  final GetStudentsUseCase _getAll;
  final GetStudentByIdUseCase _getById;
  final CalculateRankingUseCase _calculateRanking;

  StudentFacade({
    required RegisterStudentUseCase register,
    required UpdateStudentUseCase update,
    required DeleteStudentUseCase delete,
    required GetStudentsUseCase getAll,
    required GetStudentByIdUseCase getById,
    required CalculateRankingUseCase calculateRanking,
  })  : _register = register,
        _update = update,
        _delete = delete,
        _getAll = getAll,
        _getById = getById,
        _calculateRanking = calculateRanking;

  factory StudentFacade.create(StudentRepository repository) {
    return StudentFacade(
      register: RegisterStudentUseCase(repository),
      update: UpdateStudentUseCase(repository),
      delete: DeleteStudentUseCase(repository),
      getAll: GetStudentsUseCase(repository),
      getById: GetStudentByIdUseCase(repository),
      calculateRanking: CalculateRankingUseCase(repository),
    );
  }

  Future<Result<bool>> registerStudent(Student student) => _register(student);
  Future<Result<bool>> updateStudent(Student student) => _update(student);
  Future<Result<bool>> deleteStudent(String id) => _delete(id);
  Future<Result<List<Student>>> getAllStudents() => _getAll();
  Future<Result<Student?>> getStudentById(String id) => _getById(id);
  Future<Result<List<Student>>> calculateRanking() => _calculateRanking();
}
