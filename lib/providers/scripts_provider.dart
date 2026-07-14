import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/script_group.dart';
import '../services/script_scanner_service.dart';
import 'root_folders_provider.dart';

final scriptScannerServiceProvider = Provider<ScriptScannerService>((ref) => ScriptScannerService());

class ScriptsNotifier extends StateNotifier<AsyncValue<List<ScriptGroup>>> {
  ScriptsNotifier(
      this._scanner,
      String? rootPath,
      ) : super(const AsyncValue.loading()) {
    load(rootPath);
  }

  final ScriptScannerService _scanner;

  StreamSubscription<FileSystemEvent>? _subscription;

  Future<void> load(String? rootPath) async {
    await _subscription?.cancel();

    if (rootPath == null) {
      state = const AsyncValue.data([]);
      return;
    }

    await _scan(rootPath);

    _subscription = Directory(rootPath)
        .watch(recursive: true)
        .listen((_) {
      _scan(rootPath);
    });
  }

  Future<void> _scan(String rootPath) async {
    try {
      final groups = await _scanner.scanRoot(rootPath);
      state = AsyncValue.data(groups);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Ogni volta che cambia la root folder attiva, questo provider viene
/// ricreato e riesegue automaticamente la scansione della nuova cartella.
final scriptsProvider = StateNotifierProvider<ScriptsNotifier, AsyncValue<List<ScriptGroup>>>((ref) {
  final scanner = ref.watch(scriptScannerServiceProvider);
  final activePath = ref.watch(
    rootFoldersProvider.select(
          (state) => state.activeFolderPath,
    ),
  );

  return ScriptsNotifier(scanner, activePath);
});