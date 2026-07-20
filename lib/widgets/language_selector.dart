import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/locale_provider.dart';
import 'device_selector.dart';

/// Barra sottile tra l'AppBar e il contenuto principale: due bandiere
/// (IT/EN) che cambiano la lingua dell'app in tempo reale. Le bandiere
/// sono disegnate a mano (CustomPainter) invece che con emoji, perché
/// il motore di rendering di Flutter su Windows non mostra le emoji
/// bandiera a colori.
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const DeviceSelector(),
          Row(
            children: [
              _FlagButton(
                painter: const _ItalyFlagPainter(),
                tooltip: l10n.switchToItalian,
                selected: locale.languageCode == 'it',
                onTap: () => ref.read(localeProvider.notifier).state = const Locale('it'),
              ),
              const SizedBox(width: 4),
              _FlagButton(
                painter: const _UkFlagPainter(),
                tooltip: l10n.switchToEnglish,
                selected: locale.languageCode == 'en',
                onTap: () => ref.read(localeProvider.notifier).state = const Locale('en'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlagButton extends StatelessWidget {
  const _FlagButton({
    required this.painter,
    required this.tooltip,
    required this.selected,
    required this.onTap,
  });

  final CustomPainter painter;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected ? theme.colorScheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: CustomPaint(size: const Size(24, 16), painter: painter),
          ),
        ),
      ),
    );
  }
}

class _ItalyFlagPainter extends CustomPainter {
  const _ItalyFlagPainter();

  static const _green = Color(0xFF009246);
  static const _red = Color(0xFFCE2B37);

  @override
  void paint(Canvas canvas, Size size) {
    final stripeWidth = size.width / 3;
    for (final entry in const [_green, Colors.white, _red].asMap().entries) {
      canvas.drawRect(
        Rect.fromLTWH(stripeWidth * entry.key, 0, stripeWidth, size.height),
        Paint()..color = entry.value,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _UkFlagPainter extends CustomPainter {
  const _UkFlagPainter();

  static const _blue = Color(0xFF00247D);
  static const _red = Color(0xFFCF142B);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = _blue);

    canvas.save();
    canvas.clipRect(rect);

    final whiteDiagonal = Paint()
      ..color = Colors.white
      ..strokeWidth = size.height * 0.3;
    final redDiagonal = Paint()
      ..color = _red
      ..strokeWidth = size.height * 0.12;

    canvas.drawLine(Offset.zero, Offset(size.width, size.height), whiteDiagonal);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), whiteDiagonal);
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), redDiagonal);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), redDiagonal);

    canvas.restore();

    final white = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.36, size.width, size.height * 0.28), white);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.4, 0, size.width * 0.2, size.height), white);

    final red = Paint()..color = _red;
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.42, size.width, size.height * 0.16), red);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.44, 0, size.width * 0.12, size.height), red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
