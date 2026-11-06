import 'package:awady_music/data/models/album_ref.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/artwork.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/search_results.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';

/// Parsers for Innertube search and search suggestion responses.
class SearchParser {
  const SearchParser();

  /// Parses raw JSON from Innertube `search` endpoint into [SearchResults].
  SearchResults parseSearch(Map<String, dynamic> json) {
    final sections = dig(json, [
      'contents',
      'tabbedSearchResultsRenderer',
      'tabs',
      0,
      'tabRenderer',
      'content',
      'sectionListRenderer',
      'contents',
    ]) as List?;

    if (sections == null || sections.isEmpty) {
      return const SearchResults();
    }

    Object? topResult;
    final songs = <Track>[];
    final artists = <Artist>[];
    final playlists = <RemotePlaylist>[];

    for (final sec in sections) {
      if (sec is! Map<String, dynamic>) continue;

      // 1. Top result card shelf
      if (sec.containsKey('musicCardShelfRenderer')) {
        final cardShelf = sec['musicCardShelfRenderer'] as Map<String, dynamic>;
        topResult = _parseCardShelf(cardShelf);
        continue;
      }

      // 2. Shelf or itemSection renderers
      final items = _extractItems(sec);
      for (final item in items) {
        final type = _detectItemType(item);
        switch (type) {
          case _ItemType.song:
            final track = _parseSongItem(item);
            if (track != null && songs.length < 20) {
              songs.add(track);
            }
          case _ItemType.artist:
            final artist = _parseArtistItem(item);
            if (artist != null && artists.length < 8) {
              artists.add(artist);
            }
          case _ItemType.album:
          case _ItemType.playlist:
            final playlist = _parsePlaylistItem(
              item,
              isAlbum: type == _ItemType.album,
            );
            if (playlist != null && playlists.length < 8) {
              playlists.add(playlist);
            }
          case _ItemType.unknown:
            break;
        }
      }
    }

    return SearchResults(
      top: topResult,
      songs: songs,
      artists: artists,
      playlists: playlists,
    );
  }

  /// Parses search suggestions from `music/get_search_suggestions`.
  List<String> parseSuggestions(Map<String, dynamic> json) {
    final contents = dig(json, [
      'contents',
      0,
      'searchSuggestionsSectionRenderer',
      'contents',
    ]) as List?;

    if (contents == null) return const [];

    final suggestions = <String>[];
    for (final item in contents) {
      if (item is! Map<String, dynamic>) continue;
      final renderer =
          item['searchSuggestionRenderer'] as Map<String, dynamic>?;
      if (renderer == null) continue;

      final query = digAs<String>(renderer, [
        'navigationEndpoint',
        'searchEndpoint',
        'query',
      ]);

      if (query != null && query.trim().isNotEmpty) {
        suggestions.add(query.trim());
      } else {
        final runs = dig(renderer, ['suggestion', 'runs']) as List?;
        if (runs != null) {
          final text = runs
              .whereType<Map<String, dynamic>>()
              .map((r) => r['text'] as String? ?? '')
              .join()
              .trim();
          if (text.isNotEmpty) {
            suggestions.add(text);
          }
        }
      }
      if (suggestions.length >= 10) break;
    }

    return suggestions;
  }

  List<Map<String, dynamic>> _extractItems(Map<String, dynamic> section) {
    if (section.containsKey('musicShelfRenderer')) {
      final shelf = section['musicShelfRenderer'] as Map<String, dynamic>;
      final contents = shelf['contents'] as List?;
      return contents?.whereType<Map<String, dynamic>>().toList() ?? const [];
    }

    if (section.containsKey('itemSectionRenderer')) {
      final isr = section['itemSectionRenderer'] as Map<String, dynamic>;
      final contents = isr['contents'] as List?;
      return contents?.whereType<Map<String, dynamic>>().toList() ?? const [];
    }

    return const [];
  }

