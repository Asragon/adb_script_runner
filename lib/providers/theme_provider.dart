import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current theme mode of the app. Settable globally from anywhere in
/// the UI (see the button in [HomeScreen]).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
