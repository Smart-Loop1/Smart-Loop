import 'package:finalproject/core/state/app_data_controller.dart';
import 'package:finalproject/core/state/app_data_scope.dart';
import 'package:finalproject/core/theme/app_theme.dart';
import 'package:finalproject/core/theme/app_theme_controller.dart';
import 'package:finalproject/screens/welcomescreen.dart';
import 'package:finalproject/services/firebase_water_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await Firebase.initializeApp();
  }
  final firebaseWaterService = FirebaseWaterService(
    databaseUrl: 'https://smartloop-cccf0-default-rtdb.europe-west1.firebasedatabase.app',
  );
  final appDataController = AppDataController(
    firebaseWaterService: firebaseWaterService,
  );
  await appDataController.load();
  appDataController.connectToCloud();
  runApp(MainApp(appDataController: appDataController));
}

class MainApp extends StatefulWidget {
  const MainApp({required this.appDataController, super.key});

  final AppDataController appDataController;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final AppDataController _appDataController;

  @override
  void initState() {
    super.initState();
    _appDataController = widget.appDataController;
  }

  @override
  void dispose() {
    _appDataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.mode,
      child: const WelcomeScreen(),
      builder: (context, themeMode, home) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Smart Loop',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          builder: (context, child) => AppDataScope(
            controller: _appDataController,
            child: child ?? const SizedBox.shrink(),
          ),
          home: home,
        );
      },
    );
  }
}
