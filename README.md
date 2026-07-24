# ADB Script Runner

Flutter desktop app (Windows/macOS) for browsing and running ADB scripts
organized in folders. It discovers connected Android devices, lets you pick a
target, and streams each script's output into a console panel — with live
folder watching, search, and a fully themeable/localized UI.

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

### Requirements

- **`adb`** on the system PATH — needed both to list/track devices and for
  any script that invokes `adb` internally.
- **`bash`** on PATH (Git Bash or WSL on Windows) to run `.sh` scripts.

### Building a Windows release

```bash
flutter build windows --release
```

The executable is generated at
`build/windows/x64/runner/Release/adb_script_runner.exe`. It is **not**
standalone: to distribute the app, ship the whole `Release/` folder (it also
contains `flutter_windows.dll`, the `data/` directory, and any plugin DLLs).

## Features

- **Multiple root folders**: register one or more script folders and switch the
  active one; the selection is persisted across sessions.
- **Live folder scanning**: the active root is scanned into groups (one per
  immediate subfolder; loose scripts go under a "General" group) and re-scanned
  automatically when files change on disk.
- **Grouped / flat views + search**: toggle between a grouped tree and a flat
  list, and filter scripts by name (from 2 characters).
- **Parameter detection**: scripts using positional parameters get one input
  field per parameter; parameterless scripts run directly.
- **ADB device selection**: connected devices are discovered via
  `adb track-devices` and shown with their type; the chosen device's serial is
  injected as `ANDROID_SERIAL` so every `adb` call in the script targets it
  without editing the script.
- **Quick run + open folder**: each script row has a one-click run button (when
  a device is selected) and a clickable file icon that reveals the script in the
  OS file manager.
- **Console**: chronological, per-run log with streamed stdout/stderr and exit
  codes (in-memory, resets on app close).
- **Theming & language at runtime**: switch light/dark, pick an accent color
  (red/green/blue) from the app bar, and switch language (EN/IT) on the fly.

## Project structure

```
lib/
  core/
    theme/          -> AppColors + AppTheme: the single place to change the
                        palette/style; seed/accent color is runtime-settable
    constants/      -> global constants (script extensions, window size)
    utils/
      script_parameter_parser.dart -> parse $1/${1}/%1 parameters
      run_script.dart              -> shared run + console-logging helper
      reveal_in_explorer.dart      -> open a script's folder in the OS file manager
  models/           -> RootFolder, ScriptModel, ScriptGroup, ConsoleEntry, AdbDevice
  services/
    storage_service.dart        -> root folder persistence (SharedPreferences)
    script_scanner_service.dart -> folder scan -> script groups
    script_runner_service.dart  -> script execution (bash/powershell/cmd)
    adb_device_service.dart     -> adb device discovery (list / track-devices)
  providers/        -> Riverpod state: root folders, scripts, console,
                       selected script, adb devices, search, theme, locale
  screens/
    home_screen.dart -> main layout (folder/list/detail column + console)
  widgets/
    root_folder_section.dart   -> top left: folder management + device selector
    script_list_section.dart   -> center left: script list (grouped/flat + search)
    script_detail_section.dart -> bottom left: parameters + execution
    console_section.dart       -> right: chronological command log
    device_selector.dart       -> ADB device dropdown
    language_selector.dart     -> EN/IT switch
  l10n/
    app_en.arb, app_it.arb     -> multilingual strings (EN/IT)
    generated/                 -> build output, don't hand-edit
```

## Implementation notes

- **Root folder persistence**: `shared_preferences` stores the list of paths
  and the active one. This is deliberately the lightest solution possible; if
  richer metadata is ever needed (favorite scripts, execution history across
  sessions), `StorageService` can be replaced with a local database
  (Hive/Isar) without touching the rest of the app.

- **Script scanning**: each immediate subfolder of the root becomes a "group";
  scripts found directly in the root are grouped under the "General" label
  (localized). Recognized extensions: `.sh`, `.bat`, `.cmd`, `.ps1`
  (`AppConstants.scriptExtensions`).

- **Parameters**: each script's content is analyzed with a regex to detect
  `$1`, `${1}` (bash style) and `%1` (batch/Windows style), up to `9`. If no
  parameters are found, the "Run" button launches the script directly.

- **Execution**: depending on the extension, the script is launched with the
  matching interpreter:
    - `.sh` → `bash` (requires bash on PATH, e.g. Git Bash or WSL on Windows)
    - `.ps1` → `powershell -NoProfile -ExecutionPolicy Bypass -File ...`
    - `.bat` / `.cmd` → `cmd /c ...`

  The process runs with its **working directory set to the script's own
  folder**, so a script can call a sibling script with a relative path
  (e.g. `./ZipTour.sh 999998 002`) and it resolves correctly.

- **Device targeting**: when a device is selected, its serial is passed to the
  process as the `ANDROID_SERIAL` environment variable; `adb` reads it
  automatically when no explicit `-s` is given.

- **State/Riverpod**: no code-gen required ("classic"
  `StateNotifierProvider`/`StateProvider` are used), to keep the project simple
  to open and modify right away.

- **Global theming**: `AppColors.seed` in `lib/core/theme/app_colors.dart` is
  the base palette; the accent color can also be changed at runtime from the app
  bar (light and dark are derived automatically).

- **Multilingual support**: add a new language by creating
  `lib/l10n/app_<code>.arb` with the same keys as `app_en.arb`.

## Possible future extensions

- Persist console/run history across sessions.
- Favorite/pinned scripts.
- Per-script saved parameter presets.
```
