import 'package:flutter/material.dart';

/// Punto unico di verità per i colori "brand" dell'applicazione.
///
/// Per cambiare la palette dell'intera app è sufficiente modificare
/// [seed]: [ColorScheme.fromSeed] genererà automaticamente tutte le
/// varianti (primary, secondary, surface, ecc.) sia per il tema chiaro
/// che per quello scuro.
class AppColors {
  const AppColors._();

  static const Color seed = Color(0xFF3A6EA5);

  // Colori semantici usati per lo stato dei comandi in console.
  static const Color statusRunning = Color(0xFFF39C12);
  static const Color statusSuccess = Color(0xFF2ECC71);
  static const Color statusError = Color(0xFFE74C3C);

  static const Color consoleBackground = Color(0xFF1E1E1E);
  static const Color consoleForeground = Color(0xFFF5F5F5);
}
