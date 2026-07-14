import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/script_model.dart';

/// Esegue uno script come processo esterno, scegliendo l'interprete
/// corretto in base all'estensione del file:
/// - `.sh`   -> bash (richiede bash.exe nel PATH, es. Git Bash o WSL)
/// - `.ps1`  -> powershell
/// - `.bat`/`.cmd` -> cmd
///
/// I parametri vengono passati come argomenti posizionali dello script
/// (`$1`, `$2`, ... in bash o `%1`, `%2`, ... in batch).
class ScriptRunnerService {
  Future<Process> run(ScriptModel script, List<String> params) async {
    final ext = p.extension(script.path).toLowerCase();

    switch (ext) {
      case '.sh':
        return Process.start('bash', [script.path, ...params]);
      case '.ps1':
        return Process.start(
          'powershell',
          ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', script.path, ...params],
        );
      case '.bat':
      case '.cmd':
        return Process.start('cmd', ['/c', script.path, ...params]);
      default:
        return Process.start(script.path, params);
    }
  }

  /// Costruisce una stringa human-readable del comando, da mostrare in console.
  String buildCommandPreview(ScriptModel script, List<String> params) {
    final name = p.basename(script.path);
    return params.isEmpty ? name : '$name ${params.join(' ')}';
  }
}
