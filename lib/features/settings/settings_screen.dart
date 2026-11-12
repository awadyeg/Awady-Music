import 'dart:async';

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/core/util/log.dart';
import 'package:awady_music/data/repositories/backup_repository.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/data/repositories/stats_repository.dart';
import 'package:awady_music/data/sources/youtube/yt_account_importer.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/widgets/equalizer_sheet.dart';
import 'package:awady_music/widgets/glass_toast.dart';
import 'package:awady_music/widgets/import_sheet.dart';
import 'package:awady_music/widgets/large_title_scaffold.dart';
import 'package:awady_music/widgets/section_header.dart';
import 'package:awady_music/widgets/update_banner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Settings screen organizing user preferences into Playback, Appearance,
/// Library & storage, and About sections.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _checkingUpdates = false;

  void _showToast(String message, [IconData? icon]) {
    ref.read(toastProvider.notifier).show(message, icon: icon);
  }

  Future<void> _checkUpdates(L10n l10n) async {
    setState(() => _checkingUpdates = true);
    final info = await UpdateChecker.checkForUpdate(includeCurrent: true);
    if (mounted) {
      setState(() => _checkingUpdates = false);
      if (info != null) {
        if (info.isNewer) {
          ref.read(updateInfoProvider.notifier).updateInfo = info;
        }
        _showToast(
          info.isNewer
              ? l10n.settingsUpdateAvailable(info.version)
              : l10n.settingsUpdateLatest,
          info.isNewer ? LucideIcons.download : LucideIcons.check,
        );
        unawaited(showUpdateConfirmDialog(context, info));
      } else {
        _showToast(l10n.settingsUpdateLatest, LucideIcons.check);
      }
    }
  }

  void _clearCache(L10n l10n) {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    _showToast(l10n.settingsCacheCleared, LucideIcons.check);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;
    final l10n = context.l10n;
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final playerState = ref.watch(playerControllerProvider);
    final playerNotifier = ref.read(playerControllerProvider.notifier);
    final libraryRepo = ref.watch(libraryRepositoryProvider);

    final likedCount = libraryRepo.likedTracks.length;
    final playlistCount = libraryRepo.playlists.length;

    return LargeTitleScaffold(
      title: l10n.settingsTitle,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 0. Profile Section
                const SectionHeader(title: 'Profile'),
                _buildCard(
                  tokens: tokens,
                  children: [
                    _buildNavTile(
                      icon: LucideIcons.user,
                      title: 'Your Name',
                      subtitle: settings.userName.isNotEmpty
                          ? settings.userName
                          : 'Set your name for personalized greetings',
                      tokens: tokens,
                      onTap: () {
                        unawaited(_editUserName(context, settings.userName));
                      },
                    ),
                    _buildDivider(tokens),
                    _buildNavTile(
                      icon: LucideIcons.globe,
                      title: 'Google / YouTube Music Account',
                      subtitle: settings.ytmLoggedIn
                          ? 'Connected • Tap to sync or disconnect'
                          : 'Not connected • Tap to sign in and auto-sync',
                      tokens: tokens,
                      onTap: () {
                        unawaited(_showYtmAccountSheet(context, settings));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 1. Playback Section
                SectionHeader(title: l10n.settingsPlayback),
                _buildCard(
                  tokens: tokens,
                  children: [
                    // Autoplay switch
                    _buildSwitchTile(
                      title: l10n.settingsAutoplay,
                      value: settings.autoplay,
                      tokens: tokens,
                      subtitle: l10n.settingsAutoplaySub,
                      onChanged: (val) {
                        unawaited(settingsNotifier.setAutoplay(autoplay: val));
                        playerNotifier.setAutoplay(value: val);
                      },
                    ),
                    _buildDivider(tokens),

                    // Normalize volume
                    _buildSwitchTile(
                      title: l10n.eqNormalize,
                      value: playerState.normOn,
                      tokens: tokens,
                      subtitle: 'Automatic gain control',
                      onChanged: (val) {
                        playerNotifier.setNormOn(value: val);
                      },
                    ),
                    _buildDivider(tokens),

                    // Crossfade
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.eqCrossfade,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: tokens.textPrimary,
                                ),
                              ),
                              Text(
                                playerState.fadeSecs == 0
                                    ? l10n.eqOff
                                    : '${playerState.fadeSecs}s',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: playerState.fadeSecs > 0
                                      ? tokens.accent
                                      : tokens.textDim,
                                ),
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: tokens.accent,
                              inactiveTrackColor: tokens.glassStroke,
                              thumbColor: tokens.accent,
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                            ),
                            child: Slider(
                              value: playerState.fadeSecs.toDouble(),
                              max: 12,
                              divisions: 12,
                              onChanged: (val) {
                                playerNotifier.setFadeSecs(val.round());
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Equalizer (Android only)
                    if (defaultTargetPlatform == TargetPlatform.android) ...[
                      _buildDivider(tokens),
                      _buildNavTile(
                        icon: LucideIcons.sliders,
                        title: l10n.eqTitle,
                        tokens: tokens,
                        onTap: () {
                          unawaited(EqualizerSheet.show(context));
                        },
                      ),
                    ],

                    _buildDivider(tokens),
                    // Wi-Fi only downloads
                    _buildSwitchTile(
                      title: l10n.wifiOnlyDownloads,
                      value: settings.wifiOnlyDownloads,
                      tokens: tokens,
                      onChanged: (val) {
                        unawaited(
                          ref
                              .read(settingsProvider.notifier)
                              .setWifiOnlyDownloads(wifiOnly: val),
                        );
                      },
                    ),
                    _buildDivider(tokens),
                    // Auto-download liked songs
                    _buildSwitchTile(
                      title: 'Auto-download liked songs',
                      subtitle: 'Save favorite tracks offline automatically',
                      value: settings.autoDownloadLikes,
                      tokens: tokens,
                      onChanged: (val) {
                        unawaited(
                          ref
                              .read(settingsProvider.notifier)
                              .setAutoDownloadLikes(enabled: val),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Claude Code AI Section
                const SectionHeader(title: 'Claude Code AI'),
                _buildCard(
                  tokens: tokens,
                  children: [
                    _buildSwitchTile(
                      title: 'Claude AI Recommendations & Mixes',
                      subtitle:
                          'Smart recommendations, mixes & similar search songs',
                      value: settings.enableClaudeAi,
                      tokens: tokens,
                      onChanged: (val) {
                        unawaited(
                          settingsNotifier.setEnableClaudeAi(enabled: val),
                        );
                      },
                    ),
                    _buildDivider(tokens),
                    _buildNavTile(
                      icon: LucideIcons.sparkles,
                      title: 'Claude Code API Configuration',
                      subtitle: settings.claudeApiKey.isNotEmpty
                          ? 'API Key set (${settings.claudeModel})'
                          : 'Built-in AI active • Tap to set Claude API Key',
                      tokens: tokens,
                      onTap: () {
                        unawaited(_configureClaudeAi(context, settings));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Appearance Section
                SectionHeader(title: l10n.themeMode),
                _buildCard(
                  tokens: tokens,
                  children: [
                    // Theme picker
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.themeMode,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: tokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SegmentedButton<ThemeMode>(
                            segments: [
                              ButtonSegment(
                                value: ThemeMode.system,
                                label: Text(l10n.themeSystem),
                                icon: const Icon(
                                  LucideIcons.smartphone,
                                  size: 14,
                                ),
                              ),
                              ButtonSegment(
                                value: ThemeMode.light,
                                label: Text(l10n.themeLight),
                                icon: const Icon(LucideIcons.sun, size: 14),
                              ),
                              ButtonSegment(
                                value: ThemeMode.dark,
                                label: Text(l10n.themeDark),
                                icon: const Icon(LucideIcons.moon, size: 14),
                              ),
                            ],
                            selected: {settings.themeMode},
                            onSelectionChanged: (selection) {
                              unawaited(
                                settingsNotifier.setThemeMode(selection.first),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(tokens),

                    // Reduce transparency
                    _buildSwitchTile(
                      title: l10n.reduceTransparency,
                      subtitle: l10n.reduceTransparencySubtitle,
                      value: settings.reduceTransparency,
                      tokens: tokens,
                      onChanged: (val) {
                        unawaited(
                          settingsNotifier.setReduceTransparency(reduce: val),
                        );
                      },
                    ),
                    _buildDivider(tokens),

                    // Language picker
                    _buildNavTile(
                      icon: LucideIcons.languages,
                      title: l10n.settingsLanguage,
                      subtitle: _languageName(settings.locale),
                      tokens: tokens,
                      onTap: () => _showLanguageDialog(context),
                    ),
                    _buildDivider(tokens),

                    // Country / Region picker
                    _buildNavTile(
                      icon: LucideIcons.globe,
                      title: _countrySettingTitle(
                        Localizations.localeOf(context).languageCode,
                      ),
                      subtitle: _countryDisplayName(
                        settings.countryCode,
                        Localizations.localeOf(context).languageCode,
                      ),
                      tokens: tokens,
                      onTap: () => _showCountryDialog(context),
                    ),
                    _buildDivider(tokens),

                    // TV Mode launcher & settings
                    _buildNavTile(
                      icon: LucideIcons.tv,
                      title: 'Android TV Mode',
                      subtitle: switch (settings.tvMode) {
                        'on' => 'Always on (TV UI)',
                        'off' => 'Disabled',
                        _ => 'Auto-detect big screens',
                      },
                      tokens: tokens,
                      onTap: () => _showTvModeDialog(context, settings),
                    ),
                    _buildDivider(tokens),

                    // Connect receiver switch
                    _buildSwitchTile(
                      title: 'Awady Connect Receiver',
                      subtitle:
                          'Accept Cast & remote control from phones on Wi-Fi',
                      value: settings.enableConnectReceiver,
                      tokens: tokens,
                      onChanged: (val) {
                        unawaited(
                          ref
                              .read(settingsProvider.notifier)
                              .setEnableConnectReceiver(enabled: val),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Library & Storage Section
                SectionHeader(title: l10n.settingsLibrary),
                _buildCard(
                  tokens: tokens,
                  children: [
                    // Stats readout
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.database,
                            size: 18,
                            color: tokens.textDim,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.settingsLibraryStats(
                                likedCount.toString(),
                                playlistCount.toString(),
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                color: tokens.textDim,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(tokens),

                    // Import playlists from Spotify
                    _buildNavTile(
                      icon: LucideIcons.listMusic,
                      title: _spotifyImportPlaylistsTitle(
                        Localizations.localeOf(context).languageCode,
                      ),
                      subtitle: l10n.importUrlHint,
                      tokens: tokens,
                      onTap: () => unawaited(showImportSheet(context)),
                    ),
                    _buildDivider(tokens),

                    // Import Liked Songs from Spotify
                    _buildNavTile(
                      icon: LucideIcons.heart,
                      title: _spotifyImportLikesTitle(
                        Localizations.localeOf(context).languageCode,
                      ),
                      subtitle: _spotifyImportLikesSub(
                        Localizations.localeOf(context).languageCode,
                      ),
                      tokens: tokens,
                      onTap: () => unawaited(
                        showImportSheet(
                          context,
                          initialDestination: ImportDestination.liked,
                        ),
                      ),
                    ),
                    _buildDivider(tokens),

                    // Export library & stats
                    _buildNavTile(
                      icon: LucideIcons.share2,
                      title: l10n.settingsExport,
                      tokens: tokens,
                      onTap: () async {
                        try {
                          ref.read(statsRepositoryProvider).flush();
                          await ref
                              .read(backupRepositoryProvider)
                              .exportAndShare();
                          _showToast(
                            l10n.settingsBackupExported,
                            LucideIcons.check,
                          );
                        } on Object catch (_) {
                          _showToast(
                            l10n.settingsExportFailed,
                            LucideIcons.alertCircle,
                          );
                        }
                      },
                    ),
                    _buildDivider(tokens),

                    // Import backup
                    _buildNavTile(
                      icon: LucideIcons.fileInput,
                      title: l10n.importBackup,
                      tokens: tokens,
                      onTap: () async {
                        try {
                          final res = await ref
                              .read(backupRepositoryProvider)
                              .pickAndImportBackup();
                          if (res != null) {
                            if (res.success) {
                              _showToast(
                                l10n.importBackupSuccess,
                                LucideIcons.check,
                              );
                            } else {
                              _showToast(
                                res.error ?? l10n.importFailed,
                                LucideIcons.alertCircle,
                              );
                            }
                          }
                        } on Object catch (_) {
                          _showToast(
                            l10n.importFailed,
                            LucideIcons.alertCircle,
                          );
                        }
                      },
                    ),
                    _buildDivider(tokens),

                    // Clear cache
                    _buildNavTile(
                      icon: LucideIcons.trash2,
                      title: l10n.settingsClearCache,
                      tokens: tokens,
                      onTap: () => _clearCache(l10n),
                    ),
                    _buildDivider(tokens),

                    // Open logs
                    _buildNavTile(
                      icon: LucideIcons.fileText,
                      title: l10n.settingsOpenLogs,
                      tokens: tokens,
                      onTap: () {
                        final logs = Log.getLogFiles();
                        final totalBytes = logs.fold<int>(
                          0,
                          (sum, f) =>
                              sum + (f.existsSync() ? f.lengthSync() : 0),
                        );
                        _showToast(
                          '${logs.length} log files '
                          '(${(totalBytes / 1024).toStringAsFixed(1)} KB)',
                          LucideIcons.fileText,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 4. About Section
                SectionHeader(title: l10n.settingsAbout),
                _buildCard(
                  tokens: tokens,
                  children: [
                    // App info
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: tokens.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: tokens.accent.withValues(alpha: 0.3),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              'assets/icon/app_icon.png',
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Icon(
                                LucideIcons.music,
                                color: tokens.accent,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Awady Music',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: tokens.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'v1.0.14 (build 14)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: tokens.textDim,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(tokens),

                    // Check for updates
                    _buildNavTile(
                      icon: LucideIcons.refreshCw,
                      title: _checkingUpdates
                          ? l10n.settingsChecking
                          : l10n.settingsCheckUpdates,
                      tokens: tokens,
                      onTap: _checkingUpdates
                          ? null
                          : () => _checkUpdates(l10n),
                    ),
                  ],
                ),
                const SizedBox(height: 140),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _languageName(Locale? locale) {
    if (locale == null) return 'System default';
    return switch (locale.languageCode) {
      'es' => 'Español',
      'ar' => 'العربية',
      _ => 'English',
    };
  }

  String _countrySettingTitle(String langCode) {
    return switch (langCode) {
      'ar' => 'الدولة والمنطقة (التوصيات)',
      'es' => 'País y región (recomendaciones)',
      _ => 'Country & Region (Recommendations)',
    };
  }

  String _countryDisplayName(String code, String langCode) {
    final c = findMusicCountry(code);
    return '${c.flag} ${c.localizedName(langCode)} (${c.code})';
  }

  String _spotifyImportPlaylistsTitle(String langCode) {
    return switch (langCode) {
      'ar' => 'استيراد قوائم التشغيل من Spotify',
      'es' => 'Importar playlists de Spotify',
      _ => 'Import Playlists from Spotify',
    };
  }

  String _spotifyImportLikesTitle(String langCode) {
    return switch (langCode) {
      'ar' => 'استيراد الأغاني المفضلة من Spotify',
      'es' => 'Importar canciones que te gustan de Spotify',
      _ => 'Import Likes from Spotify',
    };
  }

  String _spotifyImportLikesSub(String langCode) {
    return switch (langCode) {
      'ar' => 'عبر رابط قائمة تشغيل أو ملف CSV / YourLibrary.json',
      'es' => 'Mediante enlace o archivo CSV / YourLibrary.json',
      _ => 'Via Spotify link or Exportify CSV / YourLibrary.json',
    };
  }

  Future<void> _editUserName(BuildContext context, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final saved = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final tokens = Theme.of(ctx).glass;
        return AlertDialog(
          backgroundColor: tokens.bgElevated,
          title: Text('Your Name', style: TextStyle(color: tokens.textPrimary)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(color: tokens.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: TextStyle(color: tokens.textDim),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: TextStyle(color: tokens.textDim)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.accent,
                foregroundColor: tokens.onAccent,
              ),
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (saved != null) {
      unawaited(ref.read(settingsProvider.notifier).setUserName(saved));
    }
  }

  Future<void> _configureClaudeAi(
    BuildContext context,
    AppSettings settings,
  ) async {
    final apiKeyController = TextEditingController(text: settings.claudeApiKey);
    final baseUrlController = TextEditingController(
      text: settings.claudeBaseUrl,
    );
    const validClaudeModels = [
      'claude-sonnet-5-5',
      'claude-opus-5-5',
      'claude-haiku-5-5',
    ];
    var selectedModel = validClaudeModels.contains(settings.claudeModel)
        ? settings.claudeModel
        : 'claude-sonnet-5-5';

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final tokens = Theme.of(ctx).glass;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: tokens.bgElevated,
              title: Row(
                children: [
                  Icon(LucideIcons.sparkles, color: tokens.accent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Claude Code API',
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Provide an Anthropic API key or Claude Code proxy. '
                      'Leave empty to use built-in zero-config AI.',
                      style: TextStyle(fontSize: 12, color: tokens.textDim),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: apiKeyController,
                      style: TextStyle(color: tokens.textPrimary, fontSize: 13),
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'API Key',
                        labelStyle: TextStyle(color: tokens.accent),
                        hintText: 'sk-ant-api...',
                        hintStyle: TextStyle(color: tokens.textFaint),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: baseUrlController,
                      style: TextStyle(color: tokens.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Base URL',
                        labelStyle: TextStyle(color: tokens.accent),
                        hintText: 'https://api.anthropic.com',
                        hintStyle: TextStyle(color: tokens.textFaint),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Model',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: tokens.textDim,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: selectedModel,
                      dropdownColor: tokens.bgElevated,
                      style: TextStyle(color: tokens.textPrimary, fontSize: 13),
                      items: const [
                        DropdownMenuItem(
                          value: 'claude-sonnet-5-5',
                          child: Text('Claude Sonnet 5.5'),
                        ),
                        DropdownMenuItem(
                          value: 'claude-opus-5-5',
                          child: Text('Claude Opus 5.5'),
                        ),
                        DropdownMenuItem(
                          value: 'claude-haiku-5-5',
                          child: Text('Claude Haiku 5.5'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedModel = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: tokens.textDim),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.accent,
                    foregroundColor: tokens.onAccent,
                  ),
                  onPressed: () {
                    final notifier = ref.read(settingsProvider.notifier);
                    unawaited(notifier.setClaudeApiKey(apiKeyController.text));
                    unawaited(
                      notifier.setClaudeBaseUrl(baseUrlController.text),
                    );
                    unawaited(notifier.setClaudeModel(selectedModel));
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showYtmAccountSheet(
    BuildContext context,
    AppSettings settings,
  ) async {
    if (!settings.ytmLoggedIn) {
      await YtMusicAccountImporter.signInAndImport(context, ref);
      return;
    }

    final tokens = Theme.of(context).glass;
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: tokens.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.globe, color: tokens.accent, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settings.ytmAccountName.isNotEmpty
                                ? settings.ytmAccountName
                                : 'Google / YouTube Music',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: tokens.textPrimary,
                            ),
                          ),
                          Text(
                            'Connected • Two-way likes sync active',
                            style: TextStyle(
                              fontSize: 12,
                              color: tokens.textDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.accent,
                    foregroundColor: tokens.onAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(LucideIcons.refreshCw, size: 16),
                  label: const Text('Sync Likes & History Now'),
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await YtMusicAccountImporter.signInAndImport(context, ref);
                  },
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tokens.danger,
                    side: BorderSide(color: tokens.danger),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(LucideIcons.logOut, size: 16),
                  label: const Text('Disconnect Account'),
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await YtMusicAccountImporter.logout();
                    await ref.read(settingsProvider.notifier).clearYtmAccount();
                    _showToast(
                      'Disconnected from YouTube Music',
                      LucideIcons.check,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCountryDialog(BuildContext context) {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final currentCode = ref.read(settingsProvider).countryCode.toUpperCase();
    final langCode = Localizations.localeOf(context).languageCode;

    unawaited(
      showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(_countrySettingTitle(langCode)),
            content: SizedBox(
              width: 340,
              height: 420,
              child: ListView.builder(
                itemCount: supportedCountries.length,
                itemBuilder: (itemCtx, idx) {
                  final country = supportedCountries[idx];
                  final isSelected = country.code == currentCode;
                  final name = country.localizedName(langCode);
                  return _buildLangOption(
                    ctx,
                    label: '${country.flag}  $name (${country.code})',
                    isSelected: isSelected,
                    onSelect: () {
                      unawaited(settingsNotifier.setCountryCode(country.code));
                      Navigator.of(ctx).pop();
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final currentLocale = ref.read(settingsProvider).locale;

    unawaited(
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(context.l10n.settingsLanguage),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLangOption(
                  ctx,
                  label: 'System default',
                  isSelected: currentLocale == null,
                  onSelect: () {
                    unawaited(settingsNotifier.setLocale(null));
                    Navigator.of(ctx).pop();
                  },
                ),
                _buildLangOption(
                  ctx,
                  label: 'English',
                  isSelected: currentLocale?.languageCode == 'en',
                  onSelect: () {
                    unawaited(settingsNotifier.setLocale(const Locale('en')));
                    Navigator.of(ctx).pop();
                  },
                ),
                _buildLangOption(
                  ctx,
                  label: 'Español',
                  isSelected: currentLocale?.languageCode == 'es',
                  onSelect: () {
                    unawaited(settingsNotifier.setLocale(const Locale('es')));
                    Navigator.of(ctx).pop();
                  },
                ),
                _buildLangOption(
                  ctx,
                  label: 'العربية',
                  isSelected: currentLocale?.languageCode == 'ar',
                  onSelect: () {
                    unawaited(settingsNotifier.setLocale(const Locale('ar')));
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showTvModeDialog(BuildContext context, AppSettings settings) {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    unawaited(
      showDialog(
        context: context,
        builder: (ctx) {
          final tokens = Theme.of(ctx).glass;
          return AlertDialog(
            title: const Text('Android TV Mode'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLangOption(
                  ctx,
                  label: 'Auto-detect (Recommended)',
                  isSelected: settings.tvMode == 'auto',
                  onSelect: () {
                    unawaited(settingsNotifier.setTvMode('auto'));
                    Navigator.of(ctx).pop();
                  },
                ),
                _buildLangOption(
                  ctx,
                  label: 'Always On (TV UI)',
                  isSelected: settings.tvMode == 'on',
                  onSelect: () {
                    unawaited(settingsNotifier.setTvMode('on'));
                    Navigator.of(ctx).pop();
                  },
                ),
                _buildLangOption(
                  ctx,
                  label: 'Disabled (Phone UI)',
                  isSelected: settings.tvMode == 'off',
                  onSelect: () {
                    unawaited(settingsNotifier.setTvMode('off'));
                    Navigator.of(ctx).pop();
                  },
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: tokens.accent,
                    foregroundColor: tokens.onAccent,
                  ),
                  icon: const Icon(LucideIcons.tv, size: 18),
                  label: const Text('Launch TV Mode Now'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    unawaited(context.push('/tv'));
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLangOption(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onSelect,
  }) {
    final tokens = Theme.of(context).glass;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? tokens.accent : tokens.textPrimary,
        ),
      ),
      trailing: isSelected
          ? Icon(LucideIcons.check, size: 16, color: tokens.accent)
          : null,
      onTap: onSelect,
    );
  }

  Widget _buildCard({
    required GlassTokens tokens,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.glassFill,
        borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
        border: Border.all(color: tokens.glassStroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildDivider(GlassTokens tokens) {
    return Divider(height: 1, thickness: 1, color: tokens.glassStroke);
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required GlassTokens tokens,
    required ValueChanged<bool> onChanged,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: tokens.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: tokens.textDim),
                  ),
                ],
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: tokens.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required GlassTokens tokens,
    required VoidCallback? onTap,
    String? subtitle,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: tokens.textDim),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: tokens.textDim),
                    ),
                  ],
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 16, color: tokens.textFaint),
          ],
        ),
      ),
    );
  }
}
