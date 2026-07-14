import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/console_entry.dart';

/// Gestisce lo storico cronologico dei comandi eseguiti, mostrato nella
/// console a destra.
class ConsoleNotifier extends StateNotifier<List<ConsoleEntry>> {
  ConsoleNotifier() : super(const []);

  /// Crea una nuova voce con stato "running" e la restituisce (id) così
  /// da poterla aggiornare mentre il processo produce output.
  String startEntry({required String scriptName, required String command}) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    state = [
      ...state,
      ConsoleEntry(
        id: id,
        timestamp: DateTime.now(),
        scriptName: scriptName,
        command: command,
      ),
    ];
    return id;
  }

  void appendOutput(String id, String line) {
    state = [
      for (final entry in state)
        if (entry.id == id) entry.copyWith(output: [...entry.output, line]) else entry,
    ];
  }

  void finish(String id, {required int exitCode}) {
    state = [
      for (final entry in state)
        if (entry.id == id)
          entry.copyWith(
            status: exitCode == 0 ? ConsoleEntryStatus.success : ConsoleEntryStatus.error,
            exitCode: exitCode,
          )
        else
          entry,
    ];
  }

  void clear() => state = const [];
}

final consoleProvider = StateNotifierProvider<ConsoleNotifier, List<ConsoleEntry>>(
  (ref) => ConsoleNotifier(),
);
