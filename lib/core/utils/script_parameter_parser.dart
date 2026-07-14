/// Risultato dell'analisi dei parametri di uno script.
class ScriptParameterInfo {
  const ScriptParameterInfo({required this.count, required this.placeholders});

  /// Numero di parametri posizionali individuati (es. 2 se trova $1 e $2).
  final int count;

  /// Etichette leggibili dei placeholder, es. ["\$1", "\$2"].
  final List<String> placeholders;

  static const empty = ScriptParameterInfo(count: 0, placeholders: []);
}

/// Analizza il contenuto testuale di uno script per individuare i
/// parametri posizionali richiesti, sia in stile bash (`$1`, `${2}`)
/// sia in stile batch/Windows (`%1`, `%2`).
class ScriptParameterParser {
  const ScriptParameterParser._();

  static final RegExp _bashParam = RegExp(r'\$\{?([1-9])\}?');
  static final RegExp _batchParam = RegExp(r'%([1-9])(?!\d)');

  static ScriptParameterInfo parse(String content) {
    final indices = <int>{};

    for (final match in _bashParam.allMatches(content)) {
      indices.add(int.parse(match.group(1)!));
    }
    for (final match in _batchParam.allMatches(content)) {
      indices.add(int.parse(match.group(1)!));
    }

    if (indices.isEmpty) return ScriptParameterInfo.empty;

    final maxIndex = indices.reduce((a, b) => a > b ? a : b);
    final placeholders = List.generate(maxIndex, (i) => '\$${i + 1}');

    return ScriptParameterInfo(count: maxIndex, placeholders: placeholders);
  }
}
