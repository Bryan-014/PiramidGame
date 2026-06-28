import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:signals/signals_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/patterns/result.dart' as r;
import '../../data/repositories/student_repository.dart';
import '../../data/services/student_service.dart';
import '../../domain/facades/student_facade.dart';
import '../../domain/models/student_model.dart';
import '../../domain/models/app_constants.dart';
import '../shared/app_design.dart';
import '../shared/student_ui.dart';
import '../shared/widgets/app_top_bar.dart';
import '../shared/widgets/app_widgets.dart';
import '../shared/widgets/rating_widgets.dart';
import 'student_viewmodel.dart';
import 'widgets/student_form_widgets.dart';

class StudentFormScreen extends StatefulWidget {
  const StudentFormScreen({
    super.key,
    String? studentId,
    String? alunoId,
  }) : studentId = studentId ?? alunoId;

  final String? studentId;

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  late final StudentViewModel _viewModel;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  final _scores = Student.initialScores();

  String? _selectedCourse;
  int? _selectedYear;
  DateTime? _birthDate;

  bool get _editing => widget.studentId != null;
  int get _level => _scores.values.fold(0, (sum, score) => sum + score);
  double get _progress => StudentUi.levelProgress(_level);

  @override
  void initState() {
    super.initState();

    _viewModel = StudentViewModel(
      StudentFacade.create(StudentRepository(StudentService())),
    );

    if (_editing) {
      _viewModel.getByIdCommand.execute(widget.studentId!).then((_) {
        final student = _viewModel.selectedStudent.value;
        if (student != null) _fillForm(student);
      });
    }
  }

  void _fillForm(Student student) {
    setState(() {
      _nameCtrl.text = student.name;
      _nicknameCtrl.text = student.nickname;
      _selectedCourse = student.course;
      _selectedYear = student.classYear;
      _birthDate = student.birthDate;
      student.scores.forEach((key, value) => _scores[key] = value);
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary,
                secondary: AppColors.primaryDark,
              ),
        ),
        child: child!,
      ),
    );

    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_birthDate == null) {
      _showSnack('Selecione a data de nascimento.', AppColors.primary);
      return;
    }

    final student = Student(
      id: _editing ? widget.studentId! : const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      nickname: _nicknameCtrl.text.trim(),
      course: _selectedCourse!,
      classYear: _selectedYear!,
      birthDate: _birthDate!,
      scores: Map.from(_scores),
    );

    if (_editing) {
      await _viewModel.updateCommand.execute(student);
    } else {
      await _viewModel.registerCommand.execute(student);
    }

    final result = _editing
        ? _viewModel.updateCommand.result.value
        : _viewModel.registerCommand.result.value;

    if (!mounted) return;

    if (result is r.Failure<bool>) {
      _showSnack(result.message, Colors.red);
      return;
    }

    _showSnack(_editing ? 'Aluno atualizado!' : 'Aluno cadastrado!', Colors.green);
    context.pop();
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nicknameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: _editing ? 'Editar aluno' : 'Novo aluno',
        subtitle: _editing ? 'Atualize os dados e notas' : 'Cadastre um novo participante',
        icon: _editing ? Icons.edit_note_rounded : Icons.person_add_alt_1_rounded,
        leadingIcon: Icons.arrow_back_rounded,
        onLeadingTap: () => context.pop(),
      ),
      body: Watch((context) {
        final loading = _viewModel.registerCommand.running.value ||
            _viewModel.updateCommand.running.value ||
            _viewModel.getByIdCommand.running.value;

        if (loading && _editing && _nameCtrl.text.isEmpty) {
          return const LoadingState();
        }

        return Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: AppSpacing.screen,
            children: [
              StudentFormHero(editing: _editing, level: _level, progress: _progress),
              const SizedBox(height: 14),
              _StudentFields(
                nameCtrl: _nameCtrl,
                nicknameCtrl: _nicknameCtrl,
                selectedCourse: _selectedCourse,
                selectedYear: _selectedYear,
                birthDate: _birthDate,
                onCourseChanged: (value) => setState(() => _selectedCourse = value),
                onYearChanged: (value) => setState(() => _selectedYear = value),
                onDateTap: _selectDate,
              ),
              const SizedBox(height: 14),
              AppSectionCard(
                icon: Icons.auto_awesome_rounded,
                title: 'Critérios de popularidade',
                subtitle: 'Avalie de 1 a 5 estrelas em cada categoria.',
                children: Student.criteriaKeys.map(_buildRating).toList(),
              ),
              const SizedBox(height: 14),
              LevelSummaryCard(level: _level, progress: _progress),
              const SizedBox(height: 20),
              SaveStudentButton(loading: loading, editing: _editing, onPressed: _save),
              const SizedBox(height: 28),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRating(String key) {
    return RatingItem(
      label: Student.criteriaLabels[key] ?? key,
      score: _scores[key] ?? 1,
      onChanged: (value) => setState(() => _scores[key] = value),
    );
  }
}

class _StudentFields extends StatelessWidget {
  const _StudentFields({
    required this.nameCtrl,
    required this.nicknameCtrl,
    required this.selectedCourse,
    required this.selectedYear,
    required this.birthDate,
    required this.onCourseChanged,
    required this.onYearChanged,
    required this.onDateTap,
  });

  final TextEditingController nameCtrl;
  final TextEditingController nicknameCtrl;
  final String? selectedCourse;
  final int? selectedYear;
  final DateTime? birthDate;
  final ValueChanged<String?> onCourseChanged;
  final ValueChanged<int?> onYearChanged;
  final VoidCallback onDateTap;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      icon: Icons.person_rounded,
      title: 'Dados do aluno',
      subtitle: 'Preencha as informações principais do participante.',
      children: [
        TextFormField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Nome *',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) => value == null || value.trim().isEmpty ? 'O nome é obrigatório.' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: nicknameCtrl,
          decoration: const InputDecoration(
            labelText: 'Apelido',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: selectedCourse,
          decoration: const InputDecoration(
            labelText: 'Curso *',
            prefixIcon: Icon(Icons.school_outlined),
          ),
          items: AppConstants.courses
              .map((course) => DropdownMenuItem(value: course, child: Text(course)))
              .toList(),
          onChanged: onCourseChanged,
          validator: (value) => value == null ? 'Selecione um curso.' : null,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          value: selectedYear,
          decoration: const InputDecoration(
            labelText: 'Turma/Ano *',
            prefixIcon: Icon(Icons.calendar_month_outlined),
          ),
          items: AppConstants.classYears.reversed
              .map((year) => DropdownMenuItem(value: year, child: Text('$year')))
              .toList(),
          onChanged: onYearChanged,
          validator: (value) => value == null ? 'Selecione o ano da turma.' : null,
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onDateTap,
          borderRadius: BorderRadius.circular(10),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Data de nascimento *',
              prefixIcon: Icon(Icons.cake_outlined),
            ),
            child: Text(
              birthDate != null
                  ? DateFormat('dd/MM/yyyy').format(birthDate!)
                  : 'Toque para selecionar',
              style: TextStyle(
                color: birthDate != null
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
