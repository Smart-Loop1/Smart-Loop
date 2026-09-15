import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF0D47A1);
  static const secondary = Color(0xFF42A5F5);
  static const primaryAccent = Color(0xFF1976D2);
  static const textPrimary = Color(0xFF2D3142);
  static const white = Colors.white;
  static const darkBackground = Color(0xFF101418);
  static const darkSurface = Color(0xFF1A2027);
  static const welcomeIconBackground = Color(0x26FFFFFF);
  static const black = Color(0x14000000);
  static const analyticsShadow = Color(0x331976D2);
  static const cardShadow = Color(0x0F9E9E9E);
  static const deviceOnline = Color(0xFF239B68);
  static const deviceOffline = Color(0xFFD94B4B);
  static const goalWarning = Color(0xFFE5A000);
  static const goalNearLimit = Color(0xFFE97924);
}

abstract final class AppGradients {
  static const primary = LinearGradient(
    colors: [AppColors.primary, AppColors.secondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const analytics = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const flow = LinearGradient(
    colors: [AppColors.primaryAccent, AppColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
