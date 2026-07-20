import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../l10n/generated/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../widgets/console_section.dart';
import '../widgets/language_selector.dart';
import '../widgets/root_folder_section.dart';
import '../widgets/script_detail_section.dart';
import '../widgets/script_list_section.dart';

/// Main layout:
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
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final seedColor = ref.watch(seedColorProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        scrolledUnderElevation: 0,
        actions: [
          _AccentColorDot(
            color: AppColors.accentRed,
            tooltip: l10n.changeColorRed,
            selected: seedColor == AppColors.accentRed,
          ),
          _AccentColorDot(
            color: AppColors.accentGreen,
            tooltip: l10n.changeColorGreen,
            selected: seedColor == AppColors.accentGreen,
          ),
          _AccentColorDot(
            color: AppColors.accentBlue,
            tooltip: l10n.changeColorBlue,
            selected: seedColor == AppColors.accentBlue,
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: l10n.toggleTheme,
            icon: Icon(themeMode == ThemeMode.dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
            onPressed: () {
              final notifier = ref.read(themeModeProvider.notifier);
              notifier.set(themeMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const LanguageSelector(),
          const Divider(height: 1),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 40,
                  child: Container(
                    color: theme.colorScheme.surfaceContainerLowest,
                    padding: const EdgeInsets.all(8),
                    child: const Column(
                      children: [
                        RootFolderSection(),
                        SizedBox(height: 8),
                        Expanded(child: ScriptListSection()),
                        SizedBox(height: 8),
                        ScriptDetailSection(),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                const Expanded(
                  flex: 60,
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

/// A small tappable colored circle used in the app bar to set
/// [seedColorProvider], overriding the app's whole color scheme.
class _AccentColorDot extends ConsumerWidget {
  const _AccentColorDot({
    required this.color,
    required this.tooltip,
    required this.selected,
  });

  final Color color;
  final String tooltip;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => ref.read(seedColorProvider.notifier).set(color),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? scheme.onSurface : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
