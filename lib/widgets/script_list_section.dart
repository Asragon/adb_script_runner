import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/run_script.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/script_group.dart';
import '../models/script_model.dart';
import '../providers/adb_devices_provider.dart';
import '../providers/root_folders_provider.dart';
import '../providers/script_search_provider.dart';
import '../providers/scripts_provider.dart';
import '../providers/selected_script_provider.dart';

/// Center-left section: shows the scripts of the active root folder,
/// either grouped by subfolder or as a flat list. A search field in the
/// header filters scripts by name once at least two characters are
/// typed.
class ScriptListSection extends ConsumerStatefulWidget {
  const ScriptListSection({super.key});

  @override
  ConsumerState<ScriptListSection> createState() => _ScriptListSectionState();
}

class _ScriptListSectionState extends ConsumerState<ScriptListSection> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(scriptSearchQueryProvider.notifier).state = value;
    setState(() {});
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(scriptSearchQueryProvider.notifier).state = '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scriptsAsync = ref.watch(scriptsProvider);
    final viewMode = ref.watch(scriptListViewModeProvider);
    final activeFolder = ref.watch(rootFoldersProvider).activeFolderPath;
    final searchQuery = ref.watch(scriptSearchQueryProvider);
    final effectiveQuery =
        searchQuery.trim().length >= 2 ? searchQuery.trim().toLowerCase() : '';

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Icon(Icons.terminal,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(l10n.scriptsTitle, style: theme.textTheme.titleSmall),
                const SizedBox(width: 12),
                SizedBox(
                  width: 160,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: theme.textTheme.bodySmall,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      hintText: l10n.searchScriptsHint,
                      prefixIcon: const Icon(Icons.search, size: 16),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear, size: 14),
                              tooltip: l10n.clearSearch,
                              onPressed: _clearSearch,
                            ),
                    ),
                  ),
                ),
                const Spacer(),
                ToggleButtons(
                  constraints:
                      const BoxConstraints(minHeight: 30, minWidth: 38),
                  borderRadius: BorderRadius.circular(6),
                  isSelected: [
                    viewMode == ScriptListViewMode.grouped,
                    viewMode == ScriptListViewMode.flat,
                  ],
                  onPressed: (index) {
                    ref.read(scriptListViewModeProvider.notifier).state =
                        index == 0
                            ? ScriptListViewMode.grouped
                            : ScriptListViewMode.flat;
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
                      final allScripts =
                          groups.expand((g) => g.scripts).toList();
                      if (allScripts.isEmpty) {
                        return Center(
                            child: Text(l10n.noScriptsFound,
                                style: theme.textTheme.bodySmall));
                      }

                      final filteredGroups = effectiveQuery.isEmpty
                          ? groups
                          : groups
                              .map((g) => ScriptGroup(
                                    name: g.name,
                                    path: g.path,
                                    scripts: g.scripts
                                        .where((s) => s.name
                                            .toLowerCase()
                                            .contains(effectiveQuery))
                                        .toList(),
                                  ))
                              .where((g) => g.scripts.isNotEmpty)
                              .toList();
                      final filteredScripts = effectiveQuery.isEmpty
                          ? allScripts
                          : allScripts
                              .where((s) =>
                                  s.name.toLowerCase().contains(effectiveQuery))
                              .toList();

                      final isEmptyAfterFilter =
                          viewMode == ScriptListViewMode.grouped
                              ? filteredGroups.isEmpty
                              : filteredScripts.isEmpty;
                      if (effectiveQuery.isNotEmpty && isEmptyAfterFilter) {
                        return Center(
                            child: Text(l10n.noScriptsMatchSearch,
                                style: theme.textTheme.bodySmall));
                      }

                      return viewMode == ScriptListViewMode.grouped
                          ? _GroupedList(groups: filteredGroups)
                          : _FlatList(scripts: filteredScripts);
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Center(child: Text('${l10n.errorLoadingScripts}: $e')),
                  ),
          ),
        ],
      ),
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
    final deviceSerial =
        ref.watch(adbDevicesProvider.select((s) => s.selectedSerial));

    return Material(
      type: MaterialType.transparency,
      child: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          final displayName =
              group.name.isEmpty ? l10n.generalGroup : group.name;

          return ExpansionTile(
            key: ValueKey(group.path),
            initiallyExpanded: true,
            dense: true,
            leading: const Icon(Icons.folder, size: 18),
            title: Text(displayName,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            children: group.scripts.map((script) {
              final isSelected = selected?.path == script.path;
              return _ScriptTile(
                script: script,
                isSelected: isSelected,
                indent: true,
                deviceSerial: deviceSerial,
              );
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
    final deviceSerial =
        ref.watch(adbDevicesProvider.select((s) => s.selectedSerial));

    return Material(
      type: MaterialType.transparency,
      child: ListView.builder(
        itemCount: scripts.length,
        itemBuilder: (context, index) {
          final script = scripts[index];
          final isSelected = selected?.path == script.path;
          return _ScriptTile(
            script: script,
            isSelected: isSelected,
            indent: false,
            deviceSerial: deviceSerial,
          );
        },
      ),
    );
  }
}

class _ScriptTile extends ConsumerWidget {
  const _ScriptTile({
    required this.script,
    required this.isSelected,
    required this.indent,
    required this.deviceSerial,
  });

  final ScriptModel script;
  final bool isSelected;
  final bool indent;
  final String? deviceSerial;

  Widget _buildQuickRunButton(WidgetRef ref, AppLocalizations l10n) {
    final button = IconButton(
      icon: const Icon(Icons.play_arrow, size: 18),
      visualDensity: VisualDensity.compact,
      tooltip: deviceSerial == null ? null : l10n.runScript,
      onPressed: deviceSerial == null
          ? null
          : () => runScriptWithLogging(ref, script, const [], deviceSerial!),
    );

    if (deviceSerial != null) return button;
    return Tooltip(message: l10n.noDeviceConnected, child: button);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.only(left: indent ? 32 : 16, right: 16),
      selected: isSelected,
      selectedTileColor:
          theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
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
          : _buildQuickRunButton(ref, l10n),
      onTap: () => ref.read(selectedScriptProvider.notifier).state = script,
    );
  }
}
