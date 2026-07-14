/// Rappresenta un singolo script individuato all'interno di una root folder.
class ScriptModel {
  const ScriptModel({
    required this.name,
    required this.path,
    required this.groupName,
    required this.parameterCount,
    required this.parameterPlaceholders,
    required this.body,
  });

  /// Nome del file, es. "reboot_device.sh".
  final String name;

  final String body;

  /// Percorso assoluto sul filesystem.
  final String path;

  /// Nome della sottocartella di appartenenza. Stringa vuota se lo
  /// script si trova direttamente nella root folder.
  final String groupName;

  /// Numero di parametri posizionali richiesti (0 se nessuno).
  final int parameterCount;

  /// Etichette dei parametri, es. ["\$1", "\$2"].
  final List<String> parameterPlaceholders;

  bool get hasParameters => parameterCount > 0;
}
