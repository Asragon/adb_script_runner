import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/root_folders_provider.dart';

/// Top-left section: lets the user add/remove root folders and choose
/// which one is active (the one scripts are loaded from). Root folders
/// are persisted, so they remain available when the app is reopened.
class RootFolderSection extends ConsumerWidget {
  const RootFolderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(rootFoldersProvider);
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 220, minHeight: 160),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.folder_open,
                      size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(l10n.rootFoldersTitle,
                      style: theme.textTheme.titleSmall),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      final path = await FilePicker.getDirectoryPath();
                      if (path != null) {
                        await ref
                            .watch(rootFoldersProvider.notifier)
                            .addFolder(path);
                      }
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(l10n.addFolder),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.folders.isEmpty
                        ? Center(
                            child: Text(
                              l10n.noFoldersYet,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall,
                            ),
                          )
                        : Material(
                            type: MaterialType.transparency,
                            child: ListView.builder(
                              itemCount: state.folders.length,
                              itemBuilder: (context, index) {
                                final folder = state.folders[index];
                                final isActive =
                                    folder.path == state.activeFolderPath;

                                return ListTile(
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  selected: isActive,
                                  selectedTileColor: theme
                                      .colorScheme.primaryContainer
                                      .withValues(alpha: 0.4),
                                  leading: Icon(
                                    isActive
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    size: 18,
                                    color: isActive
                                        ? theme.colorScheme.primary
                                        : null,
                                  ),
                                  title: Text(folder.name,
                                      overflow: TextOverflow.ellipsis),
                                  subtitle: Text(
                                    folder.path,
                                    style: const TextStyle(fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close, size: 16),
                                    onPressed: () => ref
                                        .read(rootFoldersProvider.notifier)
                                        .removeFolder(folder.path),
                                  ),
                                  onTap: () => ref
                                      .read(rootFoldersProvider.notifier)
                                      .setActive(folder.path),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
