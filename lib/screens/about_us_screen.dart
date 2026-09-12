import 'package:finalproject/core/constants/app_colors.dart';
import 'package:finalproject/widgets/gradient_app_bar.dart';
import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const GradientAppBar(
        title: 'About Us',
        automaticallyImplyLeading: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                gradient: AppGradients.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.water_drop_rounded,
                color: AppColors.white,
                size: 42,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'The Story Behind Smart Loop',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A simple idea for smarter water use.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 15),
          ),
          const SizedBox(height: 28),
          _AboutCard(
            icon: Icons.auto_stories_rounded,
            title: 'Our Story',
            child: Text(
              'Smart Loop started when Mohammed and Abdulilah noticed how difficult it was to understand where water was being used at home. A leak or an unusually high flow could continue unnoticed until the damage was done or the bill arrived. They needed a simple way to see each area clearly, but the available options felt complicated and disconnected.\n\nInstead of accepting the problem, they decided to build their own solution. They combined connected water devices, cloud data, and a simple mobile experience. That idea became Smart Loop: an app designed to help households understand their water use and respond earlier when something does not look right.',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _AboutCard(
            icon: Icons.track_changes_rounded,
            title: 'Our Mission',
            child: Text(
              'To make water monitoring clear, accessible, and useful by connecting every device and location in one simple experience.',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Founded by Mohammed & Abdulilah',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryAccent.withValues(alpha: 0.75),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryAccent.withValues(alpha: 0.14),
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
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: AppColors.primaryAccent, size: 21),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
