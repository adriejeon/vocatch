/// 앱에서 사용하는 간격 상수들을 정의합니다.
class AppSpacing {
  // Private constructor to prevent instantiation
  AppSpacing._();

  // Base spacing unit (4px)
  static const double base = 4.0;

  // Spacing scale
  static const double xs = base; // 4px
  static const double sm = base * 2; // 8px
  static const double md = base * 3; // 12px
  static const double lg = base * 4; // 16px
  static const double xl = base * 5; // 20px
  static const double xxl = base * 6; // 24px
  static const double xxxl = base * 8; // 32px
  static const double huge = base * 10; // 40px
  static const double massive = base * 12; // 48px

  // Specific spacing for common use cases
  static const double paddingSmall = sm; // 8px
  static const double paddingMedium = lg; // 16px
  static const double paddingLarge = xxl; // 24px
  static const double paddingXLarge = xxxl; // 32px

  // Margin spacing
  static const double marginSmall = sm; // 8px
  static const double marginMedium = lg; // 16px
  static const double marginLarge = xxl; // 24px
  static const double marginXLarge = xxxl; // 32px

  // Gap spacing for flex layouts
  static const double gapSmall = sm; // 8px
  static const double gapMedium = lg; // 16px
  static const double gapLarge = xxl; // 24px
  static const double gapXLarge = xxxl; // 32px

  // Border radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusRound = 50.0;
}
