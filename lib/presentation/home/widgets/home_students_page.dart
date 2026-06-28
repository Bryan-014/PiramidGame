import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';

import '../../../domain/models/student_model.dart';
import '../../shared/app_design.dart';
import '../../shared/student_ui.dart';
import '../../shared/widgets/app_widgets.dart';
import '../../student/student_viewmodel.dart';

class HomeStudentsPage extends StatelessWidget {
  const HomeStudentsPage({
    super.key,
    required this.viewModel,
    required this.onRemove,
  });

  final StudentViewModel viewModel;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final loading = viewModel.loadStudentsCommand.running.value;
      final students = viewModel.students.value;

      if (loading) return const LoadingState();

      return RefreshIndicator(
        onRefresh: () async {
          await viewModel.loadStudentsCommand.execute();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: Column(
                  children: [
                    _StudentsHero(students: students),
                    const SizedBox(height: 14),
                    _StudentsMetrics(students: students),
                  ],
                ),
              ),
            ),
            if (students.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.person_add_alt_1_rounded,
                  title: 'Nenhum aluno cadastrado',
                  description: 'Toque no botão de adicionar para iniciar o ranking de popularidade.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 92),
                sliver: SliverList.separated(
                  itemCount: students.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final student = students[index];
                    return StudentListCard(
                      student: student,
                      onTap: () => context
                          .push('/student/detail', extra: student.id)
                          .then((_) => viewModel.loadStudentsCommand.execute()),
                      onDetails: () => context
                          .push('/student/detail', extra: student.id)
                          .then((_) => viewModel.loadStudentsCommand.execute()),
                      onEdit: () => context
                          .push('/aluno/editar', extra: student.id)
                          .then((_) => viewModel.loadStudentsCommand.execute()),
                      onRemove: () => onRemove(student.id),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _StudentsHero extends StatelessWidget {
  const _StudentsHero({required this.students});

  final List<Student> students;

  @override
  Widget build(BuildContext context) {
    return GradientHeroCard(
      badgeIcon: Icons.local_fire_department_rounded,
      badgeText: 'Ranking de Popularidade',
      title: 'Acompanhe os alunos\ne seus níveis de lenda.',
      description: 'Gerencie participantes, visualize conquistas e acompanhe a evolução no PiramidGame.',
      backgroundIcon: Icons.groups_2_rounded,
    );
  }
}

class _StudentsMetrics extends StatelessWidget {
  const _StudentsMetrics({required this.students});

  final List<Student> students;

  @override
  Widget build(BuildContext context) {
    final total = students.length;
    final average = total == 0
        ? 0.0
        : students.fold<int>(0, (sum, student) => sum + student.legendLevel) / total;
    final top = total == 0
        ? 0
        : students.map((student) => student.legendLevel).reduce((a, b) => a > b ? a : b);

    return Row(
      children: [
        Expanded(child: AppMetricCard(icon: Icons.groups_2_rounded, label: 'Alunos', value: '$total')),
        const SizedBox(width: 10),
        Expanded(child: AppMetricCard(icon: Icons.star_rounded, label: 'Média', value: average.toStringAsFixed(1))),
        const SizedBox(width: 10),
        Expanded(child: AppMetricCard(icon: Icons.emoji_events_rounded, label: 'Top nível', value: '$top')),
      ],
    );
  }
}

class StudentListCard extends StatelessWidget {
  const StudentListCard({
    super.key,
    required this.student,
    required this.onTap,
    required this.onDetails,
    required this.onEdit,
    required this.onRemove,
  });

  final Student student;
  final VoidCallback onTap;
  final VoidCallback onDetails;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant.withOpacity(.45)),
            boxShadow: AppShadows.soft(),
          ),
          child: Row(
            children: [
              _StudentAvatar(name: student.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      StudentUi.subtitle(student),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(),
                    AppPill(icon: Icons.workspace_premium_rounded, label: 'Nível ${student.legendLevel}'),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Opções',
                icon: Icon(Icons.more_vert_rounded, color: colorScheme.onSurfaceVariant),
                onSelected: (value) {
                  if (value == 'view') onDetails();
                  if (value == 'edit') onEdit();
                  if (value == 'remove') onRemove();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'view', child: _MenuAction(icon: Icons.visibility_outlined, label: 'Ver detalhes')),
                  PopupMenuItem(value: 'edit', child: _MenuAction(icon: Icons.edit_outlined, label: 'Editar')),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'remove',
                    child: _MenuAction(icon: Icons.delete_outline_rounded, label: 'Remover', color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentAvatar extends StatelessWidget {
  const _StudentAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          StudentUi.initials(name),
          style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _MenuAction extends StatelessWidget {
  const _MenuAction({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}
