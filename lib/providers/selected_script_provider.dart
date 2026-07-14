import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/script_model.dart';

/// Script attualmente selezionato nella lista, mostrato nel pannello
/// dettagli in basso a sinistra. Null se nessuno script è selezionato.
final selectedScriptProvider = StateProvider<ScriptModel?>((ref) => null);

enum ScriptListViewMode { grouped, flat }

/// Modalità di visualizzazione della lista script: raggruppata per
/// sottocartella oppure lista piatta.
final scriptListViewModeProvider = StateProvider<ScriptListViewMode>(
  (ref) => ScriptListViewMode.grouped,
);
