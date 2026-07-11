import 'package:flutter/cupertino.dart';

class AppColors {
  // Primary brand
  static const Color primary = Color(0xFFF08010);
  static const Color primaryLight = Color(0xFFFFB347);
  static const Color primaryDark = Color(0xFFC06000);
  static const Color primaryColor = Color.fromARGB(255, 240, 128, 16);

  // Accent
  static const Color accent = Color(0xFF6366F1);
  static const Color accentLight = Color(0xFF818CF8);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFCA5A5);
  static const Color info = Color(0xFF3B82F6);

  // Expenses module
  static const Color expensePrimary = Color(0xFFEC4899);
  static const Color expenseSecondary = Color(0xFFF472B6);

  // Gradients
  static const List<Color> primaryGradient = [Color(0xFFF08010), Color(0xFFFFB347)];
  static const List<Color> earningsGradient = [Color(0xFF6366F1), Color(0xFF8B5CF6)];
  static const List<Color> collectedGradient = [Color(0xFF10B981), Color(0xFF34D399)];
  static const List<Color> pendingGradient = [Color(0xFFF59E0B), Color(0xFFFBBF24)];
  static const List<Color> expenseGradient = [Color(0xFFEC4899), Color(0xFFF472B6)];
  static const List<Color> drawerGradient = [Color(0xFF1E293B), Color(0xFF334155)];

  // Surfaces (light)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF8FAFC);
  static const Color cardBorder = Color(0xFFE2E8F0);

  // Surfaces (dark)
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color surfaceDarkAlt = Color(0xFF2C2C2E);
  static const Color cardBorderDark = Color(0xFF3A3A3C);

  // Category palette (for expense categories)
  static const List<Color> categoryPalette = [
    Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899),
    Color(0xFFEF4444), Color(0xFFF59E0B), Color(0xFF10B981),
    Color(0xFF14B8A6), Color(0xFF3B82F6), Color(0xFF06B6D4),
    Color(0xFF84CC16), Color(0xFFF97316), Color(0xFF64748B),
  ];

  static Color shadowColor(Color base, {double alpha = 0.15}) =>
      base.withValues(alpha: alpha);
}

