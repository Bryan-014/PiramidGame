import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/student_model.dart';
import '../../shared/app_design.dart';
import '../../shared/student_ui.dart';
import '../../shared/widgets/app_widgets.dart';

class StudentDetailHero extends StatelessWidget {
  const StudentDetailHero({super.key, required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    return GradientHeroCard(
      leading: Row(
        children: [
          _HeroAvatar(name: student.name),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.4,
                  ),
                ),
                if (student.nickname.trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    '"${student.nickname}"',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withOpacity(.84), fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      badgeIcon: Icons.workspace_premium_rounded,
      badgeText: 'Nível Lenda: ${student.legendLevel} / 75 pts',
      title: '',
      description: '',
      backgroundIcon: Icons.person_rounded,
      footer: _HeroFooter(student: student),
    );
  }
}

class DetailActions extends StatelessWidget {
  const DetailActions({
    super.key,
    required this.onEdit,
    required this.onRemove,
  });

  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Editar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Remover'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 7,
                shadowColor: Colors.red.withOpacity(.30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroAvatar extends StatelessWidget {
  const _HeroAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(.24), width: 1.4),
      ),
      child: Center(
        child: Text(
          StudentUi.initials(name),
          style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _HeroFooter extends StatelessWidget {
  const _HeroFooter({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final progress = StudentUi.levelProgress(student.legendLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppPill(icon: Icons.school_outlined, label: student.course, inverted: true),
            AppPill(icon: Icons.calendar_month_outlined, label: '${student.classYear}', inverted: true),
            AppPill(icon: Icons.cake_outlined, label: DateFormat('dd/MM/yyyy').format(student.birthDate), inverted: true),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: Colors.white.withOpacity(.18),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }
}
