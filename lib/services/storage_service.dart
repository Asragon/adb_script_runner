import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/root_folder.dart';

/// Handles local persistence (via [SharedPreferences]) of the root
/// folder paths chosen by the user, so they're still available when the
/// app is reopened.
///
/// Note: for the sole purpose of saving a list of paths,
/// [SharedPreferences] is sufficient and requires no extra native setup
/// on Windows/macOS. If in the future more complex data structures need
/// persisting (e.g. per-script metadata, execution history), it can be
/// migrated to a local database like Hive or Isar without impacting the
/// rest of the app, since this class is the sole access point for
/// persistence.
class StorageService {
  static const _rootFoldersKey = 'root_folders';
  static const _activeFolderKey = 'active_root_folder';
  static const _themeModeKey = 'theme_mode';
  static const _seedColorKey = 'seed_color';

  Future<List<RootFolder>> loadRootFolders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_rootFoldersKey) ?? const [];
    return raw.map(RootFolder.new).toList();
  }

  Future<void> saveRootFolders(List<RootFolder> folders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _rootFoldersKey,
      folders.map((f) => f.path).toList(),
    );
  }

  Future<String?> loadActiveFolder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeFolderKey);
  }

  Future<void> saveActiveFolder(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path == null) {
      await prefs.remove(_activeFolderKey);
    } else {
      await prefs.setString(_activeFolderKey, path);
    }
  }

  Future<ThemeMode?> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return switch (prefs.getString(_themeModeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => null,
    };
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  Future<Color?> loadSeedColor() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getInt(_seedColorKey);
    return raw == null ? null : Color(raw);
  }

  Future<void> saveSeedColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_seedColorKey, color.toARGB32());
  }
}
