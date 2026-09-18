import 'dart:io';

import 'package:finalproject/models/analytics_report.dart';
import 'package:finalproject/services/pdf_report_service.dart';

Future<void> main() async {
  // Documentation-only sample data for the README PDF preview.
  // The running app never imports this file or replaces live device values with it.
  final logoBytes = await File('assets/images/smart_loop_logo.png')
      .readAsBytes();
  final report = AnalyticsReport(
    generatedAt: DateTime(2026, 9, 18),
    periodLabel: 'Demo - Sep 2026',
    thisMonthLiters: 12450.07,
    thisMonthCost: 1.25,
    lastMonthLiters: 14200,
    lastMonthCost: 1.42,
    yearlyLiters: 57150.07,
    yearlyCost: 6.26,
    dailyAverageLiters: 691.67,
    peakFlowRate: 3.42,
    totalDevices: 3,
    onlineDevices: 2,
    leakAlerts: 0,
    monthlyUsage: const [
      MonthlyUsage(month: 'September 2026', liters: 12450.07, cost: 1.25),
      MonthlyUsage(month: 'August 2026', liters: 14200, cost: 1.42),
      MonthlyUsage(month: 'July 2026', liters: 15600, cost: 2.10),
      MonthlyUsage(month: 'June 2026', liters: 14900, cost: 1.49),
    ],
    locationUsage: const [
      LocationUsage(name: 'Main Water Line', liters: 6199.50, cost: 0.62),
      LocationUsage(name: 'Garden', liters: 4100.32, cost: 0.41),
      LocationUsage(name: 'Kitchen', liters: 2150.25, cost: 0.22),
    ],
    devices: const [
      DeviceAnalytics(
        name: 'Main Water Line',
        location: 'Unassigned',
        status: 'Online',
        totalLiters: 6199.50,
        currentFlowRate: 3.42,
      ),
      DeviceAnalytics(
        name: 'Garden Irrigation',
        location: 'Garden',
        status: 'Online',
        totalLiters: 4100.32,
        currentFlowRate: 0,
      ),
      DeviceAnalytics(
        name: 'Kitchen Sink',
        location: 'Kitchen',
        status: 'Offline',
        totalLiters: 2150.25,
        currentFlowRate: 0,
      ),
    ],
  );
  final bytes = await PdfReportService.buildReport(
    report,
    logoBytes: logoBytes,
  );
  final outputDirectory = Directory('output/pdf');
  await outputDirectory.create(recursive: true);
  await File('${outputDirectory.path}/smart_loop_report_preview.pdf')
      .writeAsBytes(bytes);
}
