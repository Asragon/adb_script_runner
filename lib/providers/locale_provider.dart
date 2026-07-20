import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current app language (IT/EN). Settable in real time via the flag
/// buttons in [LanguageSelector]. Default: English, in line with the
/// "template" locale used by l10n.yaml.
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));
