import 'package:finalproject/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class WaterDropMark extends StatelessWidget {
  const WaterDropMark({this.size = 94, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 76 / 64,
      child: const CustomPaint(painter: _WaterDropMarkPainter()),
    );
  }
}

class _WaterDropMarkPainter extends CustomPainter {
  const _WaterDropMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 64, size.height / 76);

    final outerDrop = Path()
      ..moveTo(32, 2)
      ..cubicTo(26, 13, 10, 30, 10, 45)
      ..cubicTo(10, 58, 20, 69, 32, 69)
      ..cubicTo(44, 69, 54, 58, 54, 45)
      ..cubicTo(54, 30, 38, 13, 32, 2)
      ..close();

    canvas.drawShadow(outerDrop, const Color(0x3300133D), 7, false);
    canvas.drawPath(outerDrop, Paint()..color = AppColors.white);

    final innerDrop = Path()
      ..moveTo(24, 47)
      ..cubicTo(26, 54, 31, 58, 38, 59)
      ..cubicTo(35, 62, 31, 64, 26, 63)
      ..cubicTo(19, 61, 15, 54, 16, 47)
      ..cubicTo(17, 43, 19, 39, 22, 35)
      ..cubicTo(21, 40, 22, 44, 24, 47)
      ..close();

    canvas.drawPath(innerDrop, Paint()..color = AppColors.secondary);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
