import 'package:flutter/material.dart';

/// ZenithTimer design-system color palette.
///
/// All UI components should reference these tokens instead of hard-coding
/// color literals, making global theme changes a one-file operation.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Brand / Primary
  // ---------------------------------------------------------------------------

  /// Deep violet — primary brand color and focus ring.
  static const Color primary = Color(0xFF6C63FF);

  /// Lighter tint used for highlights and secondary actions.
  static const Color primaryLight = Color(0xFF9D97FF);

  /// Muted accent used for progress arcs and Rive tints.
  static const Color accent = Color(0xFF00D9A3);

  // ---------------------------------------------------------------------------
  // Backgrounds
  // ---------------------------------------------------------------------------

  /// Fully transparent — used for Mode B (floating widget) scaffold.
  static const Color transparent = Color(0x00000000);

  /// Dark shell for Mode A (dynamic wallpaper) when no Rive animation is shown.
  static const Color wallpaperBackground = Color(0xFF0D0D1A);

  /// Widget card surface (glassmorphism base).
  static const Color surface = Color(0x26FFFFFF); // white 15 %

  /// Widget card border.
  static const Color surfaceBorder = Color(0x40FFFFFF); // white 25 %

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // white 70 %
  static const Color textMuted = Color(0x66FFFFFF); // white 40 %

  // ---------------------------------------------------------------------------
  // Timer states
  // ---------------------------------------------------------------------------

  /// Color of the progress arc during a work session.
  static const Color workSession = Color(0xFF6C63FF);

  /// Color of the progress arc during a short break.
  static const Color shortBreak = Color(0xFF00D9A3);

  /// Color of the progress arc during a long break.
  static const Color longBreak = Color(0xFFFF6B9D);

  /// "Session Complete" button gradient — start.
  static const Color completeGradientStart = Color(0xFF6C63FF);

  /// "Session Complete" button gradient — end.
  static const Color completeGradientEnd = Color(0xFF00D9A3);
}
