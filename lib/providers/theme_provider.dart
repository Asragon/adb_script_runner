import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../services/storage_service.dart';
import 'root_folders_provider.dart' show storageServiceProvider;

/// Current theme mode of the app. Settable globally from anywhere in
/// the UI (see the button in [HomeScreen]). Persisted via
/// [StorageService] so it survives app restarts.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._storage) : super(ThemeMode.system) {
    _init();
  }

  final StorageService _storage;

  Future<void> _init() async {
    final saved = await _storage.loadThemeMode();
    if (saved != null) state = saved;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await _storage.saveThemeMode(mode);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(storageServiceProvider));
});

/// Current seed color driving the app's whole color scheme (see
/// [AppColors] and the color dots in [HomeScreen]'s app bar). Persisted
/// via [StorageService] so it survives app restarts.
class SeedColorNotifier extends StateNotifier<Color> {
  SeedColorNotifier(this._storage) : super(AppColors.seed) {
    _init();
  }

  final StorageService _storage;

  Future<void> _init() async {
    final saved = await _storage.loadSeedColor();
    if (saved != null) state = saved;
  }

  Future<void> set(Color color) async {
    state = color;
    await _storage.saveSeedColor(color);
  }
}

final seedColorProvider = StateNotifierProvider<SeedColorNotifier, Color>((ref) {
  return SeedColorNotifier(ref.watch(storageServiceProvider));
});
