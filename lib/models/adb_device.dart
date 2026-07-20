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
  });

  /// Device serial, or "ip:port" for network devices.
  final String serial;

  final AdbConnectionState state;
  final String? model;
  final String? product;
  final AdbDeviceKind kind;

  /// true only if the device can receive commands (state "device").
  bool get isReady => state == AdbConnectionState.device;

  /// Human-readable name shown in the UI.
  String get displayName => model ?? product ?? serial;

  AdbDevice copyWith({AdbDeviceKind? kind}) => AdbDevice(
        serial: serial,
        state: state,
        model: model,
        product: product,
        kind: kind ?? this.kind,
      );
}
