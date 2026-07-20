import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it')
  ];

  /// Application title shown in the app bar
  ///
  /// In en, this message translates to:
  /// **'ADB Script Runner'**
  String get appTitle;

  /// No description provided for @toggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle light/dark theme'**
  String get toggleTheme;

  /// No description provided for @switchToItalian.
  ///
  /// In en, this message translates to:
  /// **'Switch to Italian'**
  String get switchToItalian;

  /// No description provided for @switchToEnglish.
  ///
  /// In en, this message translates to:
  /// **'Switch to English'**
  String get switchToEnglish;

  /// No description provided for @rootFoldersTitle.
  ///
  /// In en, this message translates to:
  /// **'Script folders'**
  String get rootFoldersTitle;

  /// No description provided for @addFolder.
  ///
  /// In en, this message translates to:
  /// **'Add folder'**
  String get addFolder;

  /// No description provided for @noFoldersYet.
  ///
  /// In en, this message translates to:
  /// **'No folders added yet. Use \"Add folder\" to get started.'**
  String get noFoldersYet;

  /// No description provided for @scriptsTitle.
  ///
  /// In en, this message translates to:
  /// **'Scripts'**
  String get scriptsTitle;

  /// No description provided for @selectFolderPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select a root folder above to load its scripts'**
  String get selectFolderPrompt;

  /// No description provided for @noScriptsFound.
  ///
  /// In en, this message translates to:
  /// **'No scripts found in this folder'**
  String get noScriptsFound;

  /// No description provided for @errorLoadingScripts.
  ///
  /// In en, this message translates to:
  /// **'Error loading scripts'**
  String get errorLoadingScripts;

  /// No description provided for @generalGroup.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalGroup;

  /// No description provided for @noScriptSelected.
  ///
  /// In en, this message translates to:
  /// **'Select a script from the list to see its details'**
  String get noScriptSelected;

  /// No description provided for @parametersLabel.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get parametersLabel;

  /// No description provided for @runScript.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get runScript;

  /// No description provided for @consoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Console'**
  String get consoleTitle;

  /// No description provided for @clearConsole.
  ///
  /// In en, this message translates to:
  /// **'Clear console'**
  String get clearConsole;

  /// No description provided for @consoleEmpty.
  ///
  /// In en, this message translates to:
  /// **'No commands executed yet'**
  String get consoleEmpty;

  /// No description provided for @selectDeviceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select device'**
  String get selectDeviceTooltip;

  /// No description provided for @noDeviceConnected.
  ///
  /// In en, this message translates to:
  /// **'No device connected'**
  String get noDeviceConnected;

  /// No description provided for @adbNotFound.
  ///
  /// In en, this message translates to:
  /// **'adb not found in PATH'**
  String get adbNotFound;

  /// No description provided for @deviceUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'unauthorized'**
  String get deviceUnauthorized;

  /// No description provided for @deviceOffline.
  ///
  /// In en, this message translates to:
  /// **'offline'**
  String get deviceOffline;

  /// No description provided for @deviceStateOther.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get deviceStateOther;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
