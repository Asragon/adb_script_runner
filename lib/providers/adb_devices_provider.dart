import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/adb_device.dart';
import '../services/adb_device_service.dart';

final adbDeviceServiceProvider =
    Provider<AdbDeviceService>((ref) => AdbDeviceService());

class AdbDevicesState {
  const AdbDevicesState({
    this.devices = const [],
    this.selectedSerial,
    this.adbAvailable = true,
  });

  final List<AdbDevice> devices;
  final String? selectedSerial;

  /// false if `adb` was not found on PATH.
  final bool adbAvailable;

  AdbDevice? get selectedDevice {
    for (final device in devices) {
      if (device.serial == selectedSerial) return device;
    }
    return null;
  }

  AdbDevicesState copyWith({
    List<AdbDevice>? devices,
    String? selectedSerial,
    bool clearSelected = false,
    bool? adbAvailable,
  }) {
    return AdbDevicesState(
      devices: devices ?? this.devices,
      selectedSerial:
          clearSelected ? null : (selectedSerial ?? this.selectedSerial),
      adbAvailable: adbAvailable ?? this.adbAvailable,
    );
  }
}

/// Keeps the list of connected ADB devices up to date by observing
/// `adb track-devices`: each event on its raw stdout (without parsing
/// its content) is just a "something changed" trigger that re-runs the
/// classic `adb devices -l`, whose output is the source of truth for the
/// state. Mirrors the lifecycle pattern of [ScriptsNotifier] (which
/// similarly starts a `Directory.watch` subscription in the constructor
/// and cancels it in dispose()).
class AdbDevicesNotifier extends StateNotifier<AdbDevicesState> {
  AdbDevicesNotifier(this._service) : super(const AdbDevicesState()) {
    _start();
  }

  final AdbDeviceService _service;

  Process? _trackProcess;
  StreamSubscription<List<int>>? _trackSubscription;
  Timer? _debounceTimer;

  final Map<String, AdbDeviceKind> _kindCache = {};
  final Set<String> _pendingKindFetches = {};

  final Map<String, String> _avdNameCache = {};
  final Set<String> _pendingAvdNameFetches = {};

  static const _debounceDelay = Duration(milliseconds: 300);

  Future<void> _start() async {
    await _refresh();

    try {
      _trackProcess = await _service.startTrackDevices();
      if (!mounted) {
        _trackProcess?.kill();
        return;
      }
      state = state.copyWith(adbAvailable: true);

      _trackSubscription = _trackProcess!.stdout.listen(
        (_) => _scheduleRefresh(),
        onError: (_) {},
        onDone: _scheduleRefresh,
      );
    } on ProcessException {
      if (!mounted) return;
      state = state.copyWith(
          adbAvailable: false, devices: const [], clearSelected: true);
    }
  }

  void _scheduleRefresh() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, _refresh);
  }

  Future<void> _refresh() async {
    try {
      final devices = await _service.listDevices();
      if (!mounted) return;

      final resolvedSelected = _resolveSelected(devices, state.selectedSerial);
      state = state.copyWith(
        devices: devices,
        selectedSerial: resolvedSelected,
        clearSelected: resolvedSelected == null,
        adbAvailable: true,
      );

      _refreshKindsIfNeeded(devices);
      _refreshAvdNamesIfNeeded(devices);
    } on ProcessException {
      if (!mounted) return;
      state = state.copyWith(
          adbAvailable: false, devices: const [], clearSelected: true);
    }
  }

  String? _resolveSelected(List<AdbDevice> devices, String? previous) {
    final ready = devices.where((d) => d.isReady).toList();
    if (previous != null && ready.any((d) => d.serial == previous))
      return previous;
    return ready.isEmpty ? null : ready.first.serial;
  }

  void _refreshKindsIfNeeded(List<AdbDevice> devices) {
    for (final device in devices) {
      if (!device.isReady) continue;

      final cachedKind = _kindCache[device.serial];
      if (cachedKind != null) {
        _applyKind(device.serial, cachedKind);
        continue;
      }
      if (_pendingKindFetches.contains(device.serial)) continue;

      _pendingKindFetches.add(device.serial);
      _service.getDeviceKind(device.serial).then((kind) {
        _pendingKindFetches.remove(device.serial);
        _kindCache[device.serial] = kind;
        if (mounted) _applyKind(device.serial, kind);
      });
    }
  }

  void _applyKind(String serial, AdbDeviceKind kind) {
    final updated = [
      for (final device in state.devices)
        if (device.serial == serial) device.copyWith(kind: kind) else device,
    ];
    state = state.copyWith(devices: updated);
  }

  void _refreshAvdNamesIfNeeded(List<AdbDevice> devices) {
    for (final device in devices) {
      if (!device.isReady) continue;
      if (!device.serial.startsWith('emulator-')) continue;

      final cachedName = _avdNameCache[device.serial];
      if (cachedName != null) {
        _applyAvdName(device.serial, cachedName);
        continue;
      }
      if (_pendingAvdNameFetches.contains(device.serial)) continue;

      _pendingAvdNameFetches.add(device.serial);
      _service.getAvdName(device.serial).then((name) {
        _pendingAvdNameFetches.remove(device.serial);
        if (name == null) return;
        _avdNameCache[device.serial] = name;
        if (mounted) _applyAvdName(device.serial, name);
      });
    }
  }

  void _applyAvdName(String serial, String avdName) {
    final updated = [
      for (final device in state.devices)
        if (device.serial == serial)
          device.copyWith(avdName: avdName)
        else
          device,
    ];
    state = state.copyWith(devices: updated);
  }

  /// Manual selection by the user (menu in [DeviceSelector]).
  void selectDevice(String serial) {
    final exists = state.devices.any((d) => d.serial == serial && d.isReady);
    if (!exists) return;
    state = state.copyWith(selectedSerial: serial);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _trackSubscription?.cancel();
    _trackProcess?.kill();
    super.dispose();
  }
}

final adbDevicesProvider =
    StateNotifierProvider<AdbDevicesNotifier, AdbDevicesState>((ref) {
  return AdbDevicesNotifier(ref.watch(adbDeviceServiceProvider));
});
