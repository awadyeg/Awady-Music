import 'package:awady_music/data/models/album_ref.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/artwork.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/mood_models.dart';
import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:awady_music/data/sources/innertube/parsers/search_parser.dart';

/// Parser for home, explore, charts, new releases, moods, and upNext endpoints.
class BrowseParser {
  const BrowseParser();

  /// Parses playlists & albums from home or explore feeds.
  List<RemotePlaylist> parseHomePlaylists(Map<String, dynamic> json) {
    final out = <RemotePlaylist>[];
    final seen = <String>{};

    void walk(dynamic node) {
      if (node == null) return;
      if (node is List) {
        node.forEach(walk);
        return;
      }
      if (node is! Map<String, dynamic>) return;

      if (node.containsKey('musicTwoRowItemRenderer')) {
        final pl = _mapTwoRowPlaylist(
          node['musicTwoRowItemRenderer'] as Map<String, dynamic>,
        );
        if (pl != null && seen.add(pl.id)) {
          out.add(pl);
        }
        return;
      }

      node.values.forEach(walk);
    }

    walk(json);
    return out;
  }

  /// Parses new releases into a list of [RemotePlaylist].
  List<RemotePlaylist> parseNewReleases(
    Map<String, dynamic> json, {
    int limit = 24,
  }) {
    final playlists = parseHomePlaylists(json);
    return playlists.length > limit ? playlists.sublist(0, limit) : playlists;
  }

  /// Parses charts browse response, extracting chart playlist IDs and any
  /// song rows.
  ({List<String> chartPlaylistIds, List<Track> tracks}) parseCharts(
    Map<String, dynamic> json,
  ) {
    final chartPlaylistIds = <String>[];
    final tracks = <Track>[];
    final seenVideos = <String>{};

    void walk(dynamic node) {
      if (node == null) return;
      if (node is List) {
        node.forEach(walk);
        return;
      }
      if (node is! Map<String, dynamic>) return;

      if (node.containsKey('browseEndpoint')) {
        final bid = digAs<String>(node, ['browseEndpoint', 'browseId']);
        if (bid != null &&
            bid.startsWith('VLPL') &&
            !chartPlaylistIds.contains(bid)) {
          chartPlaylistIds.add(bid);
        }
      }

      if (node.containsKey('musicResponsiveListItemRenderer')) {
        final item =
            node['musicResponsiveListItemRenderer'] as Map<String, dynamic>;
        final track = _parseSongItem(item);
        if (track != null && seenVideos.add(track.id)) {
          tracks.add(track);
        }
        return;
      }

      node.values.forEach(walk);
    }

    walk(json);
    return (chartPlaylistIds: chartPlaylistIds, tracks: tracks);
  }

  /// Parses moods and genres directory buttons.
  List<MoodCategory> parseMoods(Map<String, dynamic> json) {
    final out = <MoodCategory>[];
    final seenNames = <String>{};

    void walk(dynamic node) {
      if (node == null) return;
      if (node is List) {
        node.forEach(walk);
        return;
      }
      if (node is! Map<String, dynamic>) return;

      if (node.containsKey('musicNavigationButtonRenderer')) {
        final btn =
            node['musicNavigationButtonRenderer'] as Map<String, dynamic>;
        final name =
            digAs<String>(btn, ['buttonText', 'runs', 0, 'text']) ??
            digAs<String>(btn, ['text', 'runs', 0, 'text']) ??
            digAs<String>(btn, ['title', 'runs', 0, 'text']);
        final params =
            digAs<String>(btn, ['clickCommand', 'browseEndpoint', 'params']) ??
            digAs<String>(btn, ['endpoint', 'payload', 'params']);
        final stripeColor = digAs<int>(btn, ['solid', 'leftStripeColor']);

        if (name != null &&
            params != null &&
            name.isNotEmpty &&
            seenNames.add(name)) {
          out.add(
            MoodCategory(name: name, params: params, stripeColor: stripeColor),
          );
        }
        return;
      }

      node.values.forEach(walk);
    }

    walk(json);
    return out;
  }

