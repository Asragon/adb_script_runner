import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/script_model.dart';

/// Script currently selected in the list, shown in the bottom-left
/// details panel. Null if no script is selected.
final selectedScriptProvider = StateProvider<ScriptModel?>((ref) => null);

enum ScriptListViewMode { grouped, flat }

/// Script list display mode: grouped by subfolder or flat list.
final scriptListViewModeProvider = StateProvider<ScriptListViewMode>(
  (ref) => ScriptListViewMode.grouped,
);
