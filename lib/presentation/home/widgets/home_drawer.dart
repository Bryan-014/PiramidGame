import 'package:flutter/material.dart';

import '../../shared/app_design.dart';
import '../../shared/widgets/app_widgets.dart';
import 'menu_destination.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    super.key,
    required this.isDark,
    required this.currentIndex,
    required this.destinations,
    required this.onSelect,
    required this.onThemeToggle,
  });

  final bool isDark;
  final int currentIndex;
  final List<MenuDestination> destinations;
  final ValueChanged<int> onSelect;
  final VoidCallback onThemeToggle;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      child: SafeArea(
        child: Column(
          children: [
            const _DrawerHeader(),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: destinations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (_, index) {
                  final destination = destinations[index];
                  return _DrawerItem(
                    destination: destination,
                    selected: index == currentIndex,
                    onTap: () => onSelect(index),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    AppIconBox(icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, size: 38),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isDark ? 'Modo escuro' : 'Modo claro',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Switch(
                      value: isDark,
                      activeThumbColor: AppColors.primary,
                      onChanged: (_) => onThemeToggle(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
      decoration: const BoxDecoration(gradient: AppColors.gradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.13),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(.25), width: 1.4),
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 14),
          const Text(
            'PiramidGame',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(
            'Ranking de Popularidade',
            style: TextStyle(color: Colors.white.withOpacity(.86), fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          const AppPill(icon: Icons.school_rounded, label: 'IFPR • Campus Paranaguá', inverted: true),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final MenuDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: selected ? AppColors.primary.withOpacity(.12) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              AppIconBox(
                icon: selected ? destination.selectedIcon : destination.icon,
                size: 40,
                color: selected ? Colors.white : colorScheme.onSurfaceVariant,
                backgroundColor: selected ? AppColors.primary : colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.title,
                      style: TextStyle(
                        color: selected ? AppColors.primary : colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      destination.subtitle,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected) const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