  /// Parses an individual mood category page with playlists and featured songs.
  MoodPageData parseMoodPage(Map<String, dynamic> json) {
    final name =
        digAs<String>(json, [
          'header',
          'musicHeaderRenderer',
          'title',
          'runs',
          0,
          'text',
        ]) ??
        digAs<String>(json, ['header', 'title', 'runs', 0, 'text']) ??
        'Mood';

    final playlists = parseHomePlaylists(json);
    final tracks = <Track>[];
    final seen = <String>{};

    void walkSongs(dynamic node) {
      if (node == null) return;
      if (node is List) {
        node.forEach(walkSongs);
        return;
      }
      if (node is! Map<String, dynamic>) return;

      if (node.containsKey('musicResponsiveListItemRenderer')) {
        final item =
            node['musicResponsiveListItemRenderer'] as Map<String, dynamic>;
        final track = _parseSongItem(item);
        if (track != null && seen.add(track.id)) {
          tracks.add(track);
        }
        return;
      }

      if (node.containsKey('musicTwoRowItemRenderer')) {
        final item = node['musicTwoRowItemRenderer'] as Map<String, dynamic>;
        final videoId =
            digAs<String>(item, [
              'navigationEndpoint',
              'watchEndpoint',
              'videoId',
            ]) ??
            digAs<String>(item, [
              'thumbnailOverlay',
              'musicItemThumbnailOverlayRenderer',
              'content',
              'musicPlayButtonRenderer',
              'playNavigationEndpoint',
              'watchEndpoint',
              'videoId',
            ]);
        if (videoId != null && videoId.length == 11 && seen.add(videoId)) {
          final track = _parseTwoRowSongItem(item, videoId);
          if (track != null) {
            tracks.add(track);
          }
        }
        return;
      }

      node.values.forEach(walkSongs);
    }

    walkSongs(json);
    return MoodPageData(
      name: name,
      playlists: playlists.length > 24 ? playlists.sublist(0, 24) : playlists,
      tracks: tracks.length > 40 ? tracks.sublist(0, 40) : tracks,
    );
  }

  Track? _parseTwoRowSongItem(Map<String, dynamic> item, String videoId) {
    final title = digAs<String>(item, ['title', 'runs', 0, 'text']) ?? 'Song';
    var artistName = 'Unknown artist';
    String? artistChannelId;

    final subRuns = dig(item, ['subtitle', 'runs']) as List?;
    if (subRuns != null) {
      for (final run in subRuns) {
        if (run is! Map<String, dynamic>) continue;
        final t = run['text'] as String? ?? '';
        final bid = digAs<String>(run, [
          'navigationEndpoint',
          'browseEndpoint',
          'browseId',
        ]);
        if (bid != null && RegExp('^(UC|MPLA|FE)').hasMatch(bid)) {
          artistName = t;
          artistChannelId = bid;
          break;
        } else if (artistName == 'Unknown artist' && t.isNotEmpty && t != '•') {
          artistName = t;
        }
      }
    }

    final effectiveArtistId = artistChannelId != null
        ? 'yt-$artistChannelId'
        : 'yt-$artistName';
    final fallbackThumb = 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';
    final artwork = parseArtwork(
      item['thumbnailRenderer'] ?? item['thumbnail'],
      fallback: fallbackThumb,
    );

    return Track(
      id: 'yt-$videoId',
      source: TrackSource.yt,
      streamId: videoId,
      title: title,
      artwork: artwork,
      artist: Artist(
        id: effectiveArtistId,
        streamId: artistChannelId,
        name: artistName,
        handle: artistName,
      ),
    );
  }

  /// Parses UpNext / radio autoplay recommendations from `/next` response.
  List<Track> parseUpNext(Map<String, dynamic> json, {int limit = 40}) {
    final tracks = <Track>[];
    final seen = <String>{};

    void walk(dynamic node) {
      if (node == null) return;
      if (node is List) {
        node.forEach(walk);
        return;
      }
      if (node is! Map<String, dynamic>) return;

      if (node.containsKey('playlistPanelVideoRenderer')) {
        final item = node['playlistPanelVideoRenderer'] as Map<String, dynamic>;
        final track = _parsePanelVideo(item);
        if (track != null && seen.add(track.id) && tracks.length < limit) {
          tracks.add(track);
        }
        return;
      }

      if (node.containsKey('musicResponsiveListItemRenderer')) {
        final item =
            node['musicResponsiveListItemRenderer'] as Map<String, dynamic>;
        final track = _parseSongItem(item);
        if (track != null && seen.add(track.id) && tracks.length < limit) {
          tracks.add(track);
        }
        return;
      }

      node.values.forEach(walk);
    }

    walk(json);
    return tracks;
  }

