import 'dart:math' as math;
import 'dart:typed_data';

import 'package:finalproject/models/analytics_report.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

abstract final class PdfReportService {
  static final _primary = PdfColor.fromHex('#0D47A1');
  static final _secondary = PdfColor.fromHex('#42A5F5');
  static final _accent = PdfColor.fromHex('#1976D2');
  static final _ink = PdfColor.fromHex('#2D3142');
  static final _muted = PdfColor.fromHex('#6B7280');
  static final _surface = PdfColor.fromHex('#F6F9FD');
  static final _border = PdfColor.fromHex('#D9E7F7');
  static final _success = PdfColor.fromHex('#168A5B');
  static final _warning = PdfColor.fromHex('#D97706');

  static const _logoSvg = '''
<svg viewBox="0 0 64 76" xmlns="http://www.w3.org/2000/svg">
  <path fill="#FFFFFF" d="M32 2C26 13 10 30 10 45c0 13 10 24 22 24s22-11 22-24C54 30 38 13 32 2z"/>
  <path fill="#42A5F5" d="M24 47c2 7 7 11 14 12-3 3-7 5-12 4-7-2-11-9-10-16 1-4 3-8 6-12-1 5 0 9 2 12z"/>
</svg>
''';

  // Font Awesome Free 7.3.1 brand icons, licensed under CC BY 4.0.
  static const _tiktokSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512">
  <path fill="#FFFFFF" d="M448.5 209.9c-44 .1-87-13.6-122.8-39.2l0 178.7c0 33.1-10.1 65.4-29 92.6s-45.6 48-76.6 59.6-64.8 13.5-96.9 5.3-60.9-25.9-82.7-50.8-35.3-56-39-88.9 2.9-66.1 18.6-95.2 40-52.7 69.6-67.7 62.9-20.5 95.7-16l0 89.9c-15-4.7-31.1-4.6-46 .4s-27.9 14.6-37 27.3-14 28.1-13.9 43.9 5.2 31 14.5 43.7 22.4 22.1 37.4 26.9 31.1 4.8 46-.1 28-14.4 37.2-27.1 14.2-28.1 14.2-43.8l0-349.4 88 0c-.1 7.4 .6 14.9 1.9 22.2 3.1 16.3 9.4 31.9 18.7 45.7s21.3 25.6 35.2 34.6c19.9 13.1 43.2 20.1 67 20.1l0 87.4z"/>
</svg>
''';

  static const _xSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512">
  <path fill="#FFFFFF" d="M357.2 48L427.8 48 273.6 224.2 455 464 313 464 201.7 318.6 74.5 464 3.8 464 168.7 275.5-5.2 48 140.4 48 240.9 180.9 357.2 48zM332.4 421.8l39.1 0-252.4-333.8-42 0 255.3 333.8z"/>
</svg>
''';

