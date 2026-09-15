import 'package:finalproject/core/constants/app_colors.dart';
import 'package:finalproject/core/state/app_data_controller.dart';
import 'package:finalproject/extensions/water_loop_extensions.dart';
import 'package:finalproject/models/daily_usage_goal.dart';
import 'package:flutter/material.dart';

class DailyUsageGoalCard extends StatelessWidget {
  const DailyUsageGoalCard({
    required this.appData,
    required this.onEdit,
    super.key,
  });

  final AppDataController appData;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final goal = appData.dailyGoal;
    final progress = appData.dailyGoalProgress;
    final devices = appData.allDevices;
    final hasOnlineDevice = devices.any((device) => device.isOnline);
    final isDisconnected = devices.isNotEmpty && !hasOnlineDevice;
    final accentColor = _progressColor(
      progress: progress,
      enabled: goal.enabled,
      disconnected: isDisconnected,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: goal.enabled
          ? _EnabledGoalContent(
              appData: appData,
              accentColor: accentColor,
              isDisconnected: isDisconnected,
              onEdit: onEdit,
            )
          : _EmptyGoalContent(onEdit: onEdit),
    );
  }

  Color _progressColor({
    required double progress,
    required bool enabled,
    required bool disconnected,
  }) {
    if (!enabled) return AppColors.primaryAccent;
    if (disconnected) return Colors.grey;
    if (progress >= 1) return AppColors.deviceOffline;
    if (progress >= 0.9) return AppColors.goalNearLimit;
    if (progress >= 0.7) return AppColors.goalWarning;
    return AppColors.primaryAccent;
  }
}

class _EnabledGoalContent extends StatelessWidget {
  const _EnabledGoalContent({
    required this.appData,
    required this.accentColor,
    required this.isDisconnected,
    required this.onEdit,
  });

  final AppDataController appData;
  final Color accentColor;
  final bool isDisconnected;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final goal = appData.dailyGoal;
    final progress = appData.dailyGoalProgress;
    final isMonthly = goal.period == UsageGoalPeriod.monthly;
    final percent = (progress * 100).clamp(0, 999).round();
    final currentValue = appData.dailyGoalCurrentValue;
    final remaining = (goal.limit - currentValue)
        .clamp(0, double.infinity)
        .toDouble();
    final exceededBy = (currentValue - goal.limit)
        .clamp(0, double.infinity)
        .toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                Icons.water_drop_outlined,
                color: accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMonthly ? "This Month's Water" : "Today's Water",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDisconnected
                        ? 'Devices offline - showing saved usage'
                        : isMonthly
                        ? 'Monthly household goal'
                        : 'Daily household goal',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: isMonthly ? 'Edit monthly goal' : 'Edit daily goal',
              onPressed: onEdit,
              icon: const Icon(Icons.tune_rounded),
              color: AppColors.primaryAccent,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatValue(currentValue, goal.unit),
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'of ${_formatValue(goal.limit, goal.unit)}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 70,
              height: 70,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: progress.clamp(0, 1),
                      strokeWidth: 7,
                      strokeCap: StrokeCap.round,
                      backgroundColor: accentColor.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 8,
            backgroundColor: accentColor.withValues(alpha: 0.10),
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(
              progress >= 1
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline_rounded,
              color: accentColor,
              size: 17,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                progress >= 1
                    ? '${isMonthly ? 'Monthly' : 'Daily'} limit exceeded by ${_formatValue(exceededBy, goal.unit)}'
                    : '${_formatValue(remaining, goal.unit)} remaining ${isMonthly ? 'this month' : 'today'}',
                style: TextStyle(
                  color: progress >= 1
                      ? accentColor
                      : colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: progress >= 1 ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        if (goal.unit == DailyGoalUnit.cost) ...[
          const SizedBox(height: 8),
          Text(
            'Estimated from the residential water tariff.',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10),
          ),
        ],
      ],
    );
  }
}

class _EmptyGoalContent extends StatelessWidget {
  const _EmptyGoalContent({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppColors.primaryAccent.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.track_changes_rounded,
            color: AppColors.primaryAccent,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set a Usage Goal',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose a daily or monthly liters or cost limit.',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        FilledButton(onPressed: onEdit, child: const Text('Set')),
      ],
    );
  }
}

String _formatValue(double value, DailyGoalUnit unit) {
  if (unit == DailyGoalUnit.liters) {
    return '${value.toStringAsFixed(2)} L';
  }
  final decimals = value.abs() < 0.01 ? 5 : 2;
  return '${value.toStringAsFixed(decimals)} SAR';
}
