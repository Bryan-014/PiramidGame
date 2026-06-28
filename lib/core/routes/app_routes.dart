import 'package:go_router/go_router.dart';
import '../../presentation/splash/splash_screen.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/student/student_form_screen.dart';
import '../../presentation/student/student_detail_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/student/new',
      builder: (context, state) => const StudentFormScreen(),
    ),
    GoRoute(
      path: '/student/edit',
      builder: (context, state) {
        final id = state.extra as String;
        return StudentFormScreen(alunoId: id);
      },
    ),
    GoRoute(
      path: '/student/detail',
      builder: (context, state) {
        final id = state.extra as String;
        return StudentDetailScreen(alunoId: id);
      },
    ),
  ],
);
