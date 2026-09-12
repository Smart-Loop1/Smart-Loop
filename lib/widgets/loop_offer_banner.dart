import 'package:finalproject/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class LoopOfferBanner extends StatelessWidget {
  const LoopOfferBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.analyticsShadow,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OfferBadge(),
                SizedBox(height: 12),
                Text(
                  'Buy 2 Loops\nGet 1 FREE',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 23,
                    height: 1.12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 9),
                Text(
                  'Complete your home with smarter water monitoring.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Only 299 SAR',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const _ProductImagePlaceholder(),
        ],
      ),
    );
  }
}

class _OfferBadge extends StatelessWidget {
  const _OfferBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.28)),
      ),
      child: const Text(
        'LIMITED-TIME OFFER',
        style: TextStyle(
          color: AppColors.white,
          fontSize: 9,
          letterSpacing: 0.7,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  const _ProductImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    // Replace this placeholder with Image.asset when the product image is ready.
    return Container(
      width: 96,
      height: 138,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.3)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined, color: Colors.white70),
          SizedBox(height: 7),
          Text(
            'Product\nimage',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.2),
          ),
        ],
      ),
    );
  }
}
