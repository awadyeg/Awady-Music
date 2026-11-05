import 'dart:async';

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

@immutable
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.version,
    required this.downloadUrl,
    this.releaseNotes,
  });

  final String version;
  final String downloadUrl;
  final String? releaseNotes;
}

class UpdateNotifier extends Notifier<AppUpdateInfo?> {
  @override
  AppUpdateInfo? build() => null;

  AppUpdateInfo? get updateInfo => state;

  set updateInfo(AppUpdateInfo? update) {
    state = update;
  }

  void dismiss() => state = null;
}

final updateInfoProvider = NotifierProvider<UpdateNotifier, AppUpdateInfo?>(
  UpdateNotifier.new,
);

/// Glass card displayed at the top of the Home feed when an app update
/// is available
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final update = ref.watch(updateInfoProvider);
    if (update == null) return const SizedBox.shrink();

    final tokens = Theme.of(context).glass;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassSurface(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: tokens.accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.arrowUpCircle,
                color: tokens.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.appUpdateAvail} (v${update.version})',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
                  ),
                  if (update.releaseNotes != null &&
                      update.releaseNotes!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      update.releaseNotes!,
                      style: TextStyle(fontSize: 12, color: tokens.textDim),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Download button
            Semantics(
              button: true,
              label: l10n.appUpdateDownload,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: tokens.accent,
                  foregroundColor: tokens.onAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      GlassTokens.radiusCapsule,
                    ),
                  ),
                ),
                onPressed: () {
                  unawaited(
                    SharePlus.instance.share(
                      ShareParams(
                        text: update.downloadUrl,
                        subject: 'Awady Music Update v${update.version}',
                      ),
                    ),
                  );
                },
                child: Text(
                  l10n.appUpdateDownload,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Dismiss button
            IconButton(
              icon: Icon(LucideIcons.x, size: 18, color: tokens.textDim),
              tooltip: l10n.appDismissUpdate,
              onPressed: () => ref.read(updateInfoProvider.notifier).dismiss(),
            ),
          ],
        ),
      ),
    );
  }
}
