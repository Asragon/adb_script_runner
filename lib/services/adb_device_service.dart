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

  /// Queries the AVD name of an emulator (e.g. "Pixel 10 Pro XL API 37"),
  /// via the emulator console's `avd name` command. Only meaningful for
  /// emulators (serials starting with "emulator-"); the caller is
  /// responsible for skipping physical devices. Returns null on any
  /// error (emulator not ready, command failed, empty output) so the
  /// caller falls back to the build model/product.
  Future<String?> getAvdName(String serial) async {
    try {
      final result = await Process.run('adb', ['-s', serial, 'emu', 'avd', 'name']);
      final lines = (result.stdout as String)
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty && line != 'OK')
          .toList();
      if (lines.isEmpty) return null;
      return lines.first.replaceAll('_', ' ');
    } catch (_) {
      return null;
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
