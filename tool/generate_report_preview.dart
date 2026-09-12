import 'dart:io';

import 'package:finalproject/models/analytics_report.dart';
import 'package:finalproject/services/pdf_report_service.dart';

Future<void> main() async {
  final logoBytes = await File('assets/images/smart_loop_logo.png')
      .readAsBytes();
  final bytes = await PdfReportService.buildReport(
    AnalyticsReport.awaitingCloudData(),
    logoBytes: logoBytes,
  );
  final outputDirectory = Directory('output/pdf');
  await outputDirectory.create(recursive: true);
  await File('${outputDirectory.path}/smart_loop_report_preview.pdf')
      .writeAsBytes(bytes);
}
