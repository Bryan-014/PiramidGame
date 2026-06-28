import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../shared/widgets/app_widgets.dart';
import '../student/student_viewmodel.dart';
import 'widgets/ranking_cards.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({
    super.key,
    required this.studentViewModel,
  });

  final StudentViewModel studentViewModel;

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final loading = studentViewModel.calculateRankingCommand.running.value;
      final ranking = studentViewModel.ranking.value;

      if (loading) return const LoadingState();

      if (ranking.isEmpty) {
        return const EmptyState(
          icon: Icons.emoji_events_outlined,
          title: 'Nenhum aluno no ranking',
          description: 'Depois que os alunos forem cadastrados, eles aparecerão aqui ordenados pelo Nível Lenda.',
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await studentViewModel.calculateRankingCommand.execute();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                child: RankingHero(
                  totalStudents: ranking.length,
                  firstPlace: ranking.first.name,
                  highestScore: ranking.first.legendLevel,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: PodiumSection(students: ranking),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              sliver: SliverList.separated(
                itemCount: ranking.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) => RankingCard(
                  student: ranking[index],
                  position: index + 1,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
