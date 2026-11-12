import 'dart:async';
import 'dart:convert';

import 'package:awady_music/core/l10n/l10n.dart';
import 'package:awady_music/core/theme/tokens.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/import_queue.dart';
import 'package:awady_music/data/repositories/library_repository.dart';
import 'package:awady_music/data/sources/importer/playlist_file_parser.dart';
import 'package:awady_music/data/sources/spotify/spotify_importer.dart';
import 'package:awady_music/data/sources/youtube/yt_account_importer.dart';
import 'package:awady_music/data/sources/youtube/yt_playlist_importer.dart';
import 'package:awady_music/widgets/glass_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum ImportDestination { playlist, liked }

Future<void> showImportSheet(
  BuildContext context, {
  String? initialUrl,
  ImportDestination initialDestination = ImportDestination.playlist,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => ImportSheet(
      initialUrl: initialUrl,
      initialDestination: initialDestination,
    ),
  );
}

class ImportSheet extends ConsumerStatefulWidget {
  const ImportSheet({
    this.initialUrl,
    this.initialDestination = ImportDestination.playlist,
    super.key,
  });

  final String? initialUrl;
  final ImportDestination initialDestination;

  @override
  ConsumerState<ImportSheet> createState() => _ImportSheetState();
}

class _ImportSheetState extends ConsumerState<ImportSheet> {
  late final TextEditingController _urlController;
  late ImportDestination _destination;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _destination = widget.initialDestination;
    _urlController = TextEditingController(text: widget.initialUrl ?? '');
    if (widget.initialUrl != null && widget.initialUrl!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_handleImportUrl());
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _matchEntries(
    String playlistName,
    List<ImportEntry> entries, {
    bool limited = false,
    ImportDestination? forceDestination,
  }) async {
    final libraryRepo = ref.read(libraryRepositoryProvider);
    final importQueue = ref.read(importQueueProvider);
    final l10n = context.l10n;
    final target = forceDestination ?? _destination;

    if (target == ImportDestination.liked) {
      final batchId = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
      final placeholders = entries.asMap().entries.map((item) {
        final i = item.key;
        final e = item.value;
        final artistName = e.artist.isNotEmpty ? e.artist : 'Unknown artist';
        final cleanHandle = artistName.toLowerCase().replaceAll(
          RegExp('[^a-z0-9]+'),
          '-',
        );

        return Track(
          id: 'spi-liked-$batchId-$i',
          title: e.title.isNotEmpty ? e.title : 'Untitled',
          artist: Artist(id: 'spa-$cleanHandle', name: artistName),
          duration: e.duration ?? 0,
          source: TrackSource.yt,
          pending: true,
        );
      }).toList();

      libraryRepo.addLikedTracks(placeholders);
      importQueue.enqueuePending('liked', placeholders);

      if (mounted) {
        final msg = limited
            ? l10n.importLimited(placeholders.length.toString())
            : l10n.importImported(placeholders.length.toString());
        ref.read(toastProvider.notifier).show(msg);

        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        unawaited(context.push('/playlist/liked'));
      }
      return;
    }

    final pid = libraryRepo.createPlaylist(playlistName);
    final placeholders = entries.asMap().entries.map((item) {
      final i = item.key;
      final e = item.value;
      final artistName = e.artist.isNotEmpty ? e.artist : 'Unknown artist';
      final cleanHandle = artistName.toLowerCase().replaceAll(
        RegExp('[^a-z0-9]+'),
        '-',
      );

      return Track(
        id: 'spi-$pid-$i',
        title: e.title.isNotEmpty ? e.title : 'Untitled',
        artist: Artist(id: 'spa-$cleanHandle', name: artistName),
        duration: e.duration ?? 0,
        source: TrackSource.yt,
        pending: true,
      );
    }).toList();

    libraryRepo.addTracksToPlaylist(pid, placeholders);
    importQueue.enqueuePending(pid, placeholders);

    if (mounted) {
      final msg = limited
          ? l10n.importLimited(placeholders.length.toString())
          : l10n.importImported(placeholders.length.toString());
      ref.read(toastProvider.notifier).show(msg);

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      unawaited(context.push('/playlist/$pid'));
    }
  }

  Future<void> _handleImportUrl() async {
    final url = _urlController.text.trim();
    final l10n = context.l10n;

    if (url.isEmpty) {
      setState(() {
        _error = l10n.importPasteLink;
      });
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    // 1. Check if Spotify URL / URI / ID
    final spotifyEntity = SpotifyImporter.extractEntity(url);
    if (spotifyEntity != null &&
        (url.contains('spotify') ||
            SpotifyImporter.spotifyIdPattern.hasMatch(url))) {
      final importer = SpotifyImporter();
      final res = await importer.importPlaylist(url);

      if (!res.ok) {
        if (mounted) {
          setState(() {
            _busy = false;
            _error = l10n.importUnreadable;
          });
        }
        return;
      }

      await _matchEntries(
        res.name.isNotEmpty ? res.name : 'Spotify Playlist',
        res.tracks,
        limited: res.limited,
      );
      return;
    }

    // 2. Check if YouTube Music URL
    final ytId = YtPlaylistImporter.extractPlaylistId(url);
    if (ytId != null) {
      final importer = YtPlaylistImporter();
      final res = await importer.importPlaylist(ytId);

      if (!res.ok || res.tracks.isEmpty) {
        if (mounted) {
          setState(() {
            _busy = false;
            _error = l10n.importNotFound;
          });
        }
        return;
      }

      final libraryRepo = ref.read(libraryRepositoryProvider);
      if (_destination == ImportDestination.liked) {
        libraryRepo.addLikedTracks(res.tracks);
        if (mounted) {
          ref
              .read(toastProvider.notifier)
              .show(l10n.importImported(res.tracks.length.toString()));
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          unawaited(context.push('/playlist/liked'));
        }
        return;
      }

      final pid = libraryRepo.createPlaylist(res.name);
      libraryRepo.addTracksToPlaylist(pid, res.tracks);

      if (mounted) {
        ref
            .read(toastProvider.notifier)
            .show(l10n.importImported(res.tracks.length.toString()));
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        unawaited(context.push('/playlist/$pid'));
      }
      return;
    }

    // Neither Spotify nor YT matched
    if (mounted) {
      setState(() {
        _busy = false;
        _error = l10n.importPasteLink;
      });
    }
  }

  Future<void> _handlePickFile() async {
    final l10n = context.l10n;
    setState(() {
      _error = null;
    });

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'json'],
      );

