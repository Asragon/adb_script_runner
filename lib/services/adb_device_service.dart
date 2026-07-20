import 'dart:io';

import '../models/adb_device.dart';

/// Wraps all calls to the `adb` binary for discovering connected
/// devices. No state or subscription handling here: that's the
/// responsibility of the provider that consumes this service.
class AdbDeviceService {
  /// Starts `adb track-devices` as a persistent process. The caller is
  /// responsible for listening to its stdout and killing it when no
  /// longer needed. Throws [ProcessException] if `adb` is not on PATH.
  Future<Process> startTrackDevices() {
    return Process.start('adb', ['track-devices']);
  }

  /// Runs `adb devices -l` and parses its output. Throws
  /// [ProcessException] if `adb` is not on PATH.
  Future<List<AdbDevice>> listDevices() async {
    final result = await Process.run('adb', ['devices', '-l']);
    return _parseDevicesOutput(result.stdout as String);
  }

  /// Queries a device's hardware category. On any error (device gone,
  /// command failed, empty output) returns [AdbDeviceKind.phone] as a
  /// safe default: the caller must never propagate exceptions from here,
  /// otherwise it would break the periodic device list refresh.
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
