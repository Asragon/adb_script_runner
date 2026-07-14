// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'ADB Script Runner';

  @override
  String get toggleTheme => 'Cambia tema chiaro/scuro';

  @override
  String get rootFoldersTitle => 'Cartelle script';

  @override
  String get addFolder => 'Aggiungi cartella';

  @override
  String get noFoldersYet =>
      'Nessuna cartella aggiunta. Usa \"Aggiungi cartella\" per iniziare.';

  @override
  String get scriptsTitle => 'Script';

  @override
  String get selectFolderPrompt =>
      'Seleziona una cartella radice sopra per caricare gli script';

  @override
  String get noScriptsFound => 'Nessuno script trovato in questa cartella';

  @override
  String get errorLoadingScripts => 'Errore nel caricamento degli script';

  @override
  String get generalGroup => 'Generale';

  @override
  String get noScriptSelected =>
      'Seleziona uno script dalla lista per vederne i dettagli';

  @override
  String get parametersLabel => 'Parametri';

  @override
  String get runScript => 'Esegui';

  @override
  String get consoleTitle => 'Console';

  @override
  String get clearConsole => 'Pulisci console';

  @override
  String get consoleEmpty => 'Nessun comando ancora eseguito';
}
