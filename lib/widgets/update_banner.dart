import 'dart:async';

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:dio/dio.dart';
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

class UpdateChecker {
  static const String repoOwner = 'awadyeg';
  static const String repoName = 'Awady-Music';
  static const String currentVersion = '1.0.0';

  static Future<AppUpdateInfo?> checkForUpdate({Dio? dio}) async {
    final client = dio ?? Dio();
    try {
      final res = await client.get<Map<String, dynamic>>(
        'https://api.github.com/repos/$repoOwner/$repoName/releases/latest',
        options: Options(
          headers: {'Accept': 'application/vnd.github.v3+json'},
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      final data = res.data;
      if (data == null) return null;
      final tagName = data['tag_name']?.toString() ?? '';
      final remoteVersion = tagName.replaceFirst(RegExp('^v'), '');
      if (remoteVersion.isEmpty) return null;

      if (_isNewer(remoteVersion, currentVersion)) {
        final assets = data['assets'];
        String? apkUrl;
        if (assets is List) {
          for (final a in assets) {
            if (a is Map) {
              final name = a['name']?.toString() ?? '';
              if (name.endsWith('.apk')) {
                apkUrl = a['browser_download_url']?.toString();
                break;
              }
            }
          }
        }
        apkUrl ??= data['html_url']?.toString() ?? '';
        return AppUpdateInfo(
          version: remoteVersion,
          downloadUrl: apkUrl,
          releaseNotes: data['body']?.toString(),
        );
      }
      return null;
    } on Object catch (_) {
      return null;
    }
  }

  static bool _isNewer(String remote, String current) {
    final rParts = remote.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final cParts = current.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    for (var i = 0; i < 3; i++) {
      final r = i < rParts.length ? rParts[i] : 0;
      final c = i < cParts.length ? cParts[i] : 0;
      if (r > c) return true;
      if (r < c) return false;
    }
    return false;
  }
}

class UpdateNotifier extends Notifier<AppUpdateInfo?> {
  @override
  AppUpdateInfo? build() => null;

  AppUpdateInfo? get updateInfo => state;

  set updateInfo(AppUpdateInfo? update) {
    state = update;
  }

  void dismiss() => state = null;

  Future<void> check({Dio? dio}) async {
    final update = await UpdateChecker.checkForUpdate(dio: dio);
    if (update != null) {
      state = update;
    }
  }
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
