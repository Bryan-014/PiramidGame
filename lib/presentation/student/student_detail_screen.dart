import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:signals/signals_flutter.dart';

import '../../data/repositories/student_repository.dart';
import '../../data/services/student_service.dart';
import '../../domain/facades/student_facade.dart';
import '../../domain/models/student_model.dart';
import '../shared/app_design.dart';
import '../shared/student_ui.dart';
import '../shared/widgets/app_top_bar.dart';
import '../shared/widgets/app_widgets.dart';
import '../shared/widgets/rating_widgets.dart';
import 'student_viewmodel.dart';
import 'widgets/student_detail_widgets.dart';

class StudentDetailScreen extends StatefulWidget {
  const StudentDetailScreen({
    super.key,
    String? studentId,
    String? alunoId,
  })  : assert(studentId != null || alunoId != null, 'studentId or alunoId is required'),
        studentId = studentId ?? alunoId!;

  final String studentId;

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late final StudentViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = StudentViewModel(StudentFacade.create(StudentRepository(StudentService())));
    _viewModel.getByIdCommand.execute(widget.studentId);
  }

  void _confirmRemove(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('Remover aluno'),
          ],
        ),
        content: const Text('Deseja realmente remover este aluno? Essa ação não poderá ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _viewModel.deleteCommand.execute(id);

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Aluno removido com sucesso.'), backgroundColor: Colors.green),
              );
              context.pop();
            },
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Remover'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'Detalhes do aluno',
        subtitle: 'Perfil, dados e pontuação',
        icon: Icons.person_search_rounded,
        leadingIcon: Icons.arrow_back_rounded,
        onLeadingTap: () => context.pop(),
      ),
      body: Watch((context) {
        final loading = _viewModel.getByIdCommand.running.value;
        if (loading) return const LoadingState();

        final student = _viewModel.selectedStudent.value;
        if (student == null) {
          return const EmptyState(
            icon: Icons.person_off_outlined,
            title: 'Aluno não encontrado',
            description: 'Não foi possível carregar as informações deste aluno.',
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: AppSpacing.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StudentDetailHero(student: student),
              const SizedBox(height: 14),
              _Metrics(student: student),
              const SizedBox(height: 14),
              _StudentInfo(student: student),
              const SizedBox(height: 14),
              _Criteria(student: student),
              const SizedBox(height: 18),
              DetailActions(
                onEdit: () => context
                    .push('/aluno/editar', extra: student.id)
                    .then((_) => _viewModel.getByIdCommand.execute(widget.studentId)),
                onRemove: () => _confirmRemove(student.id),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: AppMetricCard(icon: Icons.workspace_premium_rounded, label: 'Nível Lenda', value: '${student.legendLevel}')),
        const SizedBox(width: 10),
        Expanded(child: AppMetricCard(icon: Icons.star_rounded, label: 'Média', value: StudentUi.average(student).toStringAsFixed(1))),
        const SizedBox(width: 10),
        Expanded(child: AppMetricCard(icon: Icons.cake_rounded, label: 'Idade', value: '${StudentUi.age(student.birthDate)}')),
      ],
    );
  }
}

class _StudentInfo extends StatelessWidget {
  const _StudentInfo({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      icon: Icons.badge_outlined,
      title: 'Informações do aluno',
      children: [
        InfoRow(icon: Icons.person_outline_rounded, label: 'Nome', value: student.name),
        if (student.nickname.trim().isNotEmpty)
          InfoRow(icon: Icons.sell_outlined, label: 'Apelido', value: '"${student.nickname}"'),
        InfoRow(icon: Icons.school_outlined, label: 'Curso', value: student.course),
        InfoRow(icon: Icons.calendar_month_outlined, label: 'Turma/Ano', value: '${student.classYear}'),
        InfoRow(icon: Icons.cake_outlined, label: 'Nascimento', value: DateFormat('dd/MM/yyyy').format(student.birthDate)),
      ],
    );
  }
}

class _Criteria extends StatelessWidget {
  const _Criteria({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      icon: Icons.auto_awesome_rounded,
      title: 'Critérios de popularidade',
      subtitle: 'Notas atribuídas em cada categoria.',
      children: Student.criteriaKeys.map((key) {
        return RatingItem(
          label: Student.criteriaLabels[key] ?? key,
          score: student.scores[key] ?? 1,
        );
      }).toList(),
    );
  }
}
