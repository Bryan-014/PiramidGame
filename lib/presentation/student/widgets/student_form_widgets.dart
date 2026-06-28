import 'package:flutter/material.dart';

import '../../shared/app_design.dart';
import '../../shared/widgets/app_widgets.dart';

class StudentFormHero extends StatelessWidget {
  const StudentFormHero({
    super.key,
    required this.editing,
    required this.level,
    required this.progress,
  });

  final bool editing;
  final int level;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return GradientHeroCard(
      badgeIcon: Icons.local_fire_department_rounded,
      badgeText: editing ? 'Edição de perfil' : 'Novo participante',
      title: editing ? 'Atualize os dados\ne o nível de lenda.' : 'Cadastre um aluno\ne monte sua pontuação.',
      description: 'A soma das notas define o Nível Lenda e posiciona o aluno no ranking geral.',
      backgroundIcon: editing ? Icons.edit_note_rounded : Icons.person_add_alt_1_rounded,
      footer: _ProgressPanel(level: level, progress: progress),
    );
  }
}

class LevelSummaryCard extends StatelessWidget {
  const LevelSummaryCard({
    super.key,
    required this.level,
    required this.progress,
  });

  final int level;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(.45)),
        boxShadow: AppShadows.soft(),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nível Lenda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(
                  '$level pontos acumulados',
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: AppColors.primary.withOpacity(.10),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SaveStudentButton extends StatelessWidget {
  const SaveStudentButton({
    super.key,
    required this.loading,
    required this.editing,
    required this.onPressed,
  });

  final bool loading;
  final bool editing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(.45),
          elevation: 7,
          shadowColor: AppColors.primary.withOpacity(.30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
              )
            : Icon(editing ? Icons.save_as_rounded : Icons.person_add_alt_1_rounded),
        label: Text(
          editing ? 'Salvar alterações' : 'Cadastrar aluno',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({required this.level, required this.progress});

  final int level;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(.12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nível Lenda atual',
                  style: TextStyle(color: Colors.white.withOpacity(.88), fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '$level / 75',
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 9),
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
      ),
    );
  }
}
