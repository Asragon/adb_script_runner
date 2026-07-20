/// Represents a single script found inside a root folder.
class ScriptModel {
  const ScriptModel({
    required this.name,
    required this.path,
    required this.groupName,
    required this.parameterCount,
    required this.parameterPlaceholders,
    required this.body,
  });

  /// File name, e.g. "reboot_device.sh".
  final String name;

  final String body;

  /// Absolute path on the filesystem.
  final String path;

  /// Name of the subfolder it belongs to. Empty string if the script
  /// sits directly in the root folder.
  final String groupName;

  /// Number of positional parameters required (0 if none).
  final int parameterCount;

  /// Parameter labels, e.g. ["\$1", "\$2"].
  final List<String> parameterPlaceholders;

  bool get hasParameters => parameterCount > 0;
}
