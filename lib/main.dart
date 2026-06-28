import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/theme_controller.dart';
import 'data/services/theme_service.dart';

final _isDarkMode = signal<bool>(false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isDark = await ThemeService().carregarTema();
  _isDarkMode.value = isDark;

  runApp(const PiramidGameApp());
}

class PiramidGameApp extends StatelessWidget {
  const PiramidGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      return MaterialApp.router(
        title: 'PiramidGame IFPR',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        routerConfig: appRouter,
      );
    });
  }
}

Signal<bool> get globalIsDarkMode => _isDarkMode;
