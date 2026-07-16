import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lingua corrente dell'app (IT/EN). Impostabile in tempo reale dai
/// bottoni bandiera in [LanguageSelector]. Default: inglese, in linea
/// con il locale "template" usato da l10n.yaml.
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));
