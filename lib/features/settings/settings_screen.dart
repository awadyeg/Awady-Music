import 'dart:async';

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/core/util/log.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/data/repositories/stats_repository.dart';
import 'package:awady_music/player/player_controller.dart';
import 'package:awady_music/widgets/equalizer_sheet.dart';
import 'package:awady_music/widgets/glass_toast.dart';
import 'package:awady_music/widgets/large_title_scaffold.dart';
import 'package:awady_music/widgets/section_header.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

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
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _checkingUpdates = false);
      _showToast(l10n.settingsUpdateLatest, LucideIcons.check);
    }
  }

  void _clearCache(L10n l10n) {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    _showToast(l10n.settingsCacheCleared, LucideIcons.check);
  }

  void _shareGitHub() {
    unawaited(
      SharePlus.instance.share(
        ShareParams(
          text: 'https://github.com/awadyeg/Awady-Music',
          subject: 'Awady Music',
        ),
      ),
    );
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

                    // Export library & stats
                    _buildNavTile(
                      icon: LucideIcons.share2,
                      title: l10n.settingsExport,
                      tokens: tokens,
                      onTap: () {
                        ref.read(statsRepositoryProvider).flush();
                        _showToast(
                          l10n.settingsBackupExported,
                          LucideIcons.check,
                        );
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
                            child: Icon(
                              LucideIcons.music,
                              color: tokens.accent,
                              size: 22,
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
                                  'v1.0.0 (build 1)',
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

                    // Attribution line (Mandatory Constitution requirement)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            LucideIcons.heartHandshake,
                            size: 16,
                            color: tokens.textDim,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.aboutAttribution,
                              style: TextStyle(
                                fontSize: 12,
                                color: tokens.textDim,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(tokens),

                    // GitHub repository link
                    _buildNavTile(
                      icon: LucideIcons.gitBranch,
                      title: l10n.settingsContribute,
                      tokens: tokens,
                      onTap: _shareGitHub,
                    ),
                    _buildDivider(tokens),

                    // Legal & Licenses
                    _buildNavTile(
                      icon: LucideIcons.scale,
                      title: l10n.settingsLegal,
                      tokens: tokens,
                      onTap: () => context.push('/settings/legal'),
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
                const SizedBox(height: 48),
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
