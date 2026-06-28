import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';

import '../../data/repositories/student_repository.dart';
import '../../data/services/student_service.dart';
import '../../data/services/theme_service.dart';
import '../../domain/facades/student_facade.dart';
import '../../domain/facades/theme_facade.dart';
import '../about/about_screen.dart';
import '../ranking/ranking_screen.dart';
import '../shared/app_design.dart';
import '../shared/widgets/app_top_bar.dart';
import '../student/student_viewmodel.dart';
import 'theme_viewmodel.dart';
import 'widgets/home_drawer.dart';
import 'widgets/home_students_page.dart';
import 'widgets/menu_destination.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late final StudentViewModel studentViewModel;
  late final ThemeViewModel themeViewModel;

  int _currentPage = 0;

  static const _destinations = [
    MenuDestination(
      title: 'Alunos',
      subtitle: 'Gerencie os participantes',
      icon: Icons.groups_2_outlined,
      selectedIcon: Icons.groups_2_rounded,
    ),
    MenuDestination(
      title: 'Ranking',
      subtitle: 'Veja a classificação',
      icon: Icons.emoji_events_outlined,
      selectedIcon: Icons.emoji_events_rounded,
    ),
    MenuDestination(
      title: 'Sobre',
      subtitle: 'Informações do projeto',
      icon: Icons.school_outlined,
      selectedIcon: Icons.school_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();

    final service = StudentService();
    studentViewModel = StudentViewModel(
      StudentFacade.create(StudentRepository(service)),
    );

    themeViewModel = ThemeViewModel(
      ThemeFacade.create(ThemeService()),
    );

    themeViewModel.loadThemeCommand.execute();
    studentViewModel.loadStudentsCommand.execute();
  }

  void _selectPage(int index) {
    Navigator.pop(context);
    setState(() => _currentPage = index);

    if (index == 1) {
      studentViewModel.calculateRankingCommand.execute();
    }
  }

  void _confirmRemove(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Remover aluno'),
        content: const Text('Deseja realmente remover este aluno?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              studentViewModel.deleteCommand.execute(id);
            },
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final isDark = themeViewModel.isDarkMode.value;
      final destination = _destinations[_currentPage];

      return Scaffold(
        key: _scaffoldKey,
        drawer: HomeDrawer(
          isDark: isDark,
          currentIndex: _currentPage,
          destinations: _destinations,
          onSelect: _selectPage,
          onThemeToggle: () => themeViewModel.toggleThemeCommand.execute(),
        ),
        appBar: AppTopBar(
          title: destination.title,
          subtitle: 'PiramidGame IFPR',
          icon: destination.selectedIcon,
          leadingIcon: Icons.menu_rounded,
          onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
          trailing: HeaderIconButton(
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            tooltip: 'Alternar tema',
            onTap: () => themeViewModel.toggleThemeCommand.execute(),
          ),
        ),
        body: IndexedStack(
          index: _currentPage,
          children: [
            HomeStudentsPage(viewModel: studentViewModel, onRemove: _confirmRemove),
            RankingScreen(studentViewModel: studentViewModel),
            const AboutScreen(),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: _currentPage == 0
            ? FloatingActionButton(
                tooltip: 'Novo aluno',
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onPressed: () => context
                    .push('/student/new')
                    .then((_) => studentViewModel.loadStudentsCommand.execute()),
                child: const Icon(Icons.person_add_alt_1_rounded, size: 27),
              )
            : null,
      );
    });
  }
}
