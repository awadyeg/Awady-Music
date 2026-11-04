import 'package:awady_music/data/models/album_ref.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/artwork.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/playlist_page.dart';
import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:awady_music/data/sources/innertube/parsers/search_parser.dart';

/// Parser for Innertube album and playlist browse responses.
class PlaylistParser {
  const PlaylistParser();

  /// Parses an album browse response into [PlaylistPage].
  PlaylistPage parseAlbum(Map<String, dynamic> json, String browseId) {
    final header = _findHeader(json);

    final rawName =
        digAs<String>(header, ['title', 'runs', 0, 'text']) ??
        digAs<String>(json, [
          'microformat',
          'microformatDataRenderer',
          'title',
        ]) ??
        'Album';

    // Artist from header straplineTextOne or subtitle runs
    var artistName = digAs<String>(header, [
      'straplineTextOne',
      'runs',
      0,
      'text',
    ]);
    var artistChannelId = digAs<String>(header, [
      'straplineTextOne',
      'runs',
      0,
      'navigationEndpoint',
      'browseEndpoint',
      'browseId',
    ]);

    if (artistName == null) {
      final subRuns = dig(header, ['subtitle', 'runs']) as List?;
      if (subRuns != null) {
        for (final run in subRuns) {
          if (run is! Map<String, dynamic>) continue;
          final bid = digAs<String>(run, [
            'navigationEndpoint',
            'browseEndpoint',
            'browseId',
          ]);
          if (bid != null && RegExp('^(UC|MPLA|FE)').hasMatch(bid)) {
            artistName = run['text'] as String?;
            artistChannelId = bid;
            break;
          }
        }
      }
    }

    final effectiveArtistName = artistName ?? 'Various Artists';
    final effectiveArtistId = artistChannelId != null
        ? 'yt-$artistChannelId'
        : 'yt-${effectiveArtistName.toLowerCase().replaceAll(' ', '-')}';

    final ownerArtist = Artist(
      id: effectiveArtistId,
      streamId: artistChannelId,
      name: effectiveArtistName,
      handle: effectiveArtistName,
    );

    final artwork = parseArtwork(
      header?['thumbnail'] ?? header?['thumbnailRenderer'],
    );
    final description = _extractDescription(header?['description']);

    // Find song items
    final rawSongItems = _findSongItems(json);
    final tracks = <Track>[];
    for (final item in rawSongItems) {
      final track = _parseAlbumSong(
        item,
        albumBrowseId: browseId,
        albumName: rawName,
        albumArtist: ownerArtist,
        albumArtwork: artwork,
      );
      if (track != null) {
        tracks.add(track);
      }
    }

    final playlist = RemotePlaylist(
      id: 'ytalb-$browseId',
      name: rawName,
      isAlbum: true,
      description: description,
      artwork: artwork,
      trackCount: tracks.length,
      owner: ownerArtist,
    );

    return PlaylistPage(playlist: playlist, tracks: tracks);
  }

  /// Parses a playlist browse response into [PlaylistPage].
  PlaylistPage parsePlaylist(Map<String, dynamic> json, String browseId) {
    final header = _findHeader(json);

    final rawName =
        digAs<String>(header, ['title', 'runs', 0, 'text']) ??
        digAs<String>(json, [
          'microformat',
          'microformatDataRenderer',
          'title',
        ]) ??
        'Playlist';

    final artwork = parseArtwork(
      header?['thumbnail'] ?? header?['thumbnailRenderer'],
    );
    final description = _extractDescription(header?['description']);

    // Find song items
    final rawSongItems = _findSongItems(json);
    final tracks = <Track>[];
    for (final item in rawSongItems) {
      final track = _parsePlaylistSong(item, playlistArtwork: artwork);
      if (track != null) {
        tracks.add(track);
      }
    }

    // Owner artist
    final ownerName =
        digAs<String>(header, ['straplineTextOne', 'runs', 0, 'text']) ??
        'YouTube Music';
    final ownerChannelId = digAs<String>(header, [
      'straplineTextOne',
      'runs',
      0,
      'navigationEndpoint',
      'browseEndpoint',
      'browseId',
    ]);

    final owner = Artist(
      id: ownerChannelId != null ? 'yt-$ownerChannelId' : 'yt-va',
      streamId: ownerChannelId,
      name: ownerName,
      handle: ownerName,
    );

    // Fall back to first track artwork if playlist has no header art
    final effectiveArtwork =
        artwork ?? (tracks.isNotEmpty ? tracks.first.artwork : null);

    final playlist = RemotePlaylist(
      id: 'ytpl-$browseId',
      name: rawName,
      description: description,
      artwork: effectiveArtwork,
      trackCount: tracks.length,
      owner: owner,
    );

    return PlaylistPage(playlist: playlist, tracks: tracks);
  }

