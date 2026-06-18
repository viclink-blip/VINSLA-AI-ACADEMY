import 'package:flutter/material.dart';

/// Vinsla AI Academy Design System — Color Tokens
class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────
  static const Color brandNavy   = Color(0xFF0A0E27);
  static const Color brandPurple = Color(0xFF6C63FF);
  static const Color brandCyan   = Color(0xFF00D4FF);
  static const Color brandGold   = Color(0xFFFFD700);

  // ── Dark Theme ─────────────────────────────────────────
  static const Color darkBg        = Color(0xFF0A0E27);
  static const Color darkSurface   = Color(0xFF141829);
  static const Color darkCard      = Color(0xFF1E2340);
  static const Color darkBorder    = Color(0xFF2A2F52);
  static const Color darkText      = Color(0xFFF0F2FF);
  static const Color darkTextSub   = Color(0xFF8B92B8);

  // ── Light Theme ────────────────────────────────────────
  static const Color lightBg       = Color(0xFFF5F6FF);
  static const Color lightSurface  = Color(0xFFFFFFFF);
  static const Color lightCard     = Color(0xFFFFFFFF);
  static const Color lightBorder   = Color(0xFFE2E4F0);
  static const Color lightText     = Color(0xFF0A0E27);
  static const Color lightTextSub  = Color(0xFF6B7280);

  // ── Semantic ───────────────────────────────────────────
  static const Color success  = Color(0xFF10B981);
  static const Color warning  = Color(0xFFF59E0B);
  static const Color error    = Color(0xFFEF4444);
  static const Color info     = Color(0xFF3B82F6);

  // ── Course Category Colors ─────────────────────────────
  static const Color pythonColor = Color(0xFF3B82F6);   // blue
  static const Color aiColor     = Color(0xFF6C63FF);   // purple
  static const Color mlColor     = Color(0xFF10B981);   // green

  // ── Gradient Presets ──────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end:   Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end:   Alignment.bottomRight,
    colors: [Color(0xFF1E2340), Color(0xFF141829)],
  );

  static const LinearGradient pythonGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
  );

  static const LinearGradient aiGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFFEC4899)],
  );

  static const LinearGradient mlGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF3B82F6)],
  );
}
