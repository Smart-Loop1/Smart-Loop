import 'package:finalproject/core/constants/app_colors.dart';
import 'package:finalproject/core/state/app_data_controller.dart';
import 'package:finalproject/core/state/app_data_scope.dart';
import 'package:finalproject/models/analytics_report.dart';
import 'package:finalproject/services/pdf_report_service.dart';
import 'package:finalproject/widgets/gradient_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appData = AppDataScope.of(context);
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    final thisMonthLiters = appData.usageForMonth(now.year, now.month);
    final lastMonthLiters = appData.usageForMonth(
      lastMonth.year,
      lastMonth.month,
    );
    final thisMonthCost = appData.estimatedCostForMonth(now.year, now.month);
    final lastMonthCost = appData.estimatedCostForMonth(
      lastMonth.year,
      lastMonth.month,
    );
    final yearlyLiters = appData.usageForYear(now.year);
    final yearlyCost = appData.estimatedCostForYear(now.year);
    final pastMonths = _buildMonthlyUsage(appData, now, count: 3, startAt: 1);

    return Scaffold(
      appBar: const GradientAppBar(
        title: 'Consumption Analytics',
        gradient: AppGradients.analytics,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparative Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ComparisonCard(
                    title: 'This Month',
                    liters: thisMonthLiters,
                    cost: thisMonthCost,
                    isCurrent: true,
                    icon: Icons.calendar_today_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ComparisonCard(
                    title: 'Last Month',
                    liters: lastMonthLiters,
                    cost: lastMonthCost,
                    icon: Icons.history_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _YearlyTotalCard(
              liters: yearlyLiters,
              cost: yearlyCost,
              year: now.year,
            ),
            const SizedBox(height: 30),
            Text(
              'Past Months Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _MonthlyUsageList(items: pastMonths),
            const SizedBox(height: 24),
            _PdfReportCard(onPressed: () => _generatePdfReport(context)),
          ],
        ),
      ),
    );
  }

  List<MonthlyUsage> _buildMonthlyUsage(
    AppDataController appData,
    DateTime anchor, {
    required int count,
    required int startAt,
  }) {
    return List.generate(count, (index) {
      final date = DateTime(anchor.year, anchor.month - startAt - index);
      final liters = appData.usageForMonth(date.year, date.month);
      return MonthlyUsage(
        month: _monthLabel(date),
        liters: liters,
        cost: appData.estimatedCostForMonth(date.year, date.month),
      );
    });
  }

  Future<void> _generatePdfReport(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Preparing your PDF report...')),
      );

    try {
      final appData = AppDataScope.read(context);
      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month - 1);
      final report = AnalyticsReport.fromDevices(
        locations: appData.locations,
        ungroupedDevices: appData.ungroupedDevices,
        thisMonthLiters: appData.usageForMonth(now.year, now.month),
        thisMonthCost: appData.estimatedCostForMonth(now.year, now.month),
        lastMonthLiters: appData.usageForMonth(lastMonth.year, lastMonth.month),
        lastMonthCost: appData.estimatedCostForMonth(
          lastMonth.year,
          lastMonth.month,
        ),
        yearlyLiters: appData.usageForYear(now.year),
        yearlyCost: appData.estimatedCostForYear(now.year),
        monthlyUsage: _buildMonthlyUsage(appData, now, count: 12, startAt: 0),
      );
      final logoData = await rootBundle.load(
        'assets/images/smart_loop_logo.png',
      );
      final bytes = await PdfReportService.buildReport(
        report,
        logoBytes: logoData.buffer.asUint8List(),
      );
      if (!context.mounted) return;

      messenger.hideCurrentSnackBar();
      final shared = await Printing.sharePdf(
        bytes: bytes,
        filename: 'smart_loop_water_report.pdf',
        subject: 'Smart Loop Water Analytics Report',
        body: 'Your Smart Loop water analytics report is attached.',
      );
      if (!shared && context.mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('The PDF could not be shared.')),
        );
      }
    } on Exception {
      if (!context.mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Could not generate the PDF report.')),
        );
    }
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({
    required this.title,
    required this.liters,
    required this.cost,
    required this.icon,
    this.isCurrent = false,
  });

  final String title;
  final double liters;
  final double cost;
  final IconData icon;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = isCurrent
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: isCurrent
            ? Border.all(color: colorScheme.primary, width: 1.5)
            : null,
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foregroundColor, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: isCurrent
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ' L',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCost(cost),
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _YearlyTotalCard extends StatelessWidget {
  const _YearlyTotalCard({
    required this.liters,
    required this.cost,
    required this.year,
  });

  final double liters;
  final double cost;
  final int year;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppGradients.analytics,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.analyticsShadow,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Yearly Total ()',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.insights_rounded, color: Colors.white, size: 24),
            ],
          ),
          SizedBox(height: 12),
          Text(
            ' Liters',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Estimated Yearly Cost: ',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _MonthlyUsageList extends StatelessWidget {
  const _MonthlyUsageList({required this.items});

  final List<MonthlyUsage> items;

  @override
  Widget build(BuildContext context) {
    const colors = [
      AppColors.primaryAccent,
      AppColors.primary,
      AppColors.secondary,
    ];

    return Column(
      children: [
        for (var index = 0; index < items.length; index++)
          _MonthlyUsageTile(
            item: items[index],
            color: colors[index % colors.length],
          ),
      ],
    );
  }
}

class _MonthlyUsageTile extends StatelessWidget {
  const _MonthlyUsageTile({required this.item, required this.color});

  final MonthlyUsage item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.date_range_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item.month,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.liters.toStringAsFixed(2)} L',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatCost(item.cost ?? 0),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PdfReportCard extends StatelessWidget {
  const _PdfReportCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryAccent.withValues(alpha: 0.18),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: AppColors.primaryAccent,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PDF Report',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create a printable consumption summary.',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.analytics,
                borderRadius: BorderRadius.circular(14),
              ),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onPressed,
                icon: const Icon(Icons.download_rounded),
                label: const Text(
                  'Generate PDF Report',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatCost(double value) {
  final decimals = value.abs() < 0.01 ? 5 : 2;
  return '${value.toStringAsFixed(decimals)} SAR';
}

String _monthLabel(DateTime value) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[value.month - 1]} ${value.year}';
}
