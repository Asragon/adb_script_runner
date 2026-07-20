import 'dart:io';

import '../models/adb_device.dart';

/// Incapsula tutte le chiamate al binario `adb` per la scoperta dei device
/// connessi. Nessuna gestione di stato o subscription qui: quella è
/// responsabilità del provider che consuma questo service.
class AdbDeviceService {
  /// Avvia `adb track-devices` come processo persistente. Il chiamante è
  /// responsabile di ascoltarne lo stdout e di terminarlo quando non serve
  /// più. Lancia [ProcessException] se `adb` non è nel PATH.
  Future<Process> startTrackDevices() {
    return Process.start('adb', ['track-devices']);
  }

  /// Esegue `adb devices -l` e ne parsa l'output. Lancia [ProcessException]
  /// se `adb` non è nel PATH.
  Future<List<AdbDevice>> listDevices() async {
    final result = await Process.run('adb', ['devices', '-l']);
    return _parseDevicesOutput(result.stdout as String);
  }

  /// Interroga la categoria hardware di un device. In caso di qualunque
  /// errore (device sparito, comando fallito, output vuoto) ritorna
  /// [AdbDeviceKind.phone] come default sicuro: il chiamante non deve mai
  /// propagare eccezioni da qui, altrimenti romperebbe il refresh
  /// periodico della lista device.
  Future<AdbDeviceKind> getDeviceKind(String serial) async {
    try {
      final result = await Process.run(
        'adb',
        ['-s', serial, 'shell', 'getprop', 'ro.build.characteristics'],
      );
      final raw = (result.stdout as String).toLowerCase();
      if (raw.contains('tv')) return AdbDeviceKind.tv;
      if (raw.contains('watch')) return AdbDeviceKind.wear;
      if (raw.contains('tablet')) return AdbDeviceKind.tablet;
      return AdbDeviceKind.phone;
    } catch (_) {
      return AdbDeviceKind.phone;
    }
  }

  List<AdbDevice> _parseDevicesOutput(String output) {
    final devices = <AdbDevice>[];

    for (final rawLine in output.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      if (line == 'List of devices attached') continue;
      if (line.startsWith('*')) continue;

      final tokens = line.split(RegExp(r'\s+'));
      if (tokens.length < 2) continue;

      final serial = tokens[0];
      final state = switch (tokens[1]) {
        'device' => AdbConnectionState.device,
        'unauthorized' => AdbConnectionState.unauthorized,
        'offline' => AdbConnectionState.offline,
        _ => AdbConnectionState.other,
      };

      final fields = <String, String>{};
      for (final token in tokens.skip(2)) {
        final separatorIndex = token.indexOf(':');
        if (separatorIndex <= 0) continue;
        fields[token.substring(0, separatorIndex)] =
            token.substring(separatorIndex + 1);
      }

      devices.add(AdbDevice(
        serial: serial,
        state: state,
        model: fields['model'],
        product: fields['product'],
      ));
    }

    return devices;
  }
}
