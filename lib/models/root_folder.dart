import 'package:path/path.dart' as p;

/// Represents a root folder chosen by the user, containing ADB
/// subfolders/scripts.
class RootFolder {
  const RootFolder(this.path);

  final String path;

  String get name => p.basename(path);

  @override
  bool operator ==(Object other) => other is RootFolder && other.path == path;

  @override
  int get hashCode => path.hashCode;
}
