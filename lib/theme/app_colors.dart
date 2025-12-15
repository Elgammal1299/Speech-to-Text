import 'package:flutter/material.dart';

/// نظام الألوان للتطبيق - يدعم الوضع الفاتح والداكن
class AppColors {
  // منع إنشاء instance من الكلاس
  AppColors._();

  // ========== الألوان الأساسية ==========

  /// اللون الأساسي للتطبيق
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  /// اللون الثانوي
  static const Color secondary = Color(0xFF03A9F4);
  static const Color secondaryDark = Color(0xFF0288D1);

  /// اللون المميز (Accent)
  static const Color accent = Color(0xFF00BCD4);

  // ========== ألوان النظام ==========

  /// ألوان النجاح والخطأ والتحذير
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // ========== ألوان التسجيل ==========

  /// لون التسجيل الصوتي
  static const Color recording = Color(0xFFE53935);
  static const Color recordingLight = Color(0xFFEF5350);

  // ========== الوضع الفاتح (Light Mode) ==========

  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);

  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightTextTertiary = Color(0xFF9E9E9E);

  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightBorder = Color(0xFFBDBDBD);

  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightCardShadow = Color(0x0D000000);

  // ========== الوضع الداكن (Dark Mode) ==========

  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);

  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextTertiary = Color(0xFF808080);

  static const Color darkDivider = Color(0xFF373737);
  static const Color darkBorder = Color(0xFF424242);

  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkCardShadow = Color(0x33000000);

  // ========== ألوان شفافة ==========

  static Color primaryWithOpacity(double opacity) => primary.withValues(alpha: opacity);
  static Color errorWithOpacity(double opacity) => error.withValues(alpha: opacity);
  static Color successWithOpacity(double opacity) => success.withValues(alpha: opacity);
  static Color warningWithOpacity(double opacity) => warning.withValues(alpha: opacity);

  // ========== Gradients ==========

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient recordingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [recording, recordingLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, secondary],
  );
}
