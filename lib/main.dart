import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:signals/signals_flutter.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/theme_service.dart';
import 'firebase_options.dart';

final _isDarkMode = signal<bool>(false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
