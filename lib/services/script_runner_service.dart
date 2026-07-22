import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/script_model.dart';

/// Runs a script as an external process, picking the correct
/// interpreter based on the file extension:
/// - `.sh`   -> bash (requires bash.exe on PATH, e.g. Git Bash or WSL)
/// - `.ps1`  -> powershell
/// - `.bat`/`.cmd` -> cmd
///
/// Parameters are passed as positional arguments to the script (`$1`,
/// `$2`, ... in bash or `%1`, `%2`, ... in batch).
///
/// If [deviceSerial] is passed, it's set as the `ANDROID_SERIAL`
/// environment variable on the process: every `adb` invocation inside
/// the script reads it automatically when it doesn't receive an
/// explicit `-s`, so the command reaches that device without having to
/// rewrite the script's contents.
class ScriptRunnerService {
  Future<Process> run(ScriptModel script, List<String> params,
      {String? deviceSerial}) async {
    final ext = p.extension(script.path).toLowerCase();
    final environment =
        deviceSerial == null ? null : {'ANDROID_SERIAL': deviceSerial};

    // Run from the script's own folder so scripts that invoke sibling
    // scripts with a relative path (e.g. `./ZipTour.sh 999998 002`)
    // resolve them correctly.
    final workingDirectory = p.dirname(script.path);

    switch (ext) {
      case '.sh':
        return Process.start('bash', [script.path, ...params],
            environment: environment, workingDirectory: workingDirectory);
      case '.ps1':
        return Process.start(
          'powershell',
          [
            '-NoProfile',
            '-ExecutionPolicy',
            'Bypass',
            '-File',
            script.path,
            ...params
          ],
          environment: environment,
          workingDirectory: workingDirectory,
        );
      case '.bat':
      case '.cmd':
        return Process.start('cmd', ['/c', script.path, ...params],
            environment: environment, workingDirectory: workingDirectory);
      default:
        return Process.start(script.path, params,
            environment: environment, workingDirectory: workingDirectory);
    }
  }

  /// Builds a human-readable command string, to show in the console.
  String buildCommandPreview(ScriptModel script, List<String> params) {
    final name = p.basename(script.path);
    return params.isEmpty ? name : '$name ${params.join(' ')}';
  }
}
