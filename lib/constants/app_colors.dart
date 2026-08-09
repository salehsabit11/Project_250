import 'package:flutter/material.dart';

/// Centralized color definitions used throughout the app.
/// Change colors here to update the entire application's theme.
class AppColors {
  AppColors._();

  // ===========================
  // Primary Colors
  // ===========================

  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF5E92F3);
  static const Color primaryDark = Color(0xFF003C8F);

  // ===========================
  // Secondary
  // ===========================

  static const Color secondary = Color(0xFF26A69A);

  // ===========================
  // Background
  // ===========================

  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;

  // ===========================
  // Text
  // ===========================

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color hint = Color(0xFF9E9E9E);

  // ===========================
  // Status Colors
  // ===========================

  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFF9A825);

  // ===========================
  // Attendance
  // ===========================

  static const Color present = Color(0xFF43A047);
  static const Color absent = Color(0xFFE53935);
  static const Color late = Color(0xFFFB8C00);

  // ===========================
  // Others
  // ===========================

  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
}