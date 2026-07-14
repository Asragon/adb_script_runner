import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/console_entry.dart';
import '../providers/console_provider.dart';

/// Sezione destra: mostra in ordine cronologico tutti i comandi
/// lanciati, con output/errore e stato (in corso / successo / errore).
class ConsoleSection extends ConsumerStatefulWidget {
  const ConsoleSection({super.key});

  @override
  ConsumerState<ConsoleSection> createState() => _ConsoleSectionState();
}

class _ConsoleSectionState extends ConsumerState<ConsoleSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final entries = ref.watch(consoleProvider);

    ref.listen(consoleProvider, (prev, next) => _scrollToBottom());

    return Container(
      color: theme.colorScheme.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              children: [
                Icon(Icons.code, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(l10n.consoleTitle, style: theme.textTheme.titleSmall),
                const Spacer(),
                IconButton(
                  tooltip: l10n.clearConsole,
                  icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                  onPressed: () => ref.read(consoleProvider.notifier).clear(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: entries.isEmpty
                ? Center(child: Text(l10n.consoleEmpty, style: theme.textTheme.bodySmall))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: entries.length,
                    itemBuilder: (context, index) => _ConsoleEntryCard(entry: entries[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ConsoleEntryCard extends StatelessWidget {
  const _ConsoleEntryCard({required this.entry});

  final ConsoleEntry entry;

  Color _statusColor() {
    switch (entry.status) {
      case ConsoleEntryStatus.running:
        return AppColors.statusRunning;
      case ConsoleEntryStatus.success:
        return AppColors.statusSuccess;
      case ConsoleEntryStatus.error:
        return AppColors.statusError;
    }
  }

  String _formatTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: _statusColor(), shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_formatTime(entry.timestamp)}  ${entry.scriptName}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (entry.exitCode != null)
                  Text(
                    'exit ${entry.exitCode}',
                    style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '\$ ${entry.command}',
              style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Theme.of(context).hintColor),
            ),
            if (entry.output.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.consoleBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  entry.output.join('\n'),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: AppColors.consoleForeground,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