  _ItemType _detectItemType(Map<String, dynamic> raw) {
    final item =
        raw['musicResponsiveListItemRenderer'] as Map<String, dynamic>? ??
        raw['musicTwoRowItemRenderer'] as Map<String, dynamic>? ??
        raw;

    final subRuns = dig(item, [
      'flexColumns',
      1,
      'musicResponsiveListItemFlexColumnRenderer',
      'text',
      'runs',
    ]) as List?;

    final subText =
        subRuns
            ?.whereType<Map<String, dynamic>>()
            .map((r) => r['text'] as String? ?? '')
            .join(' ')
            .toLowerCase() ??
        (digAs<String>(item, ['subtitle', 'runs', 0, 'text']) ?? '')
            .toLowerCase();

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
        ]);

    final browseId = digAs<String>(item, [
      'navigationEndpoint',
      'browseEndpoint',
      'browseId',
    ]);

    if (subText.contains('song') || subText.contains('canción')) {
      return _ItemType.song;
    }
    if (subText.contains('artist') || subText.contains('artista')) {
      return _ItemType.artist;
    }
    if (subText.contains('album') ||
        subText.contains('álbum') ||
        subText.contains('single') ||
        subText.contains('ep')) {
      return _ItemType.album;
    }
    if (subText.contains('playlist') || subText.contains('lista')) {
      return _ItemType.playlist;
    }
    if (subText.contains('video')) {
      return _ItemType.song;
    }

    if (videoId != null && videoId.length == 11) {
      return _ItemType.song;
    }
    if (browseId != null) {
      if (browseId.startsWith('UC')) return _ItemType.artist;
      if (browseId.startsWith('MPRE')) return _ItemType.album;
      if (browseId.startsWith('VL') || browseId.startsWith('PL')) {
        return _ItemType.playlist;
      }
    }

    return _ItemType.unknown;
  }

  Object? _parseCardShelf(Map<String, dynamic> shelf) {
    final title =
        digAs<String>(shelf, ['title', 'runs', 0, 'text']) ??
        digAs<String>(shelf, [
          'header',
          'musicCardShelfHeaderBasicRenderer',
          'title',
          'runs',
          0,
          'text',
        ]) ??
        '';
    final subRuns = dig(shelf, ['subtitle', 'runs']) as List?;
    final subtitle = subRuns != null
        ? subRuns
              .whereType<Map<String, dynamic>>()
              .map((r) => r['text'] as String? ?? '')
              .join(' ')
        : (digAs<String>(shelf, ['subtitle', 'runs', 0, 'text']) ?? '');

    var browseId =
        digAs<String>(shelf, [
          'title',
          'runs',
          0,
          'navigationEndpoint',
          'browseEndpoint',
          'browseId',
        ]) ??
        digAs<String>(shelf, [
          'navigationEndpoint',
          'browseEndpoint',
          'browseId',
        ]) ??
        digAs<String>(shelf, ['onTap', 'browseEndpoint', 'browseId']) ??
        digAs<String>(shelf, [
          'header',
          'musicCardShelfHeaderBasicRenderer',
          'title',
          'runs',
          0,
          'navigationEndpoint',
          'browseEndpoint',
          'browseId',
        ]) ??
        '';

    if (browseId.isEmpty) {
      browseId =
          _findArtistBrowseId(shelf['buttons']) ??
          _findArtistBrowseId(shelf['menu']) ??
          '';
    }

    final cleanBrowseId = browseId.replaceFirst(RegExp('^MPLA'), '').trim();
    final artwork = parseArtwork(shelf['thumbnail']);

    if (subtitle.toLowerCase().contains('artist') ||
        subtitle.toLowerCase().contains('artista') ||
        cleanBrowseId.startsWith('UC')) {
      final effectiveId = cleanBrowseId.isNotEmpty ? cleanBrowseId : title;
      if (effectiveId.isEmpty) return null;
      final monthly =
          digAs<String>(shelf, ['subtitle', 'runs', 2, 'text']) ?? subtitle;
      return Artist(
        id: 'yt-$effectiveId',
        streamId: cleanBrowseId.isNotEmpty ? cleanBrowseId : null,
        name: title.isNotEmpty ? title : effectiveId,
        handle: title.isNotEmpty ? title : effectiveId,
        isVerified: true,
        followerCount: parseCount(monthly),
        profilePicture: artwork,
      );
    }

    return null;
  }

  String? _findArtistBrowseId(dynamic node) {
    if (node == null) return null;
    if (node is List) {
      for (final item in node) {
        final found = _findArtistBrowseId(item);
        if (found != null) return found;
      }
      return null;
    }
    if (node is Map) {
      final bid = digAs<String>(node, ['browseEndpoint', 'browseId']);
      if (bid != null && (bid.startsWith('UC') || bid.startsWith('MPLA'))) {
        return bid;
      }
      for (final value in node.values) {
        final found = _findArtistBrowseId(value);
        if (found != null) return found;
      }
    }
    return null;
  }

  Track? _parseSongItem(Map<String, dynamic> raw) {
    final item =
        raw['musicResponsiveListItemRenderer'] as Map<String, dynamic>? ?? raw;

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

    final subRuns = dig(item, [
      'flexColumns',
      1,
      'musicResponsiveListItemFlexColumnRenderer',
      'text',
      'runs',
    ]) as List?;

    String? artistName;
    String? artistChannelId;
    var durationSec = 0;
    var playCount = 0;
    String? albumName;
    String? albumId;

    if (subRuns != null) {
      for (final run in subRuns) {
        if (run is! Map<String, dynamic>) continue;
        final runText = run['text'] as String? ?? '';
        final bid = digAs<String>(run, [
          'navigationEndpoint',
          'browseEndpoint',
          'browseId',
        ]);

        if (bid != null &&
            (bid.startsWith('UC') ||
                bid.startsWith('MPLA') ||
                bid.startsWith('FE'))) {
          artistName ??= runText;
          artistChannelId ??= bid;
        } else if (bid != null && bid.startsWith('MPRE')) {
          albumName = runText;
          albumId = bid;
        } else if (RegExp(r'^\d{1,3}:\d{2}').hasMatch(runText.trim())) {
          durationSec = parseDuration(runText.trim());
        } else if (RegExp(
          'views|plays|vistas',
          caseSensitive: false,
        ).hasMatch(runText)) {
          playCount = parseCount(runText);
        }
      }

      if (artistName == null && subRuns.isNotEmpty) {
        for (final run in subRuns) {
          if (run is! Map<String, dynamic>) continue;
          final runText = (run['text'] as String? ?? '').trim();
          if (runText.isNotEmpty &&
              runText != '•' &&
              !runText.toLowerCase().contains('song') &&
              !runText.toLowerCase().contains('video')) {
            artistName = runText;
            break;
          }
        }
      }
    }

    final col2Runs = dig(item, [
      'flexColumns',
      2,
      'musicResponsiveListItemFlexColumnRenderer',
      'text',
      'runs',
    ]) as List?;
    if (col2Runs != null) {
      for (final run in col2Runs) {
        if (run is! Map<String, dynamic>) continue;
        final runText = run['text'] as String? ?? '';
        if (durationSec == 0 &&
            RegExp(r'^\d{1,3}:\d{2}').hasMatch(runText.trim())) {
          durationSec = parseDuration(runText.trim());
        } else if (RegExp(
          'views|plays|vistas',
          caseSensitive: false,
        ).hasMatch(runText)) {
          playCount = parseCount(runText);
        } else if (albumName == null) {
          final bid = digAs<String>(run, [
            'navigationEndpoint',
            'browseEndpoint',
            'browseId',
          ]);
          if (bid != null && bid.startsWith('MPRE')) {
            albumName = runText;
            albumId = bid;
          }
        }
      }
    }

    // Also check menu for "Go to album" if album was not in flexColumns
    if (albumId == null) {
      final menuItems = dig(item, ['menu', 'menuRenderer', 'items']) as List?;
      if (menuItems != null) {
        for (final mi in menuItems) {
          if (mi is! Map<String, dynamic>) continue;
          final nav = mi['menuNavigationItemRenderer'] as Map<String, dynamic>?;
          if (nav == null) continue;
          final label = digAs<String>(nav, ['text', 'runs', 0, 'text']) ?? '';
          if (label.toLowerCase().contains('album') ||
              label.toLowerCase().contains('álbum')) {
            albumId = digAs<String>(nav, [
              'navigationEndpoint',
              'browseEndpoint',
              'browseId',
            ]);
            albumName ??= label;
            break;
          }
        }
      }
    }

    artistName ??= 'Unknown artist';
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
        id: 'yt-${artistChannelId ?? artistName}',
        streamId: artistChannelId,
        name: artistName,
        handle: artistName,
      ),
      album: albumName != null
          ? AlbumRef(id: albumId ?? '', name: albumName)
          : null,
    );
  }

  Artist? _parseArtistItem(Map<String, dynamic> raw) {
    final item =
        raw['musicResponsiveListItemRenderer'] as Map<String, dynamic>? ??
        raw['musicTwoRowItemRenderer'] as Map<String, dynamic>? ??
        raw;

    final name =
        digAs<String>(item, [
          'flexColumns',
          0,
          'musicResponsiveListItemFlexColumnRenderer',
          'text',
          'runs',
          0,
          'text',
        ]) ??
        digAs<String>(item, ['title', 'runs', 0, 'text']) ??
        '';

    final rawBrowseId =
        digAs<String>(item, [
          'navigationEndpoint',
          'browseEndpoint',
          'browseId',
        ]) ??
        digAs<String>(item, ['onTap', 'browseEndpoint', 'browseId']) ??
        digAs<String>(item, [
          'flexColumns',
          0,
          'musicResponsiveListItemFlexColumnRenderer',
          'text',
          'runs',
          0,
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

    final browseId = rawBrowseId?.replaceFirst(RegExp('^MPLA'), '').trim();

    if (name.isEmpty || browseId == null || !browseId.startsWith('UC')) {
      return null;
    }

    final subRuns = dig(item, [
      'flexColumns',
      1,
      'musicResponsiveListItemFlexColumnRenderer',
      'text',
      'runs',
    ]) as List?;

    var followerCount = 0;
    if (subRuns != null) {
      for (final run in subRuns) {
        if (run is! Map<String, dynamic>) continue;
        final t = run['text'] as String? ?? '';
        if (RegExp(
          'audience|subscriber|seguidor|oyente',
          caseSensitive: false,
        ).hasMatch(t)) {
          followerCount = parseCount(t);
        }
      }
    }

    final artwork = parseArtwork(item['thumbnail']);

    return Artist(
      id: 'yt-$browseId',
      streamId: browseId,
      name: name,
      handle: name,
      followerCount: followerCount,
      profilePicture: artwork,
    );
  }

  RemotePlaylist? _parsePlaylistItem(
    Map<String, dynamic> raw, {
    required bool isAlbum,
  }) {
    final item =
        raw['musicResponsiveListItemRenderer'] as Map<String, dynamic>? ?? raw;

    final name =
        digAs<String>(item, [
          'flexColumns',
          0,
          'musicResponsiveListItemFlexColumnRenderer',
          'text',
          'runs',
          0,
          'text',
        ]) ??
        '';

    final browseId =
        digAs<String>(item, [
          'navigationEndpoint',
          'browseEndpoint',
          'browseId',
        ]) ??
        digAs<String>(item, [
          'flexColumns',
          0,
          'musicResponsiveListItemFlexColumnRenderer',
          'text',
          'runs',
          0,
          'navigationEndpoint',
          'browseEndpoint',
          'browseId',
        ]);

    if (name.isEmpty || browseId == null) return null;

    final subRuns = dig(item, [
      'flexColumns',
      1,
      'musicResponsiveListItemFlexColumnRenderer',
      'text',
      'runs',
    ]) as List?;

    String? owner;
    if (subRuns != null) {
      for (final run in subRuns) {
        if (run is! Map<String, dynamic>) continue;
        final t = (run['text'] as String? ?? '').trim();
        if (t.isNotEmpty &&
            t != '•' &&
            !t.toLowerCase().contains('album') &&
            !t.toLowerCase().contains('playlist') &&
            !t.toLowerCase().contains('single') &&
            !t.toLowerCase().contains('ep')) {
          owner ??= t;
        }
      }
    }
    owner ??= 'YouTube Music';
    final cleanOwner = owner.replaceAll(
      RegExp(r'^YouTube Music$', caseSensitive: false),
      'Editorial',
    );

    final prefix = isAlbum ? 'ytalb' : 'ytpl';
    final artwork = parseArtwork(item['thumbnail']);

    return RemotePlaylist(
      id: '$prefix-$browseId',
      name: name,
      isAlbum: isAlbum,
      artwork: artwork,
      owner: Artist(id: 'yt-$cleanOwner', name: cleanOwner, handle: cleanOwner),
    );
  }
}

enum _ItemType { song, artist, album, playlist, unknown }

Artwork? parseArtwork(dynamic thumbContainer, {String? fallback}) {
  final list =
      dig(thumbContainer, ['thumbnails']) ??
      dig(thumbContainer, ['thumbnail', 'thumbnails']) ??
      dig(thumbContainer, [
        'musicThumbnailRenderer',
        'thumbnail',
        'thumbnails',
      ]);

  if (list is! List || list.isEmpty) {
    if (fallback != null) {
      return Artwork(fallback: fallback);
    }
    return null;
  }

  final urls = <String>[];
  for (final item in list) {
    if (item is Map && item['url'] is String) {
      urls.add(item['url'] as String);
    }
  }

  if (urls.isEmpty) {
    if (fallback != null) {
      return Artwork(fallback: fallback);
    }
    return null;
  }

  final s150 = urls.first;
  var s480 = urls.length > 1 ? urls[urls.length ~/ 2] : urls.last;
  var s1000 = urls.last;

  s480 = _upscaleGoogleThumb(s480, 544);
  s1000 = _upscaleGoogleThumb(s1000, 1080);

  return Artwork(s150: s150, s480: s480, s1000: s1000, fallback: fallback);
}

String _upscaleGoogleThumb(String url, int size) {
  if (url.contains('googleusercontent.com') ||
      url.contains('yt3.ggpht.com') ||
      url.contains('ggpht.com')) {
    return url.replaceAll(
      RegExp(r'=(?:w\d+-h\d+|s\d+)[^?&]*'),
      '=w$size-h$size-l90-rj',
    );
  }
  return url;
}

int parseDuration(String? s) {
  if (s == null || s.isEmpty) return 0;
  final match = RegExp(r'(?:(\d+):)?(\d{1,2}):(\d{2})').firstMatch(s);
  if (match == null) return 0;
  final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
  final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
  final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
  return (hours * 3600) + (minutes * 60) + seconds;
}

int parseCount(String? s) {
  if (s == null || s.isEmpty) return 0;
  final match = RegExp(
    r'([\d.,]+)\s*([KMB])?',
    caseSensitive: false,
  ).firstMatch(s);
  if (match == null) return 0;
  final multStr = (match.group(2) ?? '').toUpperCase();
  final mult = switch (multStr) {
    'K' => 1000,
    'M' => 1000000,
    'B' => 1000000000,
    _ => 1,
  };
  final rawNum = match.group(1)!;
  final cleanNum = multStr.isNotEmpty
      ? rawNum.replaceAll(',', '.')
      : rawNum.replaceAll(RegExp('[,.]'), '');
  final val = double.tryParse(cleanNum) ?? 0.0;
  return (val * mult).round();
}

String cleanSongTitle(String rawTitle) {
  return rawTitle
      .replaceAll(
        RegExp(
          r'\s*[\(\[](video oficial|official video|official audio|audio oficial|official music video|video lyric|lyric video|visualizer)[\)\]]',
          caseSensitive: false,
        ),
        '',
      )
      .trim();
}