  Map<String, dynamic>? _findHeader(Map<String, dynamic> json) {
    if (json.containsKey('header')) {
      final hdr = json['header'];
      if (hdr is Map<String, dynamic>) {
        if (hdr.containsKey('musicResponsiveHeaderRenderer')) {
          return hdr['musicResponsiveHeaderRenderer'] as Map<String, dynamic>;
        }
        if (hdr.containsKey('musicDetailHeaderRenderer')) {
          return hdr['musicDetailHeaderRenderer'] as Map<String, dynamic>;
        }
        if (hdr.containsKey('musicEditablePlaylistDetailHeaderRenderer')) {
          final inner = dig(hdr, [
            'musicEditablePlaylistDetailHeaderRenderer',
            'header',
            'musicResponsiveHeaderRenderer',
          ]);
          if (inner is Map<String, dynamic>) return inner;
        }
        return hdr;
      }
    }

    // Check tabs
    final tabs =
        dig(json, ['contents', 'twoColumnBrowseResultsRenderer', 'tabs'])
            as List? ??
        dig(json, ['contents', 'singleColumnBrowseResultsRenderer', 'tabs'])
            as List?;
    if (tabs != null && tabs.isNotEmpty) {
      final firstTab = tabs.first;
      if (firstTab is Map<String, dynamic>) {
        final tabContents = dig(firstTab, [
          'tabRenderer',
          'content',
          'sectionListRenderer',
          'contents',
        ]) as List?;
        if (tabContents != null) {
          for (final item in tabContents) {
            if (item is Map<String, dynamic>) {
              if (item.containsKey('musicResponsiveHeaderRenderer')) {
                return item['musicResponsiveHeaderRenderer']
                    as Map<String, dynamic>;
              }
              if (item.containsKey('musicDetailHeaderRenderer')) {
                return item['musicDetailHeaderRenderer']
                    as Map<String, dynamic>;
              }
            }
          }
        }
      }
    }

    return null;
  }

  List<Map<String, dynamic>> _findSongItems(Map<String, dynamic> json) {
    final items = <Map<String, dynamic>>[];
    final seenVideoIds = <String>{};

    void walk(dynamic node) {
      if (node == null) return;
      if (node is List) {
        node.forEach(walk);
        return;
      }
      if (node is! Map<String, dynamic>) return;

      if (node.containsKey('musicResponsiveListItemRenderer')) {
        final item =
            node['musicResponsiveListItemRenderer'] as Map<String, dynamic>;
        final videoId =
            digAs<String>(item, ['playlistItemData', 'videoId']) ??
            digAs<String>(item, [
              'overlay',
              'musicItemThumbnailOverlayRenderer',
              'content',
              'musicPlayButtonRenderer',
              'playNavigationEndpoint',
              'watchEndpoint',
              'videoId',
            ]) ??
            digAs<String>(item, [
              'flexColumns',
              0,
              'musicResponsiveListItemFlexColumnRenderer',
              'text',
              'runs',
              0,
              'navigationEndpoint',
              'watchEndpoint',
              'videoId',
            ]);
        if (videoId != null && videoId.length == 11) {
          if (seenVideoIds.add(videoId)) {
            items.add(item);
          }
        }
        return;
      }

      node.values.forEach(walk);
    }

    walk(json);
    return items;
  }

