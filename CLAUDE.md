# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this
repository.

## Project

Flutter desktop app (Windows/macOS) for browsing and running ADB scripts organized in folders.
Source comments and commit/doc language are Italian; keep new inline comments consistent with the
surrounding file's language.

## Commands

```bash
flutter pub get              # install dependencies
flutter run -d windows       # run on Windows (or -d macos)
flutter analyze              # static analysis (flutter_lints)
flutter test                 # run all tests
flutter test test/widget_test.dart   # run a single test file
flutter gen-l10n             # regenerate lib/l10n/generated/* manually if the editor complains it's missing
```

Localization files (`AppLocalizations`) are regenerated automatically on `flutter pub get`/
`flutter run` because `generate: true` is set in `pubspec.yaml`.

## Architecture

Layout is a strict `models -> services -> providers -> widgets/screens` pipeline; there is no other
cross-cutting layer.

- `lib/core/theme/` — `AppColors` + `AppTheme` are the single place to change the app's
  palette/style (light/dark derived from `AppColors.seed`).
- `lib/core/constants/app_constants.dart` — global constants, notably `scriptExtensions` (`.sh`,
  `.bat`, `.cmd`, `.ps1`).
- `lib/core/utils/script_parameter_parser.dart` — regex-based parser that detects positional
  parameters in script bodies: `$1`/`${1}` (bash-style) and `%1` (batch-style), up to `9`.
- `lib/models/` — `RootFolder`, `ScriptModel`, `ScriptGroup`, `ConsoleEntry`. Plain data classes, no
  logic beyond construction.
- `lib/services/`
    - `storage_service.dart` — persists root folder paths + active folder via `shared_preferences`.
      Deliberately minimal; if richer persistence (favorites, run history across sessions) is ever
      needed, replace this service (e.g. with Hive/Isar) without touching the rest of the app.
    - `script_scanner_service.dart` — scans a root folder into `List<ScriptGroup>`: each immediate
      subfolder becomes a group named after itself; scripts sitting directly in the root are grouped
      under an empty-name group (UI localizes the "General" label). Groups/scripts are sorted
      case-insensitively by name.
    - `script_runner_service.dart` — launches a script as an external process, picking the
      interpreter by extension: `.sh` → `bash`, `.ps1` →
      `powershell -NoProfile -ExecutionPolicy Bypass -File`, `.bat`/`.cmd` → `cmd /c`. Parameters
      are passed as positional process args. Running `.sh` scripts requires `bash` on PATH (Git
      Bash/WSL on Windows); scripts invoking `adb` require `adb.exe` on PATH or referenced by
      absolute path.
- `lib/providers/` — Riverpod state, using classic `StateNotifierProvider`/`StateProvider` (no
  code-gen, by design, to keep the project simple to open and modify).
    - `root_folders_provider.dart` — `RootFoldersNotifier`/`RootFoldersState` owns the list of root
      folders and which one is active; every mutation is persisted immediately via `StorageService`.
    - `scripts_provider.dart` — `ScriptsNotifier` watches `rootFoldersProvider`'s active path (
      `.select`), re-runs `ScriptScannerService.scanRoot` whenever it changes, and also sets up a
      recursive `Directory.watch` filesystem subscription on the active root so script list changes
      on disk are picked up live. The provider recreates (and the watch subscription resets)
      whenever the active folder changes.
    - `console_provider.dart`, `selected_script_provider.dart`, `theme_provider.dart` — console log
      entries, currently-selected script, and light/dark `ThemeMode` state respectively.
- `lib/screens/home_screen.dart` — single main screen, 4-zone layout: left column (root folder
  section / script list / script detail, stacked) plus a console section on the right showing the
  chronological command log.
- `lib/widgets/` — one widget per zone in the layout above (`root_folder_section.dart`,
  `script_list_section.dart`, `script_detail_section.dart`, `console_section.dart`).
- `lib/l10n/` — `app_en.arb`/`app_it.arb` source strings; add a language by creating
  `lib/l10n/app_<locale>.arb` with matching keys. `lib/l10n/generated/` is build output — don't
  hand-edit it.

## Notes

- If a script has no detected parameters, the "Run" button executes it directly with no parameter
  prompt.
- Console log history is in-memory only and resets on app close (see README's "possible future
  extensions" for persisting it).