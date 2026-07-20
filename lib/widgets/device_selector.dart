import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/adb_device.dart';
import '../providers/adb_devices_provider.dart';

/// Shows the currently selected ADB device (icon + name) and, if more
/// than one is connected, lets the user pick another one from a menu.
/// If no device is ready, or `adb` is not on PATH, shows a disabled
/// indicator instead.
class DeviceSelector extends ConsumerWidget {
  const DeviceSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final adbState = ref.watch(adbDevicesProvider);

    if (!adbState.adbAvailable) {
      return _StatusChip(icon: Icons.usb_off, label: l10n.adbNotFound);
    }
    if (adbState.devices.isEmpty) {
      return _StatusChip(icon: Icons.phonelink_off, label: l10n.noDeviceConnected);
    }

    final selected = adbState.selectedDevice;

    return PopupMenuButton<String>(
      enabled: adbState.devices.length > 1,
      tooltip: l10n.selectDeviceTooltip,
      onSelected: (serial) => ref.read(adbDevicesProvider.notifier).selectDevice(serial),
      itemBuilder: (context) => [
        for (final device in adbState.devices)
          PopupMenuItem<String>(
            value: device.serial,
            enabled: device.isReady,
            child: Row(
              children: [
                Icon(_iconFor(device.kind), size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(device.displayName, overflow: TextOverflow.ellipsis)),
                if (!device.isReady) ...[
                  const SizedBox(width: 8),
                  Text(
                    _stateLabel(device.state, l10n),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                  ),
                ],
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_iconFor(selected?.kind ?? AdbDeviceKind.phone), size: 18),
            const SizedBox(width: 6),
            Text(selected?.displayName ?? '', style: theme.textTheme.bodySmall),
            if (adbState.devices.length > 1) ...[
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconFor(AdbDeviceKind kind) => switch (kind) {
        AdbDeviceKind.phone => Icons.smartphone,
        AdbDeviceKind.tablet => Icons.tablet_mac,
        AdbDeviceKind.tv => Icons.tv,
        AdbDeviceKind.wear => Icons.watch,
      };

  String _stateLabel(AdbConnectionState state, AppLocalizations l10n) => switch (state) {
        AdbConnectionState.unauthorized => l10n.deviceUnauthorized,
        AdbConnectionState.offline => l10n.deviceOffline,
        _ => l10n.deviceStateOther,
      };
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: theme.hintColor),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
      ],
    );
  }
}