      if (files.isEmpty) return;

      final file = files.first;
      final bytes = await file.readAsBytes();

      final content = utf8.decode(bytes);
      final fileName = file.name.replaceAll(RegExp(r'\.[^.]+$'), '');

      setState(() {
        _busy = true;
      });

      final lowerName = fileName.toLowerCase();
      final autoLiked =
          lowerName == 'liked_songs' ||
          lowerName == 'liked songs' ||
          lowerName == 'yourlibrary';

      if (file.extension?.toLowerCase() == 'json' ||
          file.name.endsWith('.freebify.json')) {
        final parsed = await PlaylistFileParser.parseJsonCompute(
          content,
          defaultName: fileName.replaceAll('.freebify', ''),
        );
        final isLikedFile =
            autoLiked || parsed.name.toLowerCase() == 'liked songs';
        await _matchEntries(
          parsed.name,
          parsed.entries,
          forceDestination: isLikedFile ? ImportDestination.liked : null,
        );
      } else {
        final parsed = await PlaylistFileParser.parseCsvCompute(
          content,
          defaultName: fileName,
        );
        await _matchEntries(
          parsed.name,
          parsed.entries,
          forceDestination: autoLiked ? ImportDestination.liked : null,
        );
      }
    } on FormatException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.message.contains('JSON')
              ? l10n.importBadJson
              : l10n.importBadCsv;
        });
      }
    } on Object {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = l10n.importFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).glass;
    final l10n = context.l10n;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 24 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: tokens.bgElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: tokens.glassStroke),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Grabber handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: tokens.textDim.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header title
            Row(
              children: [
                Icon(
                  LucideIcons.fileSpreadsheet,
                  color: tokens.accent,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.importPlaylistTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: tokens.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Destination selector (Playlist vs Liked Songs)
            SegmentedButton<ImportDestination>(
              key: const Key('import_destination_selector'),
              segments: [
                ButtonSegment(
                  value: ImportDestination.playlist,
                  icon: const Icon(LucideIcons.listMusic, size: 16),
                  label: Text(l10n.libraryPlaylistLabel),
                ),
                ButtonSegment(
                  value: ImportDestination.liked,
                  icon: const Icon(LucideIcons.heart, size: 16),
                  label: Text(l10n.libraryLikedSongs),
                ),
              ],
              selected: {_destination},
              onSelectionChanged: _busy
                  ? null
                  : (selection) {
                      setState(() {
                        _destination = selection.first;
                      });
                    },
            ),
            const SizedBox(height: 14),

            // URL Input field
            TextField(
              key: const Key('import_url_field'),
              controller: _urlController,
              enabled: !_busy,
              style: TextStyle(color: tokens.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: l10n.importUrlHint,
                hintStyle: TextStyle(
                  color: tokens.textDim.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: tokens.bgElevated.withValues(alpha: 0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: tokens.glassStroke),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: tokens.glassStroke),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: tokens.accent, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => unawaited(_handleImportUrl()),
            ),

            // Inline error message
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                key: const Key('import_error_text'),
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 14),

            // Import submit button
            ElevatedButton(
              key: const Key('import_submit_button'),
              onPressed: _busy ? null : _handleImportUrl,
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      l10n.importSubmit,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),

            const SizedBox(height: 18),

            // Divider with "OR"
            Row(
              children: [
                Expanded(child: Divider(color: tokens.glassStroke)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: tokens.textDim.withValues(alpha: 0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: tokens.glassStroke)),
              ],
            ),

            const SizedBox(height: 18),

            // Choose file button
            OutlinedButton.icon(
              key: const Key('import_file_button'),
              onPressed: _busy ? null : _handlePickFile,
              icon: Icon(
                LucideIcons.fileUp,
                size: 18,
                color: tokens.textPrimary,
              ),
              label: Text(
                l10n.importFileButton,
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: tokens.glassStroke),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Sign in & sync Google / YouTube Music account button
            OutlinedButton.icon(
              key: const Key('import_ytm_account_button'),
              onPressed: _busy
                  ? null
                  : () async {
                      Navigator.of(context).pop();
                      await YtMusicAccountImporter.signInAndImport(
                        context,
                        ref,
                      );
                    },
              icon: Icon(LucideIcons.globe, size: 18, color: tokens.accent),
              label: Text(
                'Connect & Sync YouTube Music Account',
                style: TextStyle(
                  color: tokens.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: tokens.accent.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Hint footnote
            Center(
              child: Text(
                l10n.importCsvHint,
                style: TextStyle(
                  color: tokens.textDim.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
