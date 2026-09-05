import 'package:flutter/material.dart';

/// Centralized application color palette matching LaundrySaaS web design
class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF0F172A);      // Slate 900
  static const Color primaryLight = Color(0xFF1E293B); // Slate 800
  static const Color accent = Color(0xFF0284C7);       // Sky 600
  static const Color accentLight = Color(0xFF38BDF8);  // Sky 400

  // Status Colors
  static const Color success = Color(0xFF10B981);      // Emerald 500
  static const Color successLight = Color(0xFFD1FAE5); // Emerald 100
  static const Color warning = Color(0xFFF59E0B);      // Amber 500
  static const Color warningLight = Color(0xFFFEF3C7); // Amber 100
  static const Color error = Color(0xFFEF4444);        // Rose 500
  static const Color errorLight = Color(0xFFFEE2E2);   // Rose 100
  static const Color info = Color(0xFF6366F1);         // Indigo 500
  static const Color infoLight = Color(0xFFE0E7FF);    // Indigo 100

  // Background & Surfaces
  static const Color background = Color(0xFFF8FAFC);   // Slate 50
  static const Color surface = Colors.white;
  static const Color cardBorder = Color(0xFFE2E8F0);   // Slate 200

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
}
