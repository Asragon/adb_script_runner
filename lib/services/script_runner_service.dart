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
///
/// Se [deviceSerial] è passato, viene impostato come variabile d'ambiente
/// `ANDROID_SERIAL` sul processo: ogni `adb` invocato dentro lo script la
/// legge automaticamente quando non riceve un `-s` esplicito, così il
/// comando raggiunge quel device senza dover riscrivere il contenuto dello
/// script.
class ScriptRunnerService {
  Future<Process> run(ScriptModel script, List<String> params,
      {String? deviceSerial}) async {
    final ext = p.extension(script.path).toLowerCase();
    final environment =
        deviceSerial == null ? null : {'ANDROID_SERIAL': deviceSerial};

    switch (ext) {
      case '.sh':
        return Process.start('bash', [script.path, ...params],
            environment: environment);
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
        );
      case '.bat':
      case '.cmd':
        return Process.start('cmd', ['/c', script.path, ...params],
            environment: environment);
      default:
        return Process.start(script.path, params, environment: environment);
    }
  }

  /// Costruisce una stringa human-readable del comando, da mostrare in console.
  String buildCommandPreview(ScriptModel script, List<String> params) {
    final name = p.basename(script.path);
    return params.isEmpty ? name : '$name ${params.join(' ')}';
  }
}