  static const _instagramSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512">
  <path fill="#FFFFFF" d="M224.3 141a115 115 0 1 0-.6 230 115 115 0 1 0 .6-230zm-.6 40.4a74.6 74.6 0 1 1 .6 149.2 74.6 74.6 0 1 1-.6-149.2zm93.4-45.1a26.8 26.8 0 1 1 53.6 0 26.8 26.8 0 1 1-53.6 0zm129.7 27.2c-1.7-35.9-9.9-67.7-36.2-93.9-26.2-26.2-58-34.4-93.9-36.2-37-2.1-147.9-2.1-184.9 0-35.8 1.7-67.6 9.9-93.9 36.1s-34.4 58-36.2 93.9c-2.1 37-2.1 147.9 0 184.9 1.7 35.9 9.9 67.7 36.2 93.9s58 34.4 93.9 36.2c37 2.1 147.9 2.1 184.9 0 35.9-1.7 67.7-9.9 93.9-36.2 26.2-26.2 34.4-58 36.2-93.9 2.1-37 2.1-147.8 0-184.8zM399 388c-7.8 19.6-22.9 34.7-42.6 42.6-29.5 11.7-99.5 9-132.1 9s-102.7 2.6-132.1-9c-19.6-7.8-34.7-22.9-42.6-42.6-11.7-29.5-9-99.5-9-132.1s-2.6-102.7 9-132.1c7.8-19.6 22.9-34.7 42.6-42.6 29.5-11.7 99.5-9 132.1-9s102.7-2.6 132.1 9c19.6 7.8 34.7 22.9 42.6 42.6 11.7 29.5 9 99.5 9 132.1s2.7 102.7-9 132.1z"/>
</svg>
''';

  static Future<Uint8List> buildReport(
    AnalyticsReport report, {
    Uint8List? logoBytes,
  }) async {
    final logoImage = logoBytes == null ? null : pw.MemoryImage(logoBytes);
    final document = pw.Document(
      title: 'Smart Loop Water Analytics Report',
      author: 'Smart Loop',
      creator: 'Smart Loop',
      subject: 'Water consumption and device analytics',
      keywords: 'water, analytics, smart loop, consumption, devices',
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(30, 28, 30, 26),
        footer: _buildFooter,
        build: (context) => [
          _buildHero(report, logoImage),
          pw.SizedBox(height: 18),
          _buildReportMeta(report),
          pw.SizedBox(height: 22),
          _sectionTitle('Executive Summary'),
          pw.SizedBox(height: 10),
          pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _metricCard(
                label: 'THIS MONTH',
                value: _formatLiters(report.thisMonthLiters),
                detail: _formatCost(report.thisMonthCost),
              ),
              _metricCard(
                label: 'LAST MONTH',
                value: _formatLiters(report.lastMonthLiters),
                detail: _formatCost(report.lastMonthCost),
              ),
              _metricCard(
                label: 'YEARLY TOTAL',
                value: _formatLiters(report.yearlyLiters),
                detail: _formatCost(report.yearlyCost),
              ),
              _metricCard(
                label: 'DAILY AVERAGE',
                value: _formatLiters(report.dailyAverageLiters),
                detail: 'Average consumption',
              ),
              _metricCard(
                label: 'PEAK FLOW',
                value: _formatFlow(report.peakFlowRate),
                detail: 'Highest recorded flow',
              ),
              _metricCard(
                label: 'MONTHLY CHANGE',
                value: _formatPercent(report.monthlyChangePercent),
                detail: 'Compared with last month',
              ),
            ],
          ),
          pw.SizedBox(height: 22),
          _sectionTitle('Device Health'),
          pw.SizedBox(height: 10),
          _healthSummary(report),
          pw.NewPage(),
          _compactHeader('Consumption Details', report.periodLabel),
          pw.SizedBox(height: 20),
          _sectionTitle('Monthly Consumption Trend'),
          pw.SizedBox(height: 10),
          _monthlyChart(report.monthlyUsage),
          pw.SizedBox(height: 22),
          _sectionTitle('Monthly History'),
          pw.SizedBox(height: 10),
          _monthlyTable(report.monthlyUsage),
          pw.SizedBox(height: 22),
          _sectionTitle('Usage by Location'),
          pw.SizedBox(height: 10),
          _locationTable(report.locationUsage),
          pw.NewPage(),
          _compactHeader('Devices and Insights', report.periodLabel),
          pw.SizedBox(height: 20),
          _sectionTitle('Device Overview'),
          pw.SizedBox(height: 10),
          _deviceTable(report.devices),
          pw.SizedBox(height: 22),
          _sectionTitle('Alerts and Smart Insights'),
          pw.SizedBox(height: 10),
          _insightsCard(report),
          pw.SizedBox(height: 22),
          _cloudNote(),
          pw.SizedBox(height: 14),
          _contactCard(),
        ],
      ),
    );

    return document.save();
  }

  static pw.Widget _buildHero(
    AnalyticsReport report,
    pw.MemoryImage? logoImage,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(22),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [_primary, _secondary],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(18),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(
            width: 58,
            height: 58,
            padding: pw.EdgeInsets.all(logoImage == null ? 13 : 4),
            decoration: pw.BoxDecoration(
              color: const PdfColor(1, 1, 1, 0.16),
              borderRadius: pw.BorderRadius.circular(16),
            ),
            child: pw.Transform.translate(
              offset: const PdfPoint(0, 2),
              child: _brandLogo(logoImage),
            ),
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'SMART LOOP',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                    letterSpacing: 2.2,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Water Analytics Report',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Clear insights for smarter water decisions.',
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: pw.BoxDecoration(
              color: const PdfColor(1, 1, 1, 0.16),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Text(
              report.periodLabel,
              style: pw.TextStyle(
                color: _primary,
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildReportMeta(AnalyticsReport report) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _metaItem('REPORT STATUS', 'Waiting for cloud data'),
        _metaItem('GENERATED', _formatDate(report.generatedAt)),
        _metaItem('CURRENCY', 'SAR'),
      ],
    );
  }

  static pw.Widget _metaItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            color: _muted,
            fontSize: 7,
            letterSpacing: 0.8,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          value,
          style: pw.TextStyle(
            color: _ink,
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Row(
      children: [
        pw.Container(
          width: 4,
          height: 18,
          decoration: pw.BoxDecoration(
            color: _accent,
            borderRadius: pw.BorderRadius.circular(3),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Text(
          title,
          style: pw.TextStyle(
            color: _ink,
            fontSize: 15,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static pw.Widget _metricCard({
    required String label,
    required String value,
    required String detail,
  }) {
    return pw.Container(
      width: 165,
      padding: const pw.EdgeInsets.all(13),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: _border, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              color: _muted,
              fontSize: 7,
              letterSpacing: 0.7,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 7),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: _ink,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(detail, style: pw.TextStyle(color: _muted, fontSize: 8)),
        ],
      ),
    );
  }

  static pw.Widget _healthSummary(AnalyticsReport report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(color: _border),
      ),
      child: pw.Row(
        children: [
          _healthItem(
            'TOTAL DEVICES',
            _formatCount(report.totalDevices),
            _accent,
          ),
          _verticalDivider(),
          _healthItem('ONLINE', _formatCount(report.onlineDevices), _success),
          _verticalDivider(),
          _healthItem('OFFLINE', _formatCount(report.offlineDevices), _warning),
          _verticalDivider(),
          _healthItem('LEAK ALERTS', _formatCount(report.leakAlerts), _warning),
        ],
      ),
    );
  }

  static pw.Widget _healthItem(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            label,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              color: _muted,
              fontSize: 7,
              letterSpacing: 0.5,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _verticalDivider() {
    return pw.Container(width: 1, height: 34, color: _border);
  }

  static pw.Widget _compactHeader(String title, String period) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _border)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 30,
                height: 30,
                padding: const pw.EdgeInsets.all(7),
                decoration: pw.BoxDecoration(
                  color: _primary,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: _brandLogo(null),
              ),
              pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'SMART LOOP',
                    style: pw.TextStyle(
                      color: _accent,
                      fontSize: 7,
                      letterSpacing: 1.4,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      color: _ink,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.Text(period, style: pw.TextStyle(color: _muted, fontSize: 9)),
        ],
      ),
    );
  }

  static pw.Widget _monthlyChart(List<MonthlyUsage> months) {
    if (months.isEmpty) {
      return _emptyDataCard(
        'The monthly chart will be generated when cloud history is available.',
      );
    }

    final visibleMonths = months.length > 8
        ? months.sublist(months.length - 8)
        : months;
    final maximum = visibleMonths.fold<double>(
      0,
      (value, month) => math.max(value, month.liters),
    );

    return pw.Container(
      height: 176,
      padding: const pw.EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(color: _border),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: visibleMonths.map((month) {
          final height = maximum == 0 ? 10.0 : 92 * (month.liters / maximum);
          return pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 4),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    _compactNumber(month.liters),
                    style: pw.TextStyle(color: _muted, fontSize: 7),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Container(
                    height: math.max(10, height),
                    decoration: pw.BoxDecoration(
                      color: _accent,
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    month.month,
                    style: pw.TextStyle(color: _ink, fontSize: 7),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  static pw.Widget _monthlyTable(List<MonthlyUsage> months) {
    final rows = months.isEmpty
        ? <List<String>>[
            ['Waiting for cloud data', '--', '--'],
          ]
        : months
              .map(
                (month) => [
                  month.month,
                  _formatLiters(month.liters),
                  _formatCost(month.cost),
                ],
              )
              .toList();

    return _table(
      headers: const ['Month', 'Consumption', 'Estimated Cost'],
      rows: rows,
      columnWidths: const {
        0: pw.FlexColumnWidth(1.5),
        1: pw.FlexColumnWidth(),
        2: pw.FlexColumnWidth(),
      },
    );
  }

  static pw.Widget _locationTable(List<LocationUsage> locations) {
    final total = locations.fold<double>(
      0,
      (sum, item) => sum + (item.liters ?? 0),
    );
    final rows = locations.isEmpty
        ? <List<String>>[
            ['Waiting for cloud data', '--', '--', '--'],
          ]
        : locations.map((location) {
            final share = total == 0 || location.liters == null
                ? null
                : (location.liters! / total) * 100;
            return [
              location.name,
              _formatLiters(location.liters),
              _formatCost(location.cost),
              _formatPercent(share),
            ];
          }).toList();

    return _table(
      headers: const ['Location', 'Consumption', 'Estimated Cost', 'Share'],
      rows: rows,
      columnWidths: const {
        0: pw.FlexColumnWidth(1.5),
        1: pw.FlexColumnWidth(),
        2: pw.FlexColumnWidth(),
        3: pw.FlexColumnWidth(0.75),
      },
    );
  }

  static pw.Widget _deviceTable(List<DeviceAnalytics> devices) {
    final rows = devices.isEmpty
        ? <List<String>>[
            ['Waiting for cloud data', '--', '--', '--', '--'],
          ]
        : devices
              .map(
                (device) => [
                  device.name,
                  device.location,
                  device.status ?? '--',
                  _formatLiters(device.totalLiters),
                  _formatFlow(device.currentFlowRate),
                ],
              )
              .toList();

    return _table(
      headers: const ['Device', 'Location', 'Status', 'Usage', 'Flow Rate'],
      rows: rows,
      columnWidths: const {
        0: pw.FlexColumnWidth(1.35),
        1: pw.FlexColumnWidth(1.15),
        2: pw.FlexColumnWidth(0.8),
        3: pw.FlexColumnWidth(),
        4: pw.FlexColumnWidth(),
      },
    );
  }

  static pw.Widget _table({
    required List<String> headers,
    required List<List<String>> rows,
    required Map<int, pw.TableColumnWidth> columnWidths,
  }) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      columnWidths: columnWidths,
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(color: _border, width: 0.6),
        verticalInside: pw.BorderSide(color: _border, width: 0.4),
        bottom: pw.BorderSide(color: _border, width: 0.6),
      ),
      headerDecoration: pw.BoxDecoration(color: _primary),
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 8,
        fontWeight: pw.FontWeight.bold,
      ),
      headerAlignment: pw.Alignment.centerLeft,
      headerPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      cellStyle: pw.TextStyle(color: _ink, fontSize: 8),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      oddRowDecoration: pw.BoxDecoration(color: _surface),
      cellAlignments: const {
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _insightsCard(AnalyticsReport report) {
    final insights = <String>[];
    final change = report.monthlyChangePercent;
    if (change != null) {
      insights.add(
        change <= 0
            ? 'Monthly consumption improved by ${change.abs().toStringAsFixed(1)}%.'
            : 'Monthly consumption increased by ${change.toStringAsFixed(1)}%.',
      );
    }
    if (report.leakAlerts != null) {
      insights.add(
        report.leakAlerts == 0
            ? 'No leak alerts were recorded for this report period.'
            : '${report.leakAlerts} leak alert(s) require attention.',
      );
    }
    if (report.offlineDevices != null && report.offlineDevices! > 0) {
      insights.add('${report.offlineDevices} device(s) are currently offline.');
    }

    if (insights.isEmpty) {
      return _emptyDataCard(
        'Personalized alerts, consumption changes, and savings opportunities will appear when cloud data is received.',
      );
    }

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(color: _border),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: insights
            .map(
              (insight) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 6,
                      height: 6,
                      margin: const pw.EdgeInsets.only(top: 3),
                      decoration: pw.BoxDecoration(
                        color: _accent,
                        shape: pw.BoxShape.circle,
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: pw.Text(
                        insight,
                        style: pw.TextStyle(
                          color: _ink,
                          fontSize: 9,
                          lineSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  static pw.Widget _cloudNote() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(colors: [_primary, _accent]),
        borderRadius: pw.BorderRadius.circular(14),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Cloud-ready report',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Every placeholder in this report is ready to be replaced by live readings from your Smart Loop hardware and cloud platform.',
            style: const pw.TextStyle(
              color: PdfColors.white,
              fontSize: 9,
              lineSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _contactCard() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(color: _border),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'CONTACT SMART LOOP',
                style: pw.TextStyle(
                  color: _muted,
                  fontSize: 7,
                  letterSpacing: 0.8,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'SMARTLOOPS11@GMAIL.COM',
                style: pw.TextStyle(
                  color: _ink,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.Row(
            children: [
              _socialIcon(_tiktokSvg),
              pw.SizedBox(width: 5),
              _socialIcon(_xSvg),
              pw.SizedBox(width: 5),
              _socialIcon(_instagramSvg),
              pw.SizedBox(width: 8),
              pw.Text(
                '@smartl00ps',
                style: pw.TextStyle(
                  color: _primary,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _socialIcon(String svg) {
    return pw.Container(
      width: 24,
      height: 24,
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(
        color: _primary,
        borderRadius: pw.BorderRadius.circular(7),
      ),
      padding: const pw.EdgeInsets.all(6),
      child: pw.SvgImage(svg: svg),
    );
  }

  static pw.Widget _emptyDataCard(String message) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(color: _border),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            width: 32,
            height: 4,
            decoration: pw.BoxDecoration(
              color: _secondary,
              borderRadius: pw.BorderRadius.circular(4),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Waiting for cloud data',
            style: pw.TextStyle(
              color: _ink,
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            message,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(color: _muted, fontSize: 8, lineSpacing: 2),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _border, width: 0.6)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Smart Loop - Water Analytics Report',
            style: pw.TextStyle(color: _muted, fontSize: 7),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(color: _muted, fontSize: 7),
          ),
        ],
      ),
    );
  }

  static pw.Widget _brandLogo(pw.MemoryImage? logoImage) {
    if (logoImage != null) {
      return pw.Image(logoImage, fit: pw.BoxFit.contain);
    }
    return pw.SvgImage(svg: _logoSvg);
  }

  static String _formatLiters(double? value) {
    if (value == null) return '-- L';
    return '${_formatNumber(value, decimals: 2)} L';
  }

  static String _formatCost(double? value) {
    if (value == null) return '-- SAR';
    return '${_formatNumber(value, decimals: 2)} SAR';
  }

  static String _formatFlow(double? value) {
    if (value == null) return '-- L/min';
    return '${_formatNumber(value, decimals: 2)} L/min';
  }

  static String _formatPercent(double? value) {
    if (value == null) return '--%';
    final sign = value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)}%';
  }

  static String _formatCount(int? value) => value?.toString() ?? '--';

  static String _formatNumber(double value, {int decimals = 0}) {
    final fixed = value.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final digits = parts.first;
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(',');
      buffer.write(digits[index]);
    }
    if (parts.length > 1) buffer.write('.${parts.last}');
    return buffer.toString();
  }

  static String _compactNumber(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }

  static String _formatDate(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = value.day.toString().padLeft(2, '0');
    return '$day ${months[value.month - 1]} ${value.year}';
  }
}