  Track? _parseAlbumSong(
    Map<String, dynamic> item, {
    required String albumBrowseId,
    required String albumName,
    required Artist albumArtist,
    required Artwork? albumArtwork,
  }) {
    final videoId =
        digAs<String>(item, ['playlistItemData', 'videoId']) ??
        digAs<String>(item, [
          'overlay',
          'musicItemThumbnailOverlayRenderer',
          'content',
          'musicPlayButtonRenderer',
          'playNavigationEndpoint',
          'watchEndpoint',
          'videoId',
        ]) ??
        digAs<String>(item, [
          'flexColumns',
          0,
          'musicResponsiveListItemFlexColumnRenderer',
          'text',
          'runs',
          0,
          'navigationEndpoint',
          'watchEndpoint',
          'videoId',
        ]);

    if (videoId == null || videoId.length != 11) return null;

    final rawTitle =
        digAs<String>(item, [
          'flexColumns',
          0,
          'musicResponsiveListItemFlexColumnRenderer',
          'text',
          'runs',
          0,
          'text',
        ]) ??
        'Untitled';
    final title = cleanSongTitle(rawTitle);

    var durationSec = 0;
    var playCount = 0;
    String? artistName;
    String? artistChannelId;

    final flexCols = item['flexColumns'] as List?;
    if (flexCols != null) {
      for (final col in flexCols.skip(1)) {
        if (col is! Map<String, dynamic>) continue;
        final runs = dig(col, [
          'musicResponsiveListItemFlexColumnRenderer',
          'text',
          'runs',
        ]) as List?;
        if (runs == null) continue;
        for (final run in runs) {
          if (run is! Map<String, dynamic>) continue;
          final runText = (run['text'] as String? ?? '').trim();
          if (RegExp(r'^\d{1,3}:\d{2}').hasMatch(runText)) {
            durationSec = parseDuration(runText);
          } else if (RegExp(
            'views|plays|vistas|reproducciones',
            caseSensitive: false,
          ).hasMatch(runText)) {
            playCount = parseCount(runText);
          } else {
            final bid = digAs<String>(run, [
              'navigationEndpoint',
              'browseEndpoint',
              'browseId',
            ]);
            if (bid != null && RegExp('^(UC|MPLA|FE)').hasMatch(bid)) {
              artistName ??= runText;
              artistChannelId ??= bid;
            }
          }
        }
      }
    }

    if (durationSec == 0) {
      final fixedCols = item['fixedColumns'] as List?;
      if (fixedCols != null) {
        for (final col in fixedCols) {
          if (col is! Map<String, dynamic>) continue;
          final runs = dig(col, [
            'musicResponsiveListItemFixedColumnRenderer',
            'text',
            'runs',
          ]) as List?;
          if (runs != null) {
            for (final run in runs) {
              if (run is! Map<String, dynamic>) continue;
              final text = (run['text'] as String? ?? '').trim();
              if (RegExp(r'^\d{1,3}:\d{2}').hasMatch(text)) {
                durationSec = parseDuration(text);
                break;
              }
            }
          }
        }
      }
    }

    final fallbackThumb = 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';
    final rowArtwork = parseArtwork(item['thumbnail']);
    final artwork =
        rowArtwork ??
        albumArtwork ??
        Artwork(
          s150: fallbackThumb,
          s480: fallbackThumb,
          s1000: 'https://i.ytimg.com/vi/$videoId/maxresdefault.jpg',
        );

    final trackArtist = artistName != null
        ? Artist(
            id: 'yt-${artistChannelId ?? artistName}',
            streamId: artistChannelId,
            name: artistName,
            handle: artistName,
          )
        : albumArtist;

    return Track(
      id: 'yt-$videoId',
      source: TrackSource.yt,
      streamId: videoId,
      title: title,
      duration: durationSec,
      playCount: playCount,
      artwork: artwork,
      artist: trackArtist,
      album: AlbumRef(id: albumBrowseId, name: albumName),
    );
  }

