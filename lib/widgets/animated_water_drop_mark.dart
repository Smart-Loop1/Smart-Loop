import 'dart:math' as math;

import 'package:finalproject/core/constants/app_colors.dart';
import 'package:finalproject/widgets/water_drop_mark.dart';
import 'package:flutter/material.dart';

class AnimatedWaterDropMark extends StatefulWidget {
  const AnimatedWaterDropMark({this.size = 94, super.key});

  final double size;

  @override
  State<AnimatedWaterDropMark> createState() => _AnimatedWaterDropMarkState();
}

class _AnimatedWaterDropMarkState extends State<AnimatedWaterDropMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return WaterDropMark(size: widget.size);
    }

    final stageSize = widget.size * 1.55;
    return SizedBox.square(
      dimension: stageSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;
          final logoReveal = const Interval(
            0.72,
            0.94,
            curve: Curves.easeOut,
          ).transform(progress);
          final sparkleProgress = const Interval(
            0.82,
            1,
            curve: Curves.easeInOut,
          ).transform(progress);
          final sparkleOpacity = math
              .sin(sparkleProgress * math.pi)
              .clamp(0.0, 1.0);

          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size.square(stageSize),
                painter: _FillingWaterDropPainter(
                  progress: progress,
                  dropWidth: widget.size,
                ),
              ),
              Opacity(
                opacity: logoReveal,
                child: Transform.scale(
                  scale: 0.94 + logoReveal * 0.06,
                  child: WaterDropMark(size: widget.size),
                ),
              ),
              if (sparkleOpacity > 0)
                Transform.translate(
                  offset: Offset(widget.size * 0.27, -widget.size * 0.36),
                  child: Opacity(
                    opacity: sparkleOpacity,
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.white,
                      size: widget.size * 0.17,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FillingWaterDropPainter extends CustomPainter {
  const _FillingWaterDropPainter({
    required this.progress,
    required this.dropWidth,
  });

  final double progress;
  final double dropWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final dropHeight = dropWidth * 76 / 64;
    canvas.save();
    canvas.translate(
      (size.width - dropWidth) / 2,
      (size.height - dropHeight) / 2,
    );
    canvas.scale(dropWidth / 64, dropHeight / 76);

    final dropPath = Path()
      ..moveTo(32, 2)
      ..cubicTo(26, 13, 10, 30, 10, 45)
      ..cubicTo(10, 58, 20, 69, 32, 69)
      ..cubicTo(44, 69, 54, 58, 54, 45)
      ..cubicTo(54, 30, 38, 13, 32, 2)
      ..close();

    final outlineProgress = const Interval(
      0,
      0.36,
      curve: Curves.easeInOutCubic,
    ).transform(progress);
    final outlinePaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final metric in dropPath.computeMetrics()) {
      canvas.drawPath(
        metric.extractPath(0, metric.length * outlineProgress),
        outlinePaint,
      );
    }

    final fillProgress = const Interval(
      0.24,
      0.78,
      curve: Curves.easeInOutCubic,
    ).transform(progress);
    if (fillProgress > 0) {
      canvas.save();
      canvas.clipPath(dropPath);

      final liquidY = 72 - fillProgress * 73;
      final wavePath = Path()..moveTo(5, liquidY);
      for (var x = 5.0; x <= 59; x += 1) {
        final wave = math.sin((x / 54 * math.pi * 2) + progress * math.pi * 8);
        wavePath.lineTo(x, liquidY + wave * 1.6);
      }
      wavePath
        ..lineTo(59, 76)
        ..lineTo(5, 76)
        ..close();

      final liquidPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEAF6FF), AppColors.white],
        ).createShader(const Rect.fromLTWH(5, 0, 54, 76));
      canvas.drawPath(wavePath, liquidPaint);

      final waveLine = Path()..moveTo(5, liquidY);
      for (var x = 5.0; x <= 59; x += 1) {
        final wave = math.sin((x / 54 * math.pi * 2) + progress * math.pi * 8);
        waveLine.lineTo(x, liquidY + wave * 1.6);
      }
      canvas.drawPath(
        waveLine,
        Paint()
          ..color = AppColors.secondary.withValues(alpha: 0.72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round,
      );

      final bubblePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = AppColors.secondary.withValues(
          alpha: (fillProgress * 0.55).clamp(0, 0.55),
        );
      for (var index = 0; index < 4; index++) {
        final bubbleProgress = (fillProgress + index * 0.21) % 1;
        final bubbleY = 68 - bubbleProgress * 36;
        final bubbleX = 20.0 + index * 8 + math.sin(progress * 8 + index) * 2;
        if (bubbleY > liquidY + 3) {
          canvas.drawCircle(
            Offset(bubbleX, bubbleY),
            1.1 + index * 0.28,
            bubblePaint,
          );
        }
      }

      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FillingWaterDropPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.dropWidth != dropWidth;
  }
}
