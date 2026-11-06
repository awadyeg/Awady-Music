import 'dart:async';

import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/player/cast_service.dart';
import 'package:awady_music/player/connect_client.dart';
import 'package:awady_music/widgets/glass_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Shows the Cast / Chromecast media output bottom sheet.
Future<void> showCastSheet(BuildContext context) {
  return showGlassBottomSheet<void>(
    context: context,
    builder: (ctx) => const _CastSheetContent(),
  );
}

class _CastSheetContent extends ConsumerStatefulWidget {
  const _CastSheetContent();

  @override
  ConsumerState<_CastSheetContent> createState() => _CastSheetContentState();
}

class _CastSheetContentState extends ConsumerState<_CastSheetContent> {
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
    final connected = castState.connectedDevice;

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
                          connectState.isConnected
                              ? 'Awady Connect • Playing on TV'
                              : 'Connected',
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
                onTap: () {
                  castNotifier.connect(device);
                  if (device.model == 'Awady TV Receiver') {
                    unawaited(connectNotifier.connectTo(device));
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
            const SizedBox(height: 12),
          ],
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.bgElevated,
              foregroundColor: tokens.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: tokens.glassStroke),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(LucideIcons.radio, size: 18),
            label: const Text(
              'System Cast & Media Output',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              unawaited(castNotifier.openSystemCastSettings());
            },
          ),
        ],
      ),
    );
  }
}
