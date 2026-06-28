import 'package:flutter/material.dart';

import '../../../domain/models/student_model.dart';
import '../../shared/app_design.dart';
import '../../shared/student_ui.dart';
import '../../shared/widgets/app_widgets.dart';

Color medalColor(int position) {
  return switch (position) {
    1 => AppColors.gold,
    2 => AppColors.silver,
    3 => AppColors.bronze,
    _ => AppColors.primary,
  };
}

class RankingHero extends StatelessWidget {
  const RankingHero({
    super.key,
    required this.totalStudents,
    required this.firstPlace,
    required this.highestScore,
  });

  final int totalStudents;
  final String firstPlace;
  final int highestScore;

  @override
  Widget build(BuildContext context) {
    return GradientHeroCard(
      badgeIcon: Icons.local_fire_department_rounded,
      badgeText: 'Ranking atualizado',
      title: 'Os maiores níveis\nde lenda da turma.',
      description: 'O topo atual é de $firstPlace, com $highestScore pontos no Nível Lenda.',
      backgroundIcon: Icons.emoji_events_rounded,
      footer: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          AppPill(icon: Icons.groups_2_rounded, label: '$totalStudents alunos', inverted: true),
          AppPill(icon: Icons.star_rounded, label: '$highestScore pts', inverted: true),
        ],
      ),
    );
  }
}

class PodiumSection extends StatelessWidget {
  const PodiumSection({super.key, required this.students});

  final List<Student> students;

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) return const SizedBox.shrink();

    if (students.length < 3) {
      return Row(
        children: [
          for (var i = 0; i < students.length; i++) ...[
            Expanded(child: PodiumCard(student: students[i], position: i + 1, highlight: i == 0)),
            if (i != students.length - 1) const SizedBox(width: 10),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: PodiumCard(student: students[1], position: 2, height: 140)),
        const SizedBox(width: 10),
        Expanded(child: PodiumCard(student: students[0], position: 1, height: 170, highlight: true)),
        const SizedBox(width: 10),
        Expanded(child: PodiumCard(student: students[2], position: 3, height: 130)),
      ],
    );
  }
}

class PodiumCard extends StatelessWidget {
  const PodiumCard({
    super.key,
    required this.student,
    required this.position,
    this.height = 145,
    this.highlight = false,
  });

  final Student student;
  final int position;
  final double height;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = medalColor(position);

    return Container(
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight ? AppColors.primary : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlight ? AppColors.primary : colorScheme.outlineVariant.withOpacity(.45)),
        boxShadow: AppShadows.soft(highlight ? AppColors.primary : Colors.black),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: highlight ? 25 : 22,
            backgroundColor: color,
            child: Text('$positionº', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 9),
          Text(
            student.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: highlight ? Colors.white : colorScheme.onSurface,
              fontSize: highlight ? 15 : 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${student.legendLevel} pts',
            style: TextStyle(
              color: highlight ? Colors.white.withOpacity(.92) : colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class RankingCard extends StatelessWidget {
  const RankingCard({super.key, required this.student, required this.position});

  final Student student;
  final int position;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = medalColor(position);
    final progress = StudentUi.levelProgress(student.legendLevel);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(.45)),
        boxShadow: AppShadows.soft(),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color,
            child: Text('$positionº', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
          ),
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
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: AppColors.primary.withOpacity(.10),
                    valueColor: AlwaysStoppedAnimation<Color>(position <= 3 ? color : AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 17),
                const SizedBox(height: 2),
                Text('${student.legendLevel}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                Text('pts', style: TextStyle(color: Colors.white.withOpacity(.82), fontSize: 10, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
