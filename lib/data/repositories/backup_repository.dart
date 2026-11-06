import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/core/util/log.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/local_playlist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/data/repositories/stats_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Object? _parseJson(String source) => jsonDecode(source);

class BackupImportResult {
  const BackupImportResult({
    required this.likedCount,
    required this.playlistsCount,
    required this.artistsCount,
    required this.statsMerged,
    this.error,
  });

  final int likedCount;
  final int playlistsCount;
  final int artistsCount;
  final bool statsMerged;
  final String? error;

  bool get success => error == null;
}

class BackupRepository {
  BackupRepository({
    required this.libraryRepo,
    this.statsRepo,
    this.settingsNotifier,
    this.getSettings,
    this.getTempDir,
  });

  final LibraryRepository libraryRepo;
  final StatsRepository? statsRepo;
  final SettingsNotifier? settingsNotifier;
  final AppSettings Function()? getSettings;
  final Future<Directory> Function()? getTempDir;

  String exportBackupJson() {
    final library = {
      'liked': {for (final t in libraryRepo.likedTracks) t.id: t.toJson()},
      'likedOrder': libraryRepo.likedOrder,
      'recents': libraryRepo.recents.map((t) => t.toJson()).toList(),
      'playlists': libraryRepo.playlists.map((p) => p.toJson()).toList(),
      'followedArtists': libraryRepo.followedArtists
          .map((a) => a.toJson())
          .toList(),
    };

    final stats = {
      'days': statsRepo?.state.days ?? {},
      'months': {
        for (final e in (statsRepo?.state.months ?? {}).entries)
          e.key: e.value.toJson(),
      },
      'tracks': {
        for (final e in (statsRepo?.state.tracks ?? {}).entries)
          e.key: e.value.toJson(),
      },
      'artists': {
        for (final e in (statsRepo?.state.artists ?? {}).entries)
          e.key: e.value.toJson(),
      },
      'totalMs': statsRepo?.state.totalMs ?? 0,
      'totalPlays': statsRepo?.state.totalPlays ?? 0,
    };

    final appSettings = getSettings != null
        ? getSettings!()
        : const AppSettings();
    final settings = {
      'themeMode': appSettings.themeMode.name,
      'locale': appSettings.locale?.languageCode,
      'autoplay': appSettings.autoplay,
      'wifiOnlyDownloads': appSettings.wifiOnlyDownloads,
      'reduceTransparency': appSettings.reduceTransparency,
    };

    final payload = {
      'app': 'awadymusic',
      'version': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'library': library,
      'stats': stats,
      'settings': settings,
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<File> writeBackupToFile([Directory? targetDir]) async {
    final dir =
        targetDir ??
        (getTempDir != null
            ? await getTempDir!()
            : await getTemporaryDirectory());
    final dateStr = DateTime.now().toIso8601String().substring(0, 10);
    final filePath = p.join(dir.path, 'awadymusic-backup-$dateStr.json');
    final file = File(filePath);
    await file.writeAsString(exportBackupJson());
    return file;
  }

  Future<File> exportAndShare() async {
    final file = await writeBackupToFile();
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'Awady Music Backup',
        title: 'Awady Music Backup',
      ),
    );
    return file;
  }

