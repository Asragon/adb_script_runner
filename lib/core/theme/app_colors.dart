import 'package:flutter/material.dart';

/// Single source of truth for the application's "brand" colors.
///
/// To change the palette of the whole app, just modify [seed]:
/// [ColorScheme.fromSeed] will automatically generate all the variants
/// (primary, secondary, surface, etc.) for both the light and dark
/// theme.
class AppColors {
  const AppColors._();

  static const Color seed = Color(0xFF3A6EA5);

  // Semantic colors used for command status in the console.
  static const Color statusRunning = Color(0xFFF39C12);
  static const Color statusSuccess = Color(0xFF2ECC71);
  static const Color statusError = Color(0xFFE74C3C);

  static const Color consoleBackground = Color(0xFF1E1E1E);
  static const Color consoleForeground = Color(0xFFF5F5F5);
}
