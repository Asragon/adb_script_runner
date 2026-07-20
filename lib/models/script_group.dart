import 'script_model.dart';

/// Represents a group of scripts, corresponding to a subfolder of the
/// selected root folder. [name] is empty for scripts that sit directly
/// in the root (the "General" group).
class ScriptGroup {
  const ScriptGroup({
    required this.name,
    required this.path,
    required this.scripts,
  });

  final String name;
  final String path;
  final List<ScriptModel> scripts;
}
