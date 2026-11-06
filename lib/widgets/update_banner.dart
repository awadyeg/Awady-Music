import 'dart:async';
import 'dart:io';

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/glass.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

@immutable
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.version,
    required this.downloadUrl,
    this.releaseNotes,
    this.isNewer = true,
  });

  final String version;
  final String downloadUrl;
  final String? releaseNotes;
  final bool isNewer;
}

class UpdateChecker {
  static const String repoOwner = 'awadyeg';
  static const String repoName = 'Awady-Music';
  static const String currentVersion = '1.0.4';

  static Future<AppUpdateInfo?> checkForUpdate({
    Dio? dio,
    bool includeCurrent = false,
  }) async {
    final client = dio ?? Dio();
    try {
      Map<String, dynamic>? data;
      try {
        final res = await client.get<Map<String, dynamic>>(
          'https://api.github.com/repos/$repoOwner/$repoName/releases/latest',
          options: Options(
            headers: {'Accept': 'application/vnd.github.v3+json'},
            sendTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 8),
          ),
        );
        data = res.data;
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          final listRes = await client.get<List<dynamic>>(
            'https://api.github.com/repos/$repoOwner/$repoName/releases',
            options: Options(
              headers: {'Accept': 'application/vnd.github.v3+json'},
              sendTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
            ),
          );
          if (listRes.data != null && listRes.data!.isNotEmpty) {
            data = listRes.data!.first as Map<String, dynamic>?;
          }
        } else {
          rethrow;
        }
      }

      if (data == null) {
        if (includeCurrent) {
          return const AppUpdateInfo(
            version: currentVersion,
            downloadUrl:
                'https://github.com/$repoOwner/$repoName/releases/latest/download/app-arm64-v8a-release.apk',
            releaseNotes: 'Awady Music v$currentVersion — latest version.',
            isNewer: false,
          );
        }
        return null;
      }
      final tagName = data['tag_name']?.toString() ?? '';
      final remoteVersion = tagName.replaceFirst(RegExp('^v'), '');
      if (remoteVersion.isEmpty) return null;

      final isNewer = _isNewer(remoteVersion, currentVersion);
      if (isNewer || includeCurrent) {
        final assets = data['assets'];
        String? apkUrl;
        if (assets is List) {
          for (final a in assets) {
            if (a is Map) {
              final name = a['name']?.toString() ?? '';
              if (name.contains('arm64') && name.endsWith('.apk')) {
                apkUrl = a['browser_download_url']?.toString();
                break;
              }
            }
          }
          if (apkUrl == null) {
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
        }
        apkUrl ??= data['html_url']?.toString() ?? '';
        return AppUpdateInfo(
          version: remoteVersion,
          downloadUrl: apkUrl,
          releaseNotes: data['body']?.toString(),
          isNewer: isNewer,
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

/// Opens a confirmation dialog allowing the user to view details and install
/// the APK update.
Future<void> showUpdateConfirmDialog(
  BuildContext context,
  AppUpdateInfo info,
) async {
  await showDialog<void>(
    context: context,
    builder: (ctx) => _UpdateConfirmDialog(info: info),
  );
}

class _UpdateConfirmDialog extends StatefulWidget {
  const _UpdateConfirmDialog({required this.info});

  final AppUpdateInfo info;

  @override
  State<_UpdateConfirmDialog> createState() => _UpdateConfirmDialogState();
}

class _UpdateConfirmDialogState extends State<_UpdateConfirmDialog> {
  static const MethodChannel _updaterChannel = MethodChannel(
    'com.awady.awady_music/updater',
  );

  bool _isDownloading = false;
  double _progress = 0;
  String? _errorMessage;

  Future<void> _startDownloadAndInstall() async {
    setState(() {
      _isDownloading = true;
      _progress = 0;
      _errorMessage = null;
    });

    try {
      final dio = Dio();
      Directory tempDir;
      try {
        tempDir = await getTemporaryDirectory();
      } on Object catch (_) {
        tempDir = Directory.systemTemp;
      }
      final apkFile = File(
        '${tempDir.path}/awady-music-v${widget.info.version}.apk',
      );

      await dio.download(
        widget.info.downloadUrl,
        apkFile.path,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() {
              _progress = (received / total).clamp(0.0, 1.0);
            });
          }
        },
      );

      if (!mounted) return;

      if (defaultTargetPlatform == TargetPlatform.android) {
        await _updaterChannel.invokeMethod<void>('installApk', {
          'filePath': apkFile.path,
        });
        if (mounted) Navigator.of(context).pop();
      } else {
        await SharePlus.instance.share(
          ShareParams(
            text: widget.info.downloadUrl,
            subject: 'Awady Music Update v${widget.info.version}',
          ),
        );
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;
    final l10n = context.l10n;
    final notes = widget.info.releaseNotes?.trim();

    return AlertDialog(
      title: Text('Awady Music v${widget.info.version}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.info.isNewer)
              Text(
                l10n.appUpdateAvail,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: tokens.accent,
                ),
              )
            else
              Text(
                l10n.settingsUpdateLatest,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: tokens.accent,
                ),
              ),
            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                notes,
                style: TextStyle(fontSize: 13, color: tokens.textDim),
              ),
            ],
            if (_isDownloading) ...[
              const SizedBox(height: 18),
              LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
                color: tokens.accent,
                backgroundColor: tokens.glassFill,
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '${(_progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: tokens.textPrimary,
                  ),
                ),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 12, color: Colors.redAccent),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isDownloading ? null : () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: _isDownloading ? null : _startDownloadAndInstall,
          child: Text(_isDownloading ? 'Downloading...' : 'Confirm & Install'),
        ),
      ],
    );
  }
}

/// Glass card displayed at the top of the Home feed when an app update
/// is available
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final update = ref.watch(updateInfoProvider);
    if (update == null || !update.isNewer) return const SizedBox.shrink();

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
                  unawaited(showUpdateConfirmDialog(context, update));
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
