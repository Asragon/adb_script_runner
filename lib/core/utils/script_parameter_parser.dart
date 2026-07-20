/// Result of analyzing a script's parameters.
class ScriptParameterInfo {
  const ScriptParameterInfo({required this.count, required this.placeholders});

  /// Number of positional parameters found (e.g. 2 if it finds $1 and $2).
  final int count;

  /// Human-readable placeholder labels, e.g. ["\$1", "\$2"].
  final List<String> placeholders;

  static const empty = ScriptParameterInfo(count: 0, placeholders: []);
}

/// Analyzes a script's text content to detect the positional parameters
/// it requires, both in bash style (`$1`, `${2}`) and in batch/Windows
/// style (`%1`, `%2`).
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
