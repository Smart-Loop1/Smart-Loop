import 'package:finalproject/core/state/app_data_controller.dart';
import 'package:finalproject/core/state/app_data_scope.dart';
import 'package:finalproject/core/theme/app_theme.dart';
import 'package:finalproject/core/theme/app_theme_controller.dart';
import 'package:finalproject/models/analytics_report.dart';
import 'package:finalproject/models/device_location.dart';
import 'package:finalproject/models/waterloop.dart';
import 'package:finalproject/screens/home_screen_content.dart';
import 'package:finalproject/screens/settings_screen.dart';
import 'package:finalproject/screens/welcomescreen.dart';
import 'package:finalproject/services/pdf_report_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  test('PDF report builds safely without cloud readings', () async {
    final bytes = await PdfReportService.buildReport(
      AnalyticsReport.awaitingCloudData(),
    );

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });

  test('devices added to app data are included in analytics reports', () {
    final appData = AppDataController()
      ..addLocation(
        const DeviceLocation(
          id: 'location-1',
          name: 'First Floor',
          devices: [WaterLoop(id: 'device-1', name: 'Kitchen Loop')],
        ),
      )
      ..addDevice(const WaterLoop(id: 'device-2', name: 'Main Loop'));

    final report = AnalyticsReport.fromDevices(
      locations: appData.locations,
      ungroupedDevices: appData.ungroupedDevices,
    );

    expect(report.totalDevices, 2);
    expect(report.devices.map((device) => device.name), [
      'Main Loop',
      'Kitchen Loop',
    ]);
    expect(report.devices.last.location, 'First Floor');
    expect(report.devices.last.totalLiters, isNull);
  });

  testWidgets('home app bar returns to the welcome screen', (tester) async {
    await tester.pumpWidget(
      _withAppData(const MaterialApp(home: WelcomeScreen())),
    );

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('My Water Devices'), findsOneWidget);
    expect(find.byTooltip('Back to welcome'), findsOneWidget);

    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Back to welcome'), findsNothing);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Back to welcome'), findsNothing);

    await tester.tap(find.text('Loops'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Back to welcome'));
    await tester.pumpAndSettle();
    expect(find.text('Get Started'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('add and edit dialogs can be reopened without exceptions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _withAppData(
        MaterialApp(theme: AppTheme.light, home: const HomeScreenContent()),
      ),
    );

    for (var index = 0; index < 3; index++) {
      await _openAddDialog(tester, option: 'Add Location');
      expect(find.byIcon(FontAwesomeIcons.toilet.data), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await _openAddDialog(tester, option: 'Add Device');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await _openAddDialog(tester, option: 'Add Location');
    await tester.enterText(find.byType(TextFormField), 'First Floor');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    for (var index = 0; index < 3; index++) {
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('dark mode can be toggled repeatedly without exceptions', (
    tester,
  ) async {
    AppThemeController.mode.value = ThemeMode.light;
    addTearDown(() => AppThemeController.mode.value = ThemeMode.light);

    await tester.pumpWidget(
      ValueListenableBuilder<ThemeMode>(
        valueListenable: AppThemeController.mode,
        builder: (context, themeMode, child) {
          return MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            home: const SettingsScreen(),
          );
        },
      ),
    );

    for (var index = 0; index < 6; index++) {
      await tester.tap(find.byType(Switch).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}

Widget _withAppData(Widget child) {
  return AppDataScope(controller: AppDataController(), child: child);
}

Future<void> _openAddDialog(
  WidgetTester tester, {
  required String option,
}) async {
  await tester.tap(find.byIcon(Icons.add_rounded));
  await tester.pumpAndSettle();
  await tester.tap(find.text(option));
  await tester.pumpAndSettle();
}
