import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/root_folder.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

class RootFoldersState {
  const RootFoldersState({
    this.folders = const [],
    this.activeFolderPath,
    this.isLoading = true,
  });

  final List<RootFolder> folders;
  final String? activeFolderPath;
  final bool isLoading;

  RootFoldersState copyWith({
    List<RootFolder>? folders,
    String? activeFolderPath,
    bool clearActive = false,
    bool? isLoading,
  }) {
    return RootFoldersState(
      folders: folders ?? this.folders,
      activeFolderPath: clearActive ? null : (activeFolderPath ?? this.activeFolderPath),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier responsabile di:
/// - caricare all'avvio le root folder salvate e quella attiva
/// - aggiungere/rimuovere root folder
/// - impostare la root folder attiva (quella da cui vengono caricati gli script)
///
/// Ogni modifica viene persistita immediatamente tramite [StorageService],
/// così che alla riapertura dell'app l'utente ritrovi le proprie cartelle.
class RootFoldersNotifier extends StateNotifier<RootFoldersState> {
  RootFoldersNotifier(this._storage) : super(const RootFoldersState()) {
    _init();
  }

  final StorageService _storage;

  Future<void> _init() async {
    final folders = await _storage.loadRootFolders();
    final active = await _storage.loadActiveFolder();
    final activeIsValid = active != null && folders.any((f) => f.path == active);

    state = RootFoldersState(
      folders: folders,
      activeFolderPath: activeIsValid ? active : null,
      isLoading: false,
    );
  }

  Future<void> addFolder(String path) async {
    if (state.folders.any((f) => f.path == path)) {
      await setActive(path);
      return;
    }

    final updated = [...state.folders, RootFolder(path)];
    state = state.copyWith(folders: updated);
    await _storage.saveRootFolders(updated);
    await setActive(path);
  }

  Future<void> removeFolder(String path) async {
    final updated = state.folders.where((f) => f.path != path).toList();
    final wasActive = state.activeFolderPath == path;

    state = state.copyWith(
      folders: updated,
      clearActive: wasActive,
    );
    await _storage.saveRootFolders(updated);

    if (wasActive) {
      await _storage.saveActiveFolder(null);
    }
  }

  Future<void> setActive(String path) async {
    state = state.copyWith(activeFolderPath: path);
    await _storage.saveActiveFolder(path);
  }
}

final rootFoldersProvider = StateNotifierProvider<RootFoldersNotifier, RootFoldersState>((ref) {
  return RootFoldersNotifier(ref.watch(storageServiceProvider));
});
