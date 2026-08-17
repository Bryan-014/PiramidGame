import 'dart:io';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/theme_controller.dart';
import 'core/storage/local_storage.dart';
import 'core/storage/sqlite_storage.dart';
import 'data/services/theme_service.dart';
import 'data/services/student_service.dart';

final _isDarkMode = signal<bool>(false);
Signal<bool> get globalIsDarkMode => _isDarkMode;

late final ThemeService themeService;
late final StudentService studentService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final LocalStorage storage = SqliteStorage();

  themeService = ThemeService(storage);
  studentService = StudentService(storage);

  final isDark = await themeService.carregarTema();
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