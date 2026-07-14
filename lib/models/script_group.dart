import 'script_model.dart';

/// Rappresenta un gruppo di script, corrispondente a una sottocartella
/// della root folder selezionata. [name] è vuoto per gli script che si
/// trovano direttamente nella root (gruppo "Generale").
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
