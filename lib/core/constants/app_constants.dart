/// Costanti globali dell'applicazione.
class AppConstants {
  const AppConstants._();

  /// Estensioni di file riconosciute come "script eseguibili".
  static const List<String> scriptExtensions = ['.sh', '.bat', '.cmd', '.ps1'];

  /// Dimensioni minime consigliate per la finestra desktop.
  static const double minWindowWidth = 1100;
  static const double minWindowHeight = 700;
}
