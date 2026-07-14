import 'package:shared_preferences/shared_preferences.dart';

import '../models/root_folder.dart';

/// Gestisce la persistenza locale (tramite [SharedPreferences]) dei
/// percorsi delle root folder scelte dall'utente, così che siano
/// disponibili anche alla riapertura dell'app.
///
/// Nota: per il solo scopo di salvare una lista di percorsi,
/// [SharedPreferences] è sufficiente e non richiede setup nativo
/// aggiuntivo su Windows/macOS. Se in futuro servisse persistere
/// strutture dati più complesse (es. metadati per script, storico
/// esecuzioni) si può migrare a un database locale come Hive o Isar
/// senza impattare il resto dell'app, dato che questa classe è l'unico
/// punto di accesso alla persistenza.
class StorageService {
  static const _rootFoldersKey = 'root_folders';
  static const _activeFolderKey = 'active_root_folder';

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
}
