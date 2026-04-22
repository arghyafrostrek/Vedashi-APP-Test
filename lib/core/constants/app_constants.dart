import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Vedashi';
  static const String appTagline = 'Natural Wellness';
  static const String currency = '₹';
  static const String currencyCode = 'INR';
}

class AppColors {
  // Brand colors inspired by the Vedashi storefront (earthy green + warm tones)
  static const Color primary = Color(0xFF3B5D3B);
  static const Color primaryLight = Color(0xFF91CA35);
  static const Color primaryDark = Color(0xFF2A432A);
  static const Color accent = Color(0xFF91CA35);
  static const Color background = Color(0xFFF9FAF7);
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFF0F0F0);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF3F4F6);
  static const Color saleBadge = Color(0xFFEF4444);
  static const Color starYellow = Color(0xFFFBBF24);
}

class AppTextStyles {
  static const String fontFamily = 'Inter';

  static TextStyle heading1 = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle heading2 = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle heading3 = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyLarge = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle bodySmall = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static TextStyle price = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static TextStyle salePrice = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    decoration: TextDecoration.lineThrough,
  );

  static TextStyle button = const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
}
