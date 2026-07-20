import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/script_model.dart';
import '../../providers/console_provider.dart';
import '../../services/script_runner_service.dart';

final _runner = ScriptRunnerService();

/// Runs [script] with [params] on [deviceSerial] and streams its
/// stdout/stderr into the console log. Shared by ScriptDetailSection and
/// the quick-run button in ScriptListSection so both reuse the same
/// process-spawning/console-logging logic instead of duplicating it.
Future<void> runScriptWithLogging(
  WidgetRef ref,
  ScriptModel script,
  List<String> params,
  String deviceSerial,
) async {
  final consoleNotifier = ref.read(consoleProvider.notifier);
  final command = _runner.buildCommandPreview(script, params);
  final entryId =
      consoleNotifier.startEntry(scriptName: script.name, command: command);

  try {
    final process =
        await _runner.run(script, params, deviceSerial: deviceSerial);

    process.stdout.transform(const SystemEncoding().decoder).listen((data) {
      for (final line in data.split('\n')) {
        if (line.trim().isNotEmpty) consoleNotifier.appendOutput(entryId, line);
      }
    });
    process.stderr.transform(const SystemEncoding().decoder).listen((data) {
      for (final line in data.split('\n')) {
        if (line.trim().isNotEmpty) {
          consoleNotifier.appendOutput(entryId, '[stderr] $line');
        }
      }
    });

    final exitCode = await process.exitCode;
    consoleNotifier.finish(entryId, exitCode: exitCode);
  } catch (e) {
    consoleNotifier.appendOutput(entryId, '[error] $e');
    consoleNotifier.finish(entryId, exitCode: -1);
  }
}
