import 'dart:io';

import 'package:path/path.dart' as p;

import '../core/constants/app_constants.dart';
import '../core/utils/script_parameter_parser.dart';
import '../models/script_group.dart';
import '../models/script_model.dart';

/// Scans a root folder and derives the list of [ScriptGroup] from it:
/// - each immediate subfolder becomes a group (name = folder name)
/// - scripts found directly in the root form the "General" group
///   (represented with an empty [ScriptGroup.name]; localizing the
///   label is the UI's responsibility)
class ScriptScannerService {
  Future<List<ScriptGroup>> scanRoot(String rootPath) async {
    final rootDir = Directory(rootPath);
    if (!await rootDir.exists()) return const [];

    final groups = <ScriptGroup>[];
    final rootScripts = <ScriptModel>[];

    final entries = rootDir.listSync(followLinks: false);

    for (final entry in entries) {
      if (entry is Directory) {
        final scripts = await _scanScriptsInDir(entry, p.basename(entry.path));
        if (scripts.isNotEmpty) {
          groups.add(
            ScriptGroup(
              name: p.basename(entry.path),
              path: entry.path,
              scripts: scripts,
            ),
          );
        }
      } else if (entry is File) {
        if (_isScript(entry.path)) {
          rootScripts.add(await _buildScriptModel(entry, ''));
        }
      }
    }

    groups.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    if (rootScripts.isNotEmpty) {
      rootScripts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      groups.insert(0, ScriptGroup(name: '', path: rootPath, scripts: rootScripts));
    }

    return groups;
  }

  bool _isScript(String path) =>
      AppConstants.scriptExtensions.contains(p.extension(path).toLowerCase());

  Future<List<ScriptModel>> _scanScriptsInDir(Directory dir, String groupName) async {
    final scripts = <ScriptModel>[];
    final entries = dir.listSync(followLinks: false);

    for (final entry in entries) {
      if (entry is File && _isScript(entry.path)) {
        scripts.add(await _buildScriptModel(entry, groupName));
      }
    }

    scripts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return scripts;
  }

  Future<ScriptModel> _buildScriptModel(File file, String groupName) async {
    String content = '';
    try {
      content = await file.readAsString();
    } catch (_) {
      // Binary file or not readable as text: no parameter detectable.
      content = '';
    }

    final info = ScriptParameterParser.parse(content);

    return ScriptModel(
      name: p.basename(file.path),
      path: file.path,
      groupName: groupName,
      parameterCount: info.count,
      parameterPlaceholders: info.placeholders,
      body: content,
    );
  }
}
