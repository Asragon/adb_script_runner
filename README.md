# ADB Script Runner

App desktop Flutter (Windows/macOS) per sfogliare ed eseguire script ADB
organizzati in cartelle.

## Come avviare il progetto

```bash
flutter pub get
flutter run -d windows   # oppure -d macos
```

Le localizzazioni (`AppLocalizations`) vengono generate automaticamente
grazie a `generate: true` in `pubspec.yaml` + `l10n.yaml`, quindi non
serve alcun comando aggiuntivo: basta `flutter pub get` / `flutter run`.
Se il tuo editor segnala che `l10n/generated/app_localizations.dart` non
esiste, lancia una volta `flutter gen-l10n`.

## Struttura del progetto

```
lib/
  core/
    theme/          -> AppColors + AppTheme: un solo punto per cambiare
                        palette/stile in tutta l'app
    constants/       -> costanti globali (estensioni script, ecc.)
    utils/           -> parsing dei parametri $1/%1 dagli script
  models/            -> RootFolder, ScriptModel, ScriptGroup, ConsoleEntry
  services/
    storage_service.dart        -> persistenza root folder (SharedPreferences)
    script_scanner_service.dart -> scansione cartella -> gruppi di script
    script_runner_service.dart  -> esecuzione script (bash/powershell/cmd)
  providers/         -> stato Riverpod (root folders, script, console, tema)
  screens/
    home_screen.dart -> layout principale a 4 zone
  widgets/
    root_folder_section.dart   -> in alto a sinistra: gestione cartelle
    script_list_section.dart   -> centro sinistra: lista script (gruppi/piatta)
    script_detail_section.dart -> basso sinistra: parametri + esecuzione
    console_section.dart       -> destra: log cronologico dei comandi
  l10n/
    app_en.arb, app_it.arb     -> stringhe multilingua (EN/IT)
```

## Note implementative

- **Persistenza root folder**: si usa `shared_preferences` per salvare la
  lista dei percorsi e quale sia quello attivo. È volutamente la
  soluzione più leggera possibile; se in futuro servisse salvare anche
  metadati più ricchi (es. script preferiti, storico esecuzioni su più
  sessioni) si può sostituire `StorageService` con un database locale
  (Hive/Isar) senza toccare il resto dell'app.

- **Scansione script**: ogni sottocartella immediata della root diventa
  un "gruppo"; gli script trovati direttamente nella root vengono
  raggruppati sotto l'etichetta "Generale"/"General" (localizzata).
  Estensioni riconosciute: `.sh`, `.bat`, `.cmd`, `.ps1`
  (`AppConstants.scriptExtensions`).

- **Parametri**: il contenuto di ogni script viene analizzato con una
  regex per individuare `$1`, `${1}` (stile bash) e `%1` (stile
  batch/Windows), fino a `9`. Se non trova parametri, il pulsante
  "Esegui" lancia lo script direttamente.

- **Esecuzione**: in base all'estensione, lo script viene lanciato con
  l'interprete corrispondente:
  - `.sh` → `bash` (richiede bash nel PATH, es. Git Bash o WSL su Windows)
  - `.ps1` → `powershell -ExecutionPolicy Bypass -File ...`
  - `.bat` / `.cmd` → `cmd /c ...`

  Se i tuoi script `.sh` chiamano `adb` internamente, assicurati che
  `adb.exe` sia nel PATH di sistema (o referenziato con percorso assoluto
  dentro lo script).

- **Stato/Riverpod**: nessun code-gen richiesto (si usano
  `StateNotifierProvider`/`StateProvider` "classici"), per tenere il
  progetto semplice da aprire e modificare subito.

- **Theming globale**: modifica `AppColors.seed` in
  `lib/core/theme/app_colors.dart` per cambiare il colore principale di
  tutta l'app (chiaro e scuro vengono derivati automaticamente).

- **Multilingua**: aggiungi una nuova lingua creando
  `lib/l10n/app_<codice>.arb` con le stesse chiavi di `app_en.arb`.

## Possibili estensioni future

- Storico esecuzioni persistente (oggi il log console si azzera alla
  chiusura dell'app).
- Ricerca/filtro testuale nella lista script.
- Visualizzazione elenco dispositivi ADB collegati (`adb devices`) in
  una sezione dedicata.
- Drag&drop di una cartella direttamente sulla finestra per aggiungerla
  come root folder.
