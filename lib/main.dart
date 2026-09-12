import 'package:finalproject/core/state/app_data_controller.dart';
import 'package:finalproject/core/state/app_data_scope.dart';
import 'package:finalproject/core/theme/app_theme.dart';
import 'package:finalproject/core/theme/app_theme_controller.dart';
import 'package:finalproject/screens/welcomescreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final AppDataController _appDataController;

  @override
  void initState() {
    super.initState();
    _appDataController = AppDataController();
  }

  @override
  void dispose() {
    _appDataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDataScope(
      controller: _appDataController,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: AppThemeController.mode,
        child: const WelcomeScreen(),
        builder: (context, themeMode, home) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Smart Loop',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            home: home,
          );
        },
      ),
    );
  }
}
