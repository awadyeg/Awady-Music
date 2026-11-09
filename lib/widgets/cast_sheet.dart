import 'dart:async';

import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/player/cast_service.dart';
import 'package:awady_music/player/chromecast_client.dart';
import 'package:awady_music/player/connect_client.dart';
import 'package:awady_music/widgets/glass_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shows the Cast / Chromecast media output bottom sheet.
Future<void> showCastSheet(BuildContext context) {
  return showGlassBottomSheet<void>(
    context: context,
    builder: (ctx) => const CastSheetContent(),
  );
}

class CastSheetContent extends ConsumerStatefulWidget {
  const CastSheetContent({super.key});

  @override
  ConsumerState<CastSheetContent> createState() => _CastSheetContentState();
}

class _CastSheetContentState extends ConsumerState<CastSheetContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(castProvider.notifier).startDiscovery());
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;
    final castState = ref.watch(castProvider);
    final castNotifier = ref.read(castProvider.notifier);
    final connectState = ref.watch(connectClientProvider);
    final connectNotifier = ref.read(connectClientProvider.notifier);
    final chromecastState = ref.watch(chromecastClientProvider);
    final chromecastNotifier = ref.read(chromecastClientProvider.notifier);
    final connected = castState.connectedDevice;

    final isAwadyConnect = connectState.isConnected;
    final isChromecast = chromecastState.isConnected;
    final statusText = (isAwadyConnect || isChromecast)
        ? 'Awady Music • Playing on TV'
        : 'Connected';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(LucideIcons.cast, color: tokens.accent, size: 22),
              const SizedBox(width: 12),
              Text(
                'Cast / Media Output',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: tokens.textPrimary,
                ),
              ),
              const Spacer(),
              if (castState.isScanning)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: const Icon(LucideIcons.refreshCw, size: 18),
                  tooltip: 'Scan for devices',
                  onPressed: castNotifier.startDiscovery,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (connected != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: tokens.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: tokens.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.tv,
                    color: Color(0xFF10B981),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          connected.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: tokens.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          statusText,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      castNotifier.disconnect();
                      connectNotifier.disconnect();
                      chromecastNotifier.disconnect();
                    },
                    child: const Text('Disconnect'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (castState.devices.isNotEmpty) ...[
            Text(
              'Discovered Devices',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: tokens.textDim,
              ),
            ),
            const SizedBox(height: 8),
            for (final device in castState.devices) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  device.model == 'Awady Music' ||
                          device.model == 'Awady TV Receiver'
                      ? LucideIcons.tv
                      : LucideIcons.cast,
                  color: tokens.accent,
                  size: 20,
                ),
                title: Text(
                  device.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '${device.host} • ${device.model}',
                  style: TextStyle(fontSize: 12, color: tokens.textDim),
                ),
                trailing: connected?.id == device.id
                    ? const Icon(
                        LucideIcons.check,
                        color: Color(0xFF10B981),
                        size: 18,
                      )
                    : null,
                onTap: () async {
                  castNotifier.connect(device);
                  Navigator.of(context).pop();
                  final awadyDevice = CastDevice(
                    id: device.id,
                    name: device.name,
                    host: device.host,
                    port: device.model == 'Awady Music' ? device.port : 8654,
                    model: 'Awady Music',
                  );
                  final ok = await connectNotifier.connectTo(awadyDevice);
                  if (!ok) {
                    unawaited(chromecastNotifier.connectTo(device));
                  }
                },
              ),
            ],
            const SizedBox(height: 12),
          ],
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: tokens.textPrimary,
              side: BorderSide(color: tokens.glassStroke),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            icon: const Icon(LucideIcons.globe, size: 18),
            label: const Text(
              'Connect via IP Address',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            onPressed: _showManualIpDialog,
          ),
        ],
      ),
    );
  }

  Future<void> _showManualIpDialog() async {
    final controller = TextEditingController();
    final ip = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final tokens = Theme.of(ctx).glass;
        return AlertDialog(
          backgroundColor: tokens.bgElevated,
          title: Text(
            'Connect to Smart TV / Cast IP',
            style: TextStyle(color: tokens.textPrimary, fontSize: 16),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.url,
            style: TextStyle(color: tokens.textPrimary),
            decoration: InputDecoration(
              hintText: '192.168.1.50',
              hintStyle: TextStyle(color: tokens.textDim),
              labelText: 'IP Address',
              labelStyle: TextStyle(color: tokens.accent),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              child: const Text('Connect'),
            ),
          ],
        );
      },
    );

    if (ip != null && ip.isNotEmpty && mounted) {
      final device = CastDevice(
        id: ip,
        name: 'Cast TV ($ip)',
        host: ip,
        port: 8654,
        model: 'Awady Music',
      );
      ref.read(castProvider.notifier).connect(device);
      Navigator.of(context).pop();
      final ok = await ref
          .read(connectClientProvider.notifier)
          .connectTo(device);
      if (!ok) {
        unawaited(
          ref.read(chromecastClientProvider.notifier).connectTo(device),
        );
      }
    }
  }
}
