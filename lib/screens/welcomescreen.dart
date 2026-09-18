import 'package:finalproject/core/constants/app_colors.dart';
import 'package:finalproject/extensions/app_extensions.dart';
import 'package:finalproject/screens/mainscreen.dart';
import 'package:finalproject/widgets/animated_water_drop_mark.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.primary),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned(
              top: -90,
              right: -75,
              child: _BackgroundOrb(size: 260, opacity: 0.10),
            ),
            const Positioned(
              top: 160,
              left: -85,
              child: _BackgroundOrb(size: 190, opacity: 0.06),
            ),
            const Positioned(
              bottom: -110,
              right: -80,
              child: _BackgroundOrb(size: 280, opacity: 0.07),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 52,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const Spacer(flex: 2),
                            const AnimatedWaterDropMark(size: 94),
                            const SizedBox(height: 12),
                            const Text(
                              'Smart loop',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 38,
                                height: 1.05,
                                letterSpacing: 0.2,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 440),
                              child: const Text(
                                'Track your home water loops, monitor live flow rates, and manage utility costs seamlessly in real-time.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  height: 1.55,
                                ),
                              ),
                            ),
                            const SizedBox(height: 27),
                            const _VerseText(),
                            const Spacer(flex: 3),
                            const SizedBox(height: 34),
                            _GetStartedButton(
                              onPressed: () =>
                                  context.pushScreen<void>(const MainScreen()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerseText extends StatelessWidget {
  const _VerseText();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Text(
              ':قال تعالى',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 7),
            Text(
              '﴿وَجَعَلْنَا مِنَ الْمَاءِ كُلَّ شَيْءٍ حَيٍّ﴾',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.primary,
            elevation: 12,
            shadowColor: const Color(0x5500133D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          onPressed: onPressed,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Get Started',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded, size: 21),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  const _BackgroundOrb({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