  Track? _parsePanelVideo(Map<String, dynamic> item) {
    final videoId =
        digAs<String>(item, ['videoId']) ??
        digAs<String>(item, ['navigationEndpoint', 'watchEndpoint', 'videoId']);

    if (videoId == null || videoId.length != 11) return null;

    final rawTitle =
        digAs<String>(item, ['title', 'runs', 0, 'text']) ??
        digAs<String>(item, ['title', 'text']) ??
        'Untitled';
    final title = cleanSongTitle(rawTitle);

    var artistName = 'Unknown artist';
    String? channelId;
    String? albumName;
    String? albumBrowseId;

    final runs =
        dig(item, ['longBylineText', 'runs']) as List? ??
        dig(item, ['artists']) as List?;

    if (runs != null) {
      for (final run in runs) {
        if (run is! Map<String, dynamic>) continue;
        final runText = (run['text'] as String? ?? '').trim();
        if (runText.isEmpty || runText == '•') continue;

        final bid = digAs<String>(run, [
          'navigationEndpoint',
          'browseEndpoint',
          'browseId',
        ]);
        if (bid != null && RegExp('^(UC|MPLA|FE)').hasMatch(bid)) {
          artistName = runText;
          channelId = bid;
        } else if (bid != null && bid.startsWith('MPRE')) {
          albumName = runText;
          albumBrowseId = bid;
        } else if (artistName == 'Unknown artist') {
          artistName = runText;
        }
      }
    } else {
      final shortByline = digAs<String>(item, [
        'shortBylineText',
        'runs',
        0,
        'text',
      ]);
      if (shortByline != null) artistName = shortByline;
    }

    final durationText =
        digAs<String>(item, ['lengthText', 'runs', 0, 'text']) ??
        digAs<String>(item, ['duration', 'runs', 0, 'text']) ??
        '';
    final durationSec = parseDuration(durationText);

    final vi = 'https://i.ytimg.com/vi/$videoId';
    final artwork =
        parseArtwork(item['thumbnail']) ??
        Artwork(
          s150: '$vi/hqdefault.jpg',
          s480: '$vi/hqdefault.jpg',
          s1000: '$vi/maxresdefault.jpg',
        );

    final artistId = channelId != null ? 'yt-$channelId' : 'yt-$artistName';

    return Track(
      id: 'yt-$videoId',
      source: TrackSource.yt,
      streamId: videoId,
      title: title,
      duration: durationSec,
      artwork: artwork,
      artist: Artist(
        id: artistId,
        streamId: channelId,
        name: artistName,
        handle: artistName,
      ),
      album: albumName != null
          ? AlbumRef(id: albumBrowseId ?? '', name: albumName)
          : null,
    );
  }

  Track? _parseSongItem(Map<String, dynamic> item) {
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

    final flexCols =
        item['flexColumns'] as List? ?? item['flex_columns'] as List?;
    if (flexCols != null) {
      for (var i = 1; i < flexCols.length; i++) {
        final col = flexCols[i];
        if (col is! Map<String, dynamic>) continue;

        // Note: handles both
        // col.musicResponsiveListItemFlexColumnRenderer.text.runs
        // and flex_columns[1].title.runs
        final runs =
            dig(col, [
              'musicResponsiveListItemFlexColumnRenderer',
              'text',
              'runs',
            ]) as List? ??
            dig(col, ['text', 'runs']) as List? ??
            dig(col, ['title', 'runs']) as List?;

        if (runs == null) continue;
        for (final run in runs) {
          if (run is! Map<String, dynamic>) continue;
          final runText = (run['text'] as String? ?? '').trim();
          if (runText.isEmpty || runText == '•') continue;

          final bid =
              digAs<String>(run, [
                'navigationEndpoint',
                'browseEndpoint',
                'browseId',
              ]) ??
              digAs<String>(run, ['endpoint', 'payload', 'browseId']);

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
    final artwork = parseArtwork(item['thumbnail'], fallback: fallbackThumb);

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

  RemotePlaylist? _mapTwoRowPlaylist(Map<String, dynamic> raw) {
    final item = raw['musicTwoRowItemRenderer'] as Map<String, dynamic>? ?? raw;

    final browseId =
        digAs<String>(item, [
          'navigationEndpoint',
          'browseEndpoint',
          'browseId',
        ]) ??
        digAs<String>(item, [
          'title',
          'runs',
          0,
          'navigationEndpoint',
          'browseEndpoint',
          'browseId',
        ]);

    if (browseId == null ||
        !RegExp('^(VL|PL|RD|OLAK|MPRE)').hasMatch(browseId)) {
      return null;
    }

    final isAlbum = browseId.startsWith('MPRE') || browseId.startsWith('OLAK');
    final route = isAlbum && browseId.startsWith('MPRE') ? 'ytalb' : 'ytpl';

    final name =
        digAs<String>(item, ['title', 'runs', 0, 'text']) ?? 'Playlist';

    var ownerName = 'Editorial';
    final subRuns = dig(item, ['subtitle', 'runs']) as List?;
    if (subRuns != null && subRuns.isNotEmpty) {
      final subText = subRuns
          .whereType<Map<String, dynamic>>()
          .map((r) => r['text'] as String? ?? '')
          .join()
          .trim();
      final cleaned = subText
          .replaceFirst(RegExp(r'^playlist\s*•?\s*', caseSensitive: false), '')
          .split('•')
          .first
          .trim();
      if (cleaned.isNotEmpty &&
          !cleaned.toLowerCase().contains('youtube music')) {
        ownerName = cleaned;
      }
    }

    final artwork = parseArtwork(
      item['thumbnailRenderer'] ?? item['thumbnail'],
    );

    return RemotePlaylist(
      id: '$route-$browseId',
      name: name,
      isAlbum: isAlbum,
      artwork: artwork,
      owner: Artist(id: 'yt-va', name: ownerName, handle: ownerName),
    );
  }
}