  Future<BackupImportResult> importBackupJson(String jsonString) async {
    final dynamic decoded;
    try {
      decoded = await compute(_parseJson, jsonString);
    } on Object catch (e) {
      return BackupImportResult(
        likedCount: 0,
        playlistsCount: 0,
        artistsCount: 0,
        statsMerged: false,
        error: 'Invalid JSON: $e',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      return const BackupImportResult(
        likedCount: 0,
        playlistsCount: 0,
        artistsCount: 0,
        statsMerged: false,
        error: 'Backup must be a JSON object',
      );
    }

    var likedMerged = 0;
    var playlistsMerged = 0;
    var artistsMerged = 0;
    var statsMerged = false;

    // 1. Library merge
    final libData = decoded['library'];
    if (libData is Map<String, dynamic>) {
      // Liked tracks
      final likedObj = libData['liked'];
      if (likedObj is Map<String, dynamic>) {
        for (final val in likedObj.values) {
          if (val is Map<String, dynamic>) {
            try {
              final track = Track.fromJson(val);
              if (!libraryRepo.isLiked(track.id)) {
                libraryRepo.toggleLike(track);
                likedMerged++;
              }
            } on Object catch (_) {}
          }
        }
      } else if (likedObj is List) {
        for (final item in likedObj) {
          if (item is Map<String, dynamic>) {
            try {
              final track = Track.fromJson(item);
              if (!libraryRepo.isLiked(track.id)) {
                libraryRepo.toggleLike(track);
                likedMerged++;
              }
            } on Object catch (_) {}
          }
        }
      }

      // Followed artists
      final followedList = libData['followedArtists'];
      if (followedList is List) {
        for (final item in followedList) {
          if (item is Map<String, dynamic>) {
            try {
              final artist = Artist.fromJson(item);
              if (!libraryRepo.isFollowing(artist.id)) {
                libraryRepo.toggleFollow(artist);
                artistsMerged++;
              }
            } on Object catch (_) {}
          }
        }
      }

      // Playlists
      final playlistsList = libData['playlists'];
      if (playlistsList is List) {
        for (final item in playlistsList) {
          if (item is Map<String, dynamic>) {
            try {
              final playlist = LocalPlaylist.fromJson(item);
              final existing = libraryRepo.getPlaylist(playlist.id);
              if (existing != null) {
                final existingIds = existing.tracks.map((t) => t.id).toSet();
                final toAdd = playlist.tracks
                    .where((t) => !existingIds.contains(t.id))
                    .toList();
                if (toAdd.isNotEmpty) {
                  libraryRepo.addTracksToPlaylist(existing.id, toAdd);
                }
              } else {
                final newId = libraryRepo.createPlaylist(playlist.name);
                libraryRepo.addTracksToPlaylist(newId, playlist.tracks);
              }
              playlistsMerged++;
            } on Object catch (_) {}
          }
        }
      }
    }

    // 2. Stats merge
    final statsData = decoded['stats'];
    if (statsData is Map<String, dynamic> && statsRepo != null) {
      try {
        final mergedState = mergePersisted(statsData, statsRepo!.state);
        statsRepo!.setState(mergedState);
        statsMerged = true;
      } on Object catch (e) {
        Log.w('Failed merging stats from backup: $e');
      }
    }

    // 3. Settings merge
    final settingsData = decoded['settings'];
    if (settingsData is Map<String, dynamic> && settingsNotifier != null) {
      try {
        if (settingsData['themeMode'] is String) {
          final mode = ThemeMode.values.firstWhere(
            (m) => m.name == settingsData['themeMode'],
            orElse: () => ThemeMode.system,
          );
          unawaited(settingsNotifier!.setThemeMode(mode));
        }
        if (settingsData['autoplay'] is bool) {
          unawaited(
            settingsNotifier!.setAutoplay(
              autoplay: settingsData['autoplay'] as bool,
            ),
          );
        }
        if (settingsData['wifiOnlyDownloads'] is bool) {
          unawaited(
            settingsNotifier!.setWifiOnlyDownloads(
              wifiOnly: settingsData['wifiOnlyDownloads'] as bool,
            ),
          );
        }
        if (settingsData['reduceTransparency'] is bool) {
          unawaited(
            settingsNotifier!.setReduceTransparency(
              reduce: settingsData['reduceTransparency'] as bool,
            ),
          );
        }
      } on Object catch (e) {
        Log.w('Failed merging settings from backup: $e');
      }
    }

    return BackupImportResult(
      likedCount: likedMerged,
      playlistsCount: playlistsMerged,
      artistsCount: artistsMerged,
      statsMerged: statsMerged,
    );
  }

  Future<BackupImportResult?> pickAndImportBackup() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (files.isEmpty) return null;

    final file = files.first;
    final bytes = await file.readAsBytes();
    final content = utf8.decode(bytes);

    return await importBackupJson(content);
  }
}

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  final libraryRepo = ref.watch(libraryRepositoryProvider);
  final statsRepo = ref.watch(statsRepositoryProvider);
  final settingsNotifier = ref.watch(settingsProvider.notifier);

  return BackupRepository(
    libraryRepo: libraryRepo,
    statsRepo: statsRepo,
    settingsNotifier: settingsNotifier,
    getSettings: () => ref.watch(settingsProvider),
  );
});
