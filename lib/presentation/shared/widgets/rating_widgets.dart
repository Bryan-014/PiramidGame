import 'package:flutter/material.dart';

import '../app_design.dart';

class RatingItem extends StatelessWidget {
  const RatingItem({
    super.key,
    required this.label,
    required this.score,
    this.onChanged,
  });

  final String label;
  final int score;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.055),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(.08)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 420;
          final content = [
            Expanded(child: _RatingTitle(label: label, score: score)),
            const SizedBox(width: 8),
            StarsRow(score: score, onChanged: onChanged),
          ];

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RatingTitle(label: label, score: score),
                const SizedBox(height: 8),
                StarsRow(score: score, onChanged: onChanged),
              ],
            );
          }

          return Row(children: content);
        },
      ),
    );
  }
}

class StarsRow extends StatelessWidget {
  const StarsRow({
    super.key,
    required this.score,
    this.onChanged,
  });

  final int score;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final star = index + 1;
        final selected = star <= score;
        final icon = Icon(
          selected ? Icons.star_rounded : Icons.star_border_rounded,
          color: selected ? AppColors.primary : AppColors.primary.withOpacity(.35),
          size: 27,
        );

        if (onChanged == null) {
          return Padding(padding: const EdgeInsets.all(1), child: icon);
        }

        return InkWell(
          onTap: () => onChanged!(star),
          borderRadius: BorderRadius.circular(12),
          child: Padding(padding: const EdgeInsets.all(1), child: icon),
        );
      }),
    );
  }
}

class _RatingTitle extends StatelessWidget {
  const _RatingTitle({required this.label, required this.score});

  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$score/5',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
