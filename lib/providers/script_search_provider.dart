import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Search text used to filter the script list by name (see
/// [ScriptListSection]). The filter is only applied once the query is
/// at least two characters long; shorter queries show the full list.
final scriptSearchQueryProvider = StateProvider<String>((ref) => '');
