/// Stato di connessione riportato da `adb devices -l`.
enum AdbConnectionState { device, unauthorized, offline, other }

/// Categoria hardware del device, dedotta da `ro.build.characteristics`.
/// Il default (prima della query, o se la query fallisce) è [phone].
enum AdbDeviceKind { phone, tablet, tv, wear }

/// Rappresenta un device ADB così come riportato da `adb devices -l`.
class AdbDevice {
  const AdbDevice({
    required this.serial,
    required this.state,
    this.model,
    this.product,
    this.kind = AdbDeviceKind.phone,
  });

  /// Serial del device, oppure "ip:porta" per i device di rete.
  final String serial;

  final AdbConnectionState state;
  final String? model;
  final String? product;
  final AdbDeviceKind kind;

  /// true solo se il device può ricevere comandi (stato "device").
  bool get isReady => state == AdbConnectionState.device;

  /// Nome leggibile mostrato in UI.
  String get displayName => model ?? product ?? serial;

  AdbDevice copyWith({AdbDeviceKind? kind}) => AdbDevice(
        serial: serial,
        state: state,
        model: model,
        product: product,
        kind: kind ?? this.kind,
      );
}
