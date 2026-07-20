/// Connection state reported by `adb devices -l`.
enum AdbConnectionState { device, unauthorized, offline, other }

/// Hardware category of the device, inferred from
/// `ro.build.characteristics`. The default (before the query, or if the
/// query fails) is [phone].
enum AdbDeviceKind { phone, tablet, tv, wear }

/// Represents an ADB device as reported by `adb devices -l`.
class AdbDevice {
  const AdbDevice({
    required this.serial,
    required this.state,
    this.model,
    this.product,
    this.kind = AdbDeviceKind.phone,
    this.avdName,
  });

  /// Device serial, or "ip:port" for network devices.
  final String serial;

  final AdbConnectionState state;
  final String? model;
  final String? product;
  final AdbDeviceKind kind;

  /// AVD name for emulators (e.g. "Pixel 10 Pro XL API 37"), resolved
  /// asynchronously via the emulator console (`adb emu avd name`) since
  /// `adb devices -l` only reports the generic build model/product. Null
  /// for physical devices, or before it's been resolved.
  final String? avdName;

  /// true only if the device can receive commands (state "device").
  bool get isReady => state == AdbConnectionState.device;

  /// Human-readable name shown in the UI. Prefers the AVD name for
  /// emulators, which is far more recognizable than the generic build
  /// model/product (e.g. "sdk_gphone16k_x86_64"), falling back to
  /// model/product/serial.
  String get displayName => avdName ?? model ?? product ?? serial;

  AdbDevice copyWith({AdbDeviceKind? kind, String? avdName}) => AdbDevice(
        serial: serial,
        state: state,
        model: model,
        product: product,
        kind: kind ?? this.kind,
        avdName: avdName ?? this.avdName,
      );
}
