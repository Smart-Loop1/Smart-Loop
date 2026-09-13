import 'package:finalproject/core/constants/app_colors.dart';
import 'package:finalproject/core/state/app_data_scope.dart';
import 'package:finalproject/models/waterloop.dart';
import 'package:finalproject/widgets/gradient_app_bar.dart';
import 'package:flutter/material.dart';

class LoopDashboardScreen extends StatelessWidget {
  const LoopDashboardScreen({required this.loop, super.key});

  final WaterLoop loop;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentLoop = AppDataScope.of(context).deviceById(loop.id) ?? loop;
    final flowRate = currentLoop.currentFlowRate;
    final totalLiters = currentLoop.totalLiters;
    final flowRateText = flowRate == null
        ? '-- L / min'
        : '${flowRate.toStringAsFixed(1)} L / min';
    final totalLitersText = totalLiters == null
        ? '-- L'
        : '${totalLiters.toStringAsFixed(1)} L';

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
                const Expanded(
                  child: _InfoCard(
                    title: 'Est. Cost',
                    value: '-- SAR',
                    icon: Icons.receipt_long_rounded,
                    accentColor: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              'System Status & Alerts',
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
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_sync_rounded,
              color: AppColors.primaryAccent,
              size: 26,
            ),
          ),
          title: Text(
            loop.status == 'online'
                ? 'Device connected'
                : loop.status == 'off'
                ? 'System switched off'
                : 'Waiting for device status',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            loop.lastSeen == null
                ? 'System alerts will appear when cloud data is received.'
                : 'Live readings received from ${loop.id}.',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
          ),
        ),
      ),
    );
  }
}
