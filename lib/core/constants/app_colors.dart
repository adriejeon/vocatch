import 'package:flutter/material.dart';

/// 앱에서 사용하는 색상 상수들을 정의합니다.
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Color
  static const Color primary = Color(0xFF3182F7);

  // Grey Scale
  static const Color grey100 = Color(0xFF191F28);
  static const Color grey90 = Color(0xFF333D4B);
  static const Color grey80 = Color(0xFF4E5968);
  static const Color grey70 = Color(0xFF6B7684);
  static const Color grey60 = Color(0xFF8B95A1);
  static const Color grey50 = Color(0xFFB0B8C1);
  static const Color grey40 = Color(0xFFD1D6DB);
  static const Color grey30 = Color(0xFFE5E8EB);
  static const Color grey20 = Color(0xFFF2F4F6);
  static const Color grey10 = Color(0xFFF9FAFB);
  static const Color grey00 = Color(0xFFFFFFFF);

  // Semantic Colors
  static const Color background = grey00;
  static const Color textPrimary = grey90;
  static const Color textSecondary = grey70;
  static const Color textTertiary = grey60;
  
  // Surface Colors
  static const Color surface = grey00;
  static const Color surfaceVariant = grey10;
  static const Color surfaceContainer = grey20;
  
  // Border Colors
  static const Color border = grey30;
  static const Color borderFocus = primary;
  
  // Status Colors
  static const Color success = Color(0xFF00C851);
  static const Color warning = Color(0xFFFF8800);
  static const Color error = Color(0xFFFF4444);
  static const Color info = primary;
}
