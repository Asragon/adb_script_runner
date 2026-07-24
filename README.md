# ADB Script Runner

Flutter desktop app (Windows/macOS) for browsing and running ADB scripts
organized in folders.

## Getting started

```bash
flutter pub get
flutter run -d windows   # or -d macos
```

Localization (`AppLocalizations`) is generated automatically thanks to
`generate: true` in `pubspec.yaml` + `l10n.yaml`, so no extra command is
needed: just `flutter pub get` / `flutter run`. If your editor reports
that `l10n/generated/app_localizations.dart` doesn't exist, run
`flutter gen-l10n` once.

## Project structure

```
lib/
  core/
    theme/          -> AppColors + AppTheme: the single place to change
                        the palette/style across the whole app
    constants/       -> global constants (script extensions, etc.)
    utils/           -> parsing of $1/%1 parameters from scripts
  models/            -> RootFolder, ScriptModel, ScriptGroup, ConsoleEntry
  services/
    storage_service.dart        -> root folder persistence (SharedPreferences)
    script_scanner_service.dart -> folder scan -> script groups
    script_runner_service.dart  -> script execution (bash/powershell/cmd)
  providers/         -> Riverpod state (root folders, scripts, console, theme)
  screens/
    home_screen.dart -> main 4-zone layout
  widgets/
    root_folder_section.dart   -> top left: folder management
    script_list_section.dart   -> center left: script list (grouped/flat)
    script_detail_section.dart -> bottom left: parameters + execution
    console_section.dart       -> right: chronological command log
  l10n/
    app_en.arb, app_it.arb     -> multilingual strings (EN/IT)
```

## Implementation notes

- **Root folder persistence**: `shared_preferences` is used to save the
  list of paths and which one is active. This is deliberately the
  lightest solution possible; if richer metadata is ever needed (e.g.
  favorite scripts, execution history across sessions), `StorageService`
  can be replaced with a local database (Hive/Isar) without touching the
  rest of the app.

- **Script scanning**: each immediate subfolder of the root becomes a
  "group"; scripts found directly in the root are grouped under the
  "General" label (localized). Recognized extensions: `.sh`, `.bat`,
  `.cmd`, `.ps1` (`AppConstants.scriptExtensions`).

- **Parameters**: each script's content is analyzed with a regex to
  detect `$1`, `${1}` (bash style) and `%1` (batch/Windows style), up to
  `9`. If no parameters are found, the "Run" button launches the script
  directly.

- **Execution**: depending on the extension, the script is launched with
  the matching interpreter:
    - `.sh` → `bash` (requires bash on PATH, e.g. Git Bash or WSL on Windows)
    - `.ps1` → `powershell -ExecutionPolicy Bypass -File ...`
    - `.bat` / `.cmd` → `cmd /c ...`

  If your `.sh` scripts call `adb` internally, make sure `adb.exe` is on
  the system PATH (or referenced with an absolute path inside the
  script).

- **State/Riverpod**: no code-gen required ("classic"
  `StateNotifierProvider`/`StateProvider` are used), to keep the project
  simple to open and modify right away.

- **Global theming**: change `AppColors.seed` in
  `lib/core/theme/app_colors.dart` to change the app's primary color
  everywhere (light and dark are derived automatically).

- **Multilingual support**: add a new language by creating
  `lib/l10n/app_<code>.arb` with the same keys as `app_en.arb`.

