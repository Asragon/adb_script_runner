import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../widgets/console_section.dart';
import '../widgets/language_selector.dart';
import '../widgets/root_folder_section.dart';
import '../widgets/script_detail_section.dart';
import '../widgets/script_list_section.dart';

/// Layout principale:
///
/// ┌─────────────────────────────────────────────────┐
/// │ Language selector                                │
/// ├─────────────────────────────┬───────────────────┤
/// │ Root folder section (top)   │                    │
/// ├─────────────────────────────┤                    │
/// │ Script list section (mid)   │  Console section    │
/// ├─────────────────────────────┤                    │
/// │ Script detail section (bot) │                    │
/// └─────────────────────────────┴───────────────────┘
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: l10n.toggleTheme,
            icon: Icon(themeMode == ThemeMode.dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
            onPressed: () {
              final notifier = ref.read(themeModeProvider.notifier);
              notifier.state = themeMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const Column(
        children: [
          LanguageSelector(),
          Divider(height: 1),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      RootFolderSection(),
                      Divider(height: 1),
                      Expanded(child: ScriptListSection()),
                      Divider(height: 1),
                      ScriptDetailSection(),
                    ],
                  ),
                ),
                VerticalDivider(width: 1),
                Expanded(
                  flex: 4,
                  child: ConsoleSection(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
