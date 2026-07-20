import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/script_group.dart';
import '../models/script_model.dart';
import '../providers/root_folders_provider.dart';
import '../providers/scripts_provider.dart';
import '../providers/selected_script_provider.dart';

/// Center-left section: shows the scripts of the active root folder,
/// either grouped by subfolder or as a flat list.
class ScriptListSection extends ConsumerWidget {
  const ScriptListSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scriptsAsync = ref.watch(scriptsProvider);
    final viewMode = ref.watch(scriptListViewModeProvider);
    final activeFolder = ref.watch(rootFoldersProvider).activeFolderPath;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              Icon(Icons.terminal, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(l10n.scriptsTitle, style: theme.textTheme.titleSmall),
              const Spacer(),
              ToggleButtons(
                constraints: const BoxConstraints(minHeight: 30, minWidth: 38),
                borderRadius: BorderRadius.circular(6),
                isSelected: [
                  viewMode == ScriptListViewMode.grouped,
                  viewMode == ScriptListViewMode.flat,
                ],
                onPressed: (index) {
                  ref.read(scriptListViewModeProvider.notifier).state =
                      index == 0 ? ScriptListViewMode.grouped : ScriptListViewMode.flat;
                },
                children: const [
                  Icon(Icons.folder_outlined, size: 16),
                  Icon(Icons.list, size: 16),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: activeFolder == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.selectFolderPrompt,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                )
              : scriptsAsync.when(
                  data: (groups) {
                    final allScripts = groups.expand((g) => g.scripts).toList();
                    if (allScripts.isEmpty) {
                      return Center(child: Text(l10n.noScriptsFound, style: theme.textTheme.bodySmall));
                    }
                    return viewMode == ScriptListViewMode.grouped
                        ? _GroupedList(groups: groups)
                        : _FlatList(scripts: allScripts);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('${l10n.errorLoadingScripts}: $e')),
                ),
        ),
      ],
    );
  }
}

class _GroupedList extends ConsumerWidget {
  const _GroupedList({required this.groups});

  final List<ScriptGroup> groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selected = ref.watch(selectedScriptProvider);

    return Material(
      type: MaterialType.transparency,
      child: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          final displayName = group.name.isEmpty ? l10n.generalGroup : group.name;

          return ExpansionTile(
            initiallyExpanded: true,
            dense: true,
            leading: const Icon(Icons.folder, size: 18),
            title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
            children: group.scripts.map((script) {
              final isSelected = selected?.path == script.path;
              return _ScriptTile(script: script, isSelected: isSelected, indent: true);
            }).toList(),
          );
        },
      ),
    );
  }
}

class _FlatList extends ConsumerWidget {
  const _FlatList({required this.scripts});

  final List<ScriptModel> scripts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedScriptProvider);

    return Material(
      type: MaterialType.transparency,
      child: ListView.builder(
        itemCount: scripts.length,
        itemBuilder: (context, index) {
          final script = scripts[index];
          final isSelected = selected?.path == script.path;
          return _ScriptTile(script: script, isSelected: isSelected, indent: false);
        },
      ),
    );
  }
}

class _ScriptTile extends ConsumerWidget {
  const _ScriptTile({required this.script, required this.isSelected, required this.indent});

  final ScriptModel script;
  final bool isSelected;
  final bool indent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.only(left: indent ? 32 : 16, right: 16),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
      leading: const Icon(Icons.description_outlined, size: 16),
      title: Text(script.name, overflow: TextOverflow.ellipsis),
      subtitle: !indent && script.groupName.isNotEmpty
          ? Text(script.groupName, style: const TextStyle(fontSize: 10))
          : null,
      trailing: script.hasParameters
          ? Chip(
              visualDensity: VisualDensity.compact,
              label: Text('${script.parameterCount}'),
              padding: EdgeInsets.zero,
            )
          : null,
      onTap: () => ref.read(selectedScriptProvider.notifier).state = script,
    );
  }
}
