import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/run_script.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/script_model.dart';
import '../providers/adb_devices_provider.dart';
import '../providers/selected_script_provider.dart';

/// Bottom-left section: shows the details of the selected script. If
/// the script requires positional parameters ($1, $2, ...) it shows a
/// text field for each one; otherwise the "Run" button launches the
/// command directly.
class ScriptDetailSection extends ConsumerStatefulWidget {
  const ScriptDetailSection({super.key});

  @override
  ConsumerState<ScriptDetailSection> createState() =>
      _ScriptDetailSectionState();
}

class _ScriptDetailSectionState extends ConsumerState<ScriptDetailSection> {
  final Map<String, TextEditingController> _controllers = {};
  String? _lastScriptPath;

  List<TextEditingController> _controllersFor(ScriptModel script) {
    if (_lastScriptPath != script.path) {
      for (final c in _controllers.values) {
        c.dispose();
      }
      _controllers.clear();
      for (final placeholder in script.parameterPlaceholders) {
        _controllers[placeholder] = TextEditingController();
      }
      _lastScriptPath = script.path;
    }
    return script.parameterPlaceholders.map((ph) => _controllers[ph]!).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _buildRunButton(
    AppLocalizations l10n,
    ScriptModel script,
    String? deviceSerial,
  ) {
    final button = FilledButton.icon(
      onPressed: deviceSerial == null
          ? null
          : () {
              final params =
                  _controllersFor(script).map((c) => c.text).toList();
              runScriptWithLogging(ref, script, params, deviceSerial);
            },
      icon: const Icon(Icons.play_arrow, size: 18),
      label: Text(l10n.runScript),
    );

    if (deviceSerial != null) return button;
    return Tooltip(message: l10n.noDeviceConnected, child: button);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final script = ref.watch(selectedScriptProvider);
    final deviceSerial =
        ref.watch(adbDevicesProvider.select((s) => s.selectedSerial));

    return Container(
      constraints: const BoxConstraints(minHeight: 170, maxHeight: 260),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: script == null
          ? Center(
              child: Text(
                l10n.noScriptSelected,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fixed header row: icon + name/path on the left, Run button
                // on the right. This row never scrolls.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.description_outlined, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            script.name,
                            style: theme.textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            script.path,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.hintColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildRunButton(l10n, script, deviceSerial),
                  ],
                ),
                const SizedBox(height: 12),
                // Everything below (parameters + script body) scrolls.
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (script.hasParameters) ...[
                          Text(l10n.parametersLabel,
                              style: theme.textTheme.labelMedium),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: _controllersFor(script)
                                .asMap()
                                .entries
                                .map((entry) {
                              final placeholder =
                                  script.parameterPlaceholders[entry.key];
                              return SizedBox(
                                width: 150,
                                child: TextField(
                                  controller: entry.value,
                                  decoration:
                                      InputDecoration(labelText: placeholder),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Text(
                          script.body,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.hintColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