  Track? _parsePlaylistSong(
    Map<String, dynamic> item, {
    required Artwork? playlistArtwork,
  }) {
    final videoId =
        digAs<String>(item, ['playlistItemData', 'videoId']) ??
        digAs<String>(item, [
          'overlay',
          'musicItemThumbnailOverlayRenderer',
          'content',
          'musicPlayButtonRenderer',
          'playNavigationEndpoint',
          'watchEndpoint',
          'videoId',
        ]) ??
        digAs<String>(item, [
          'flexColumns',
          0,
          'musicResponsiveListItemFlexColumnRenderer',
          'text',
          'runs',
          0,
          'navigationEndpoint',
          'watchEndpoint',
          'videoId',
        ]);

    if (videoId == null || videoId.length != 11) return null;

    final rawTitle =
        digAs<String>(item, [
          'flexColumns',
          0,
          'musicResponsiveListItemFlexColumnRenderer',
          'text',
          'runs',
          0,
          'text',
        ]) ??
        'Untitled';
    final title = cleanSongTitle(rawTitle);

    var durationSec = 0;
    var playCount = 0;
    String? artistName;
    String? artistChannelId;
    String? albumName;
    String? albumBrowseId;

    final flexCols = item['flexColumns'] as List?;
    if (flexCols != null) {
      for (var i = 1; i < flexCols.length; i++) {
        final col = flexCols[i];
        if (col is! Map<String, dynamic>) continue;
        final runs = dig(col, [
          'musicResponsiveListItemFlexColumnRenderer',
          'text',
          'runs',
        ]) as List?;
        if (runs == null) continue;
        for (final run in runs) {
          if (run is! Map<String, dynamic>) continue;
          final runText = (run['text'] as String? ?? '').trim();
          if (runText.isEmpty || runText == '•') continue;

          final bid = digAs<String>(run, [
            'navigationEndpoint',
            'browseEndpoint',
            'browseId',
          ]);

          if (RegExp(r'^\d{1,3}:\d{2}').hasMatch(runText)) {
            durationSec = parseDuration(runText);
          } else if (RegExp(
            'views|plays|vistas|reproducciones',
            caseSensitive: false,
          ).hasMatch(runText)) {
            playCount = parseCount(runText);
          } else if (bid != null && RegExp('^(UC|MPLA|FE)').hasMatch(bid)) {
            artistName ??= runText;
            artistChannelId ??= bid;
          } else if (bid != null && bid.startsWith('MPRE')) {
            albumName ??= runText;
            albumBrowseId ??= bid;
          } else if (i == 1 && artistName == null) {
            artistName = runText;
          }
        }
      }
    }

    if (durationSec == 0) {
      final fixedCols = item['fixedColumns'] as List?;
      if (fixedCols != null) {
        for (final col in fixedCols) {
          if (col is! Map<String, dynamic>) continue;
          final runs = dig(col, [
            'musicResponsiveListItemFixedColumnRenderer',
            'text',
            'runs',
          ]) as List?;
          if (runs != null) {
            for (final run in runs) {
              if (run is! Map<String, dynamic>) continue;
              final text = (run['text'] as String? ?? '').trim();
              if (RegExp(r'^\d{1,3}:\d{2}').hasMatch(text)) {
                durationSec = parseDuration(text);
                break;
              }
            }
          }
        }
      }
    }

    final effectiveArtistName = artistName ?? 'Unknown artist';
    final effectiveArtistId = artistChannelId != null
        ? 'yt-$artistChannelId'
        : 'yt-$effectiveArtistName';

    final fallbackThumb = 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';
    final rowArtwork = parseArtwork(item['thumbnail'], fallback: fallbackThumb);
    final artwork =
        rowArtwork ??
        playlistArtwork ??
        Artwork(
          s150: fallbackThumb,
          s480: fallbackThumb,
          s1000: 'https://i.ytimg.com/vi/$videoId/maxresdefault.jpg',
        );

    return Track(
      id: 'yt-$videoId',
      source: TrackSource.yt,
      streamId: videoId,
      title: title,
      duration: durationSec,
      playCount: playCount,
      artwork: artwork,
      artist: Artist(
        id: effectiveArtistId,
        streamId: artistChannelId,
        name: effectiveArtistName,
        handle: effectiveArtistName,
      ),
      album: albumName != null
          ? AlbumRef(id: albumBrowseId ?? '', name: albumName)
          : null,
    );
  }

  String? _extractDescription(dynamic descNode) {
    if (descNode == null) return null;
    if (descNode is String) return descNode;
    if (descNode is Map<String, dynamic>) {
      final runs =
          dig(descNode, [
            'musicDescriptionShelfRenderer',
            'description',
            'runs',
          ]) as List? ??
          dig(descNode, ['runs']) as List?;
      if (runs != null) {
        final text = runs
            .whereType<Map<String, dynamic>>()
            .map((r) => r['text'] as String? ?? '')
            .join();
        if (text.isNotEmpty) return text;
      }
    }
    return null;
  }
}
