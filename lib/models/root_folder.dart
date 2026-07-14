import 'package:path/path.dart' as p;

/// Rappresenta una cartella radice scelta dall'utente, contenente
/// sottocartelle/script ADB.
class RootFolder {
  const RootFolder(this.path);

  final String path;

  String get name => p.basename(path);

  @override
  bool operator ==(Object other) => other is RootFolder && other.path == path;

  @override
  int get hashCode => path.hashCode;
}
