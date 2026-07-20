// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ADB Script Runner';

  @override
  String get toggleTheme => 'Toggle light/dark theme';

  @override
  String get switchToItalian => 'Switch to Italian';

  @override
  String get switchToEnglish => 'Switch to English';

  @override
  String get rootFoldersTitle => 'Script folders';

  @override
  String get addFolder => 'Add folder';

  @override
  String get noFoldersYet =>
      'No folders added yet. Use \"Add folder\" to get started.';

  @override
  String get scriptsTitle => 'Scripts';

  @override
  String get selectFolderPrompt =>
      'Select a root folder above to load its scripts';

  @override
  String get noScriptsFound => 'No scripts found in this folder';

  @override
  String get errorLoadingScripts => 'Error loading scripts';

  @override
  String get generalGroup => 'General';

  @override
  String get searchScriptsHint => 'Search scripts';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get noScriptsMatchSearch => 'No scripts match your search';

  @override
  String get noScriptSelected =>
      'Select a script from the list to see its details';

  @override
  String get parametersLabel => 'Parameters';

  @override
  String get runScript => 'Run';

  @override
  String get consoleTitle => 'Console';

  @override
  String get clearConsole => 'Clear console';

  @override
  String get consoleEmpty => 'No commands executed yet';

  @override
  String get selectDeviceTooltip => 'Select device';

  @override
  String get noDeviceConnected => 'No device connected';

  @override
  String get adbNotFound => 'adb not found in PATH';

  @override
  String get deviceUnauthorized => 'unauthorized';

  @override
  String get deviceOffline => 'offline';

  @override
  String get deviceStateOther => 'unknown';
}
