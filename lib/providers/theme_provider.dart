import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modalità tema corrente dell'app. Impostabile globalmente da qualsiasi
/// punto della UI (vedi il bottone in [HomeScreen]).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
