enum ConsoleEntryStatus { running, success, error }

/// Rappresenta l'esecuzione di un comando, mostrata nella console di
/// destra in ordine cronologico.
class ConsoleEntry {
  const ConsoleEntry({
    required this.id,
    required this.timestamp,
    required this.scriptName,
    required this.command,
    this.output = const [],
    this.status = ConsoleEntryStatus.running,
    this.exitCode,
  });

  final String id;
  final DateTime timestamp;
  final String scriptName;
  final String command;
  final List<String> output;
  final ConsoleEntryStatus status;
  final int? exitCode;

  ConsoleEntry copyWith({
    List<String>? output,
    ConsoleEntryStatus? status,
    int? exitCode,
  }) {
    return ConsoleEntry(
      id: id,
      timestamp: timestamp,
      scriptName: scriptName,
      command: command,
      output: output ?? this.output,
      status: status ?? this.status,
      exitCode: exitCode ?? this.exitCode,
    );
  }
}
