import 'package:finalproject/core/constants/app_colors.dart';
import 'package:finalproject/core/state/app_data_scope.dart';
import 'package:finalproject/core/utils/saudi_residential_water_tariff.dart';
import 'package:finalproject/extensions/water_loop_extensions.dart';
import 'package:finalproject/models/waterloop.dart';
import 'package:finalproject/widgets/device_status_badge.dart';
import 'package:finalproject/widgets/gradient_app_bar.dart';
import 'package:flutter/material.dart';

class LoopDashboardScreen extends StatelessWidget {
  const LoopDashboardScreen({required this.loop, super.key});

  final WaterLoop loop;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentLoop = AppDataScope.of(context).deviceById(loop.id) ?? loop;
    final flowRate = currentLoop.isOnline
        ? currentLoop.currentFlowRate ?? 0.0
        : 0.0;
    final totalLiters = currentLoop.totalLiters ?? 0.0;
    final estimatedCost = SaudiResidentialWaterTariff.estimateWaterCost(
      totalLiters,
    );
    final estimatedCostText = estimatedCost < 0.01
        ? '${estimatedCost.toStringAsFixed(5)} SAR'
        : '${estimatedCost.toStringAsFixed(2)} SAR';
    final flowRateText = '${flowRate.toStringAsFixed(2)} L / min';
    final totalLitersText = '${totalLiters.toStringAsFixed(2)} L';

    return Scaffold(
      appBar: GradientAppBar(
        title: currentLoop.name,
        gradient: AppGradients.flow,
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FlowRateCard(value: flowRateText),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    title: 'Total Consumed',
                    value: totalLitersText,
                    icon: Icons.analytics_outlined,
                    accentColor: AppColors.primaryAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _InfoCard(
                    title: 'Est. Cost',
                    value: estimatedCostText,
                    icon: Icons.receipt_long_rounded,
                    accentColor: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Residential water tariff only · excludes wastewater, VAT, and meter fees.',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Device Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _SystemStatusCard(loop: currentLoop),
          ],
        ),
      ),
    );
  }
}

class _FlowRateCard extends StatelessWidget {
  const _FlowRateCard({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.flow,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.analyticsShadow,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.welcomeIconBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.waves_rounded,
              size: 40,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Current Flow Rate',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemStatusCard extends StatelessWidget {
  const _SystemStatusCard({required this.loop});

  final WaterLoop loop;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = loop.isOnline
        ? AppColors.deviceOnline
        : AppColors.deviceOffline;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  loop.isOnline
                      ? Icons.cloud_done_rounded
                      : Icons.cloud_off_rounded,
                  color: statusColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DeviceStatusBadge(device: loop),
                    const SizedBox(height: 8),
                    Text(
                      loop.lastReadingLabel,
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
        ),
      ),
    );
  }
}
