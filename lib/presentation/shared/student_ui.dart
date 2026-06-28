import '../../domain/models/student_model.dart';

class StudentUi {
  const StudentUi._();

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static String subtitle(Student student) {
    final nickname = student.nickname.trim();
    if (nickname.isEmpty) return '${student.course} • ${student.classYear}';
    return '"$nickname" • ${student.course} • ${student.classYear}';
  }

  static double average(Student student) {
    if (student.scores.isEmpty) return 0;
    final total = student.scores.values.fold<int>(0, (sum, score) => sum + score);
    return total / student.scores.length;
  }

  static double levelProgress(int legendLevel) {
    return (legendLevel / 75).clamp(0.0, 1.0).toDouble();
  }

  static int age(DateTime birthDate) {
    final today = DateTime.now();
    var age = today.year - birthDate.year;
    final beforeBirthday = today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day);
    return beforeBirthday ? age - 1 : age;
  }
}
