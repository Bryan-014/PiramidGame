import 'package:signals/signals.dart';
import '../../core/patterns/command.dart';
import '../../core/patterns/result.dart';
import '../../domain/facades/student_facade.dart';
import '../../domain/models/student_model.dart';

class StudentViewModel {
  final StudentFacade _facade;

  StudentViewModel(this._facade) {
    loadStudentsCommand = Command0(_loadStudents);
    calculateRankingCommand = Command0(_calculateRanking);
    registerCommand = Command1(_register);
    updateCommand = Command1(_update);
    deleteCommand = Command1(_delete);
    getByIdCommand = Command1(_getById);
  }

  final students = signal<List<Student>>([]);
  final ranking = signal<List<Student>>([]);
  final selectedStudent = signal<Student?>(null);
  final errorMessage = signal<String?>(null);

  late final Command0<List<Student>> loadStudentsCommand;
  late final Command0<List<Student>> calculateRankingCommand;
  late final Command1<bool, Student> registerCommand;
  late final Command1<bool, Student> updateCommand;
  late final Command1<bool, String> deleteCommand;
  late final Command1<Student?, String> getByIdCommand;

  Future<Result<List<Student>>> _loadStudents() async {
    final result = await _facade.getAllStudents();
    if (result is Success) {
      students.value = (result as Success<List<Student>>).data;
      errorMessage.value = null;
    } else {
      errorMessage.value = (result as Failure).message;
    }
    return result;
  }

  Future<Result<List<Student>>> _calculateRanking() async {
    final result = await _facade.calculateRanking();
    if (result is Success) {
      ranking.value = (result as Success<List<Student>>).data;
      errorMessage.value = null;
    } else {
      errorMessage.value = (result as Failure).message;
    }
    return result;
  }

  Future<Result<bool>> _register(Student student) async {
    final result = await _facade.registerStudent(student);
    if (result is Success) {
      await _loadStudents();
      errorMessage.value = null;
    } else {
      errorMessage.value = (result as Failure).message;
    }
    return result;
  }

  Future<Result<bool>> _update(Student student) async {
    final result = await _facade.updateStudent(student);
    if (result is Success) {
      await _loadStudents();
      errorMessage.value = null;
    } else {
      errorMessage.value = (result as Failure).message;
    }
    return result;
  }

  Future<Result<bool>> _delete(String id) async {
    final result = await _facade.deleteStudent(id);
    if (result is Success) {
      await _loadStudents();
      errorMessage.value = null;
    } else {
      errorMessage.value = (result as Failure).message;
    }
    return result;
  }

  Future<Result<Student?>> _getById(String id) async {
    final result = await _facade.getStudentById(id);
    if (result is Success) {
      selectedStudent.value = (result as Success<Student?>).data;
      errorMessage.value = null;
    } else {
      errorMessage.value = (result as Failure).message;
    }
    return result;
  }
}
