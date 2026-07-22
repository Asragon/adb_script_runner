import 'dart:io';

import 'package:path/path.dart' as p;

/// Opens the OS file manager on the folder containing [filePath], selecting
/// the file when the platform supports it.
///
/// - Windows: `explorer /select,"<file>"` opens the folder and highlights it.
/// - macOS:   `open -R "<file>"` reveals it in Finder.
/// - Other:   falls back to opening the parent directory.
Future<void> revealInExplorer(String filePath) async {
  if (Platform.isWindows) {
    // explorer.exe needs Windows-style backslashes to select the file.
    final windowsPath = filePath.replaceAll('/', r'\');
    await Process.start('explorer', ['/select,$windowsPath']);
  } else if (Platform.isMacOS) {
    await Process.start('open', ['-R', filePath]);
  } else {
    await Process.start('xdg-open', [p.dirname(filePath)]);
  }
}
