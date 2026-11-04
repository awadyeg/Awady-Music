import 'package:awady_music/data/models/album_ref.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/artist_page.dart';
import 'package:awady_music/data/models/artwork.dart';
import 'package:awady_music/data/models/enums.dart';
import 'package:awady_music/data/models/remote_playlist.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/sources/innertube/innertube_client.dart';
import 'package:awady_music/data/sources/innertube/parsers/search_parser.dart';

/// Parser for Innertube artist browse pages and MPAD discography endpoints.
class ArtistParser {
  const ArtistParser();

  /// Parses the full artist browse response into [ArtistPage].
  ArtistPage parseArtistPage(
    Map<String, dynamic> json, {
    String? channelId,
    String? nameHint,
  }) {
    // 1. Header parsing
    final header =
        dig(json, ['header', 'musicImmersiveHeaderRenderer'])
            as Map<String, dynamic>? ??
        dig(json, ['header', 'musicVisualHeaderRenderer'])
            as Map<String, dynamic>? ??
        dig(json, ['header', 'musicHeaderRenderer']) as Map<String, dynamic>? ??
        const <String, dynamic>{};

    final rawName = digAs<String>(header, ['title', 'runs', 0, 'text']);
    final name = (rawName != null && rawName.isNotEmpty)
        ? rawName
        : (nameHint ?? 'Artist');

    final effectiveId = channelId ?? '';
    final id = effectiveId.startsWith('yt-') ? effectiveId : 'yt-$effectiveId';

    final isVerified = _hasVerifiedBadge(header);

    final subText =
        digAs<String>(header, [
          'subscriptionButton',
          'subscribeButtonRenderer',
          'subscriberCountText',
          'runs',
          0,
          'text',
        ]) ??
        digAs<String>(header, ['description', 'runs', 0, 'text']) ??
        '';
    final followerCount = parseCount(subText);

    // Banners & Avatar
    final bannerThumbnails =
        dig(header, [
          'thumbnail',
          'musicThumbnailRenderer',
          'thumbnail',
          'thumbnails',
        ]) as List? ??
        dig(header, [
          'foregroundThumbnail',
          'musicThumbnailRenderer',
          'thumbnail',
          'thumbnails',
        ]) as List?;

    String? coverPhotoUrl;
    Artwork? avatarArtwork;

    if (bannerThumbnails != null && bannerThumbnails.isNotEmpty) {
      final urls = bannerThumbnails
          .whereType<Map<String, dynamic>>()
          .map((t) => t['url'] as String? ?? '')
          .where((u) => u.isNotEmpty)
          .toList();
      if (urls.isNotEmpty) {
        coverPhotoUrl = urls.last;
        avatarArtwork = Artwork(
          s150: urls.first,
          s480: urls.length > 1 ? urls[urls.length ~/ 2] : urls.last,
          s1000: urls.last,
        );
      }
    }

    String? bio;
    final topSongs = <Track>[];
    final albums = <RemotePlaylist>[];
    final singles = <RemotePlaylist>[];

    // 2. Section Shelves
    final shelves = dig(json, [
      'contents',
      'singleColumnBrowseResultsRenderer',
      'tabs',
      0,
      'tabRenderer',
      'content',
      'sectionListRenderer',
      'contents',
    ]) as List?;

    if (shelves != null) {
      for (final shelf in shelves) {
        if (shelf is! Map<String, dynamic>) continue;

        // A. Top Songs (musicShelfRenderer)
        if (shelf.containsKey('musicShelfRenderer')) {
          final msr = shelf['musicShelfRenderer'] as Map<String, dynamic>;
          final shelfTitle =
              digAs<String>(msr, ['title', 'runs', 0, 'text']) ?? '';
          if (RegExp(
                'songs|canciones|top',
                caseSensitive: false,
              ).hasMatch(shelfTitle) ||
              topSongs.isEmpty) {
            final items = msr['contents'] as List?;
            if (items != null) {
              for (final item in items) {
                if (item is! Map<String, dynamic>) continue;
                final track = _parseArtistSongItem(
                  item,
                  artistName: name,
                  artistChannelId: effectiveId,
                );
                if (track != null && topSongs.length < 50) {
                  topSongs.add(track);
                }
              }
            }
          }
        }
        // B. Releases Carousels (musicCarouselShelfRenderer)
        else if (shelf.containsKey('musicCarouselShelfRenderer')) {
          final mcsr =
              shelf['musicCarouselShelfRenderer'] as Map<String, dynamic>;
          final shelfTitle =
              digAs<String>(mcsr, [
                'header',
                'musicCarouselShelfBasicHeaderRenderer',
                'title',
                'runs',
                0,
                'text',
              ]) ??
              '';
          final isAlbumShelf = RegExp(
            'album|álbum',
            caseSensitive: false,
          ).hasMatch(shelfTitle);
          final isSingleShelf = RegExp(
            r'single|sencillo|\bep\b',
            caseSensitive: false,
          ).hasMatch(shelfTitle);

          final items = mcsr['contents'] as List?;
          if (items != null && (isAlbumShelf || isSingleShelf)) {
            for (final item in items) {
              if (item is! Map<String, dynamic>) continue;
              final pl = _parseCarouselAlbumRow(item, artistName: name);
              if (pl != null) {
                if (isAlbumShelf) {
                  albums.add(pl);
                } else {
                  singles.add(pl);
                }
              }
            }
          }
        }
        // C. Description / Bio (musicDescriptionShelfRenderer)
        else if (shelf.containsKey('musicDescriptionShelfRenderer')) {
          final mdsr =
              shelf['musicDescriptionShelfRenderer'] as Map<String, dynamic>;
          bio ??= digAs<String>(mdsr, ['description', 'runs', 0, 'text']);
        }
      }
    }

    final artist = Artist(
      id: id,
      streamId: effectiveId.isNotEmpty ? effectiveId : null,
      name: name,
      handle: name,
      isVerified: isVerified,
      followerCount: followerCount,
      trackCount: topSongs.length,
      profilePicture: avatarArtwork,
      coverPhoto: coverPhotoUrl,
      bio: bio,
    );

    return ArtistPage(
      artist: artist,
      topSongs: topSongs,
      albums: albums,
      singles: singles,
      bio: bio,
    );
  }

  /// Parses raw MPAD full discography responses into separate albums and
  /// singles.
  ({List<RemotePlaylist> albums, List<RemotePlaylist> singles})
  parseMpadDiscography(Map<String, dynamic> json, String artistName) {
    final albums = <RemotePlaylist>[];
    final singles = <RemotePlaylist>[];
    final seen = <String>{};

    void walk(dynamic node) {
      if (node == null) return;
      if (node is List) {
        node.forEach(walk);
        return;
      }
      if (node is! Map<String, dynamic>) return;

      if (node.containsKey('musicTwoRowItemRenderer')) {
        final item = node['musicTwoRowItemRenderer'] as Map<String, dynamic>;
        final pl = _parseCarouselAlbumRow({
          'musicTwoRowItemRenderer': item,
        }, artistName: artistName);
        if (pl != null && seen.add(pl.id)) {
          if (pl.isAlbum) {
            albums.add(pl);
          } else {
            singles.add(pl);
          }
        }
        return;
      }

      node.values.forEach(walk);
    }

    walk(json);
    return (albums: albums, singles: singles);
  }

  bool _hasVerifiedBadge(Map<String, dynamic> header) {
    final badges =
        header['badges'] as List? ??
        dig(header, ['title', 'runs', 0, 'badges']) as List? ??
        header['subtitleBadges'] as List?;
    if (badges != null) {
      for (final b in badges) {
        if (b is! Map<String, dynamic>) continue;
        final iconType =
            digAs<String>(b, [
              'musicInlineBadgeRenderer',
              'icon',
              'iconType',
            ]) ??
            '';
        final tooltip =
            digAs<String>(b, [
              'musicInlineBadgeRenderer',
              'accessibilityData',
              'accessibilityData',
              'label',
            ]) ??
            digAs<String>(b, ['musicInlineBadgeRenderer', 'tooltip']) ??
            '';
        final combined = '$iconType $tooltip'.toLowerCase();
        if (combined.contains('verif') || combined.contains('official')) {
          return true;
        }
      }
    }
    return false;
  }

  Track? _parseArtistSongItem(
    Map<String, dynamic> raw, {
    required String artistName,
    required String artistChannelId,
  }) {
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

    var playCount = 0;
    var durationSec = 0;
    String? albumName;
    String? albumId;

    // Explore all flex columns for plays, duration, album
    final flexCols = item['flexColumns'] as List?;
    if (flexCols != null) {
      for (final col in flexCols) {
        if (col is! Map<String, dynamic>) continue;
        final runs = dig(col, [
          'musicResponsiveListItemFlexColumnRenderer',
          'text',
          'runs',
        ]) as List?;
        if (runs == null) continue;
        for (final run in runs) {
          if (run is! Map<String, dynamic>) continue;
          final runText = run['text'] as String? ?? '';
          if (RegExp(r'^\d{1,3}:\d{2}').hasMatch(runText.trim())) {
            durationSec = parseDuration(runText.trim());
          } else if (RegExp(
            'views|plays|vistas',
            caseSensitive: false,
          ).hasMatch(runText)) {
            playCount = parseCount(runText);
          } else {
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
    }

    // Check fixedColumns for duration
    if (durationSec == 0) {
      final fixedRuns = dig(item, [
        'fixedColumns',
        0,
        'musicResponsiveListItemFixedColumnRenderer',
        'text',
        'runs',
      ]) as List?;
      if (fixedRuns != null) {
        for (final run in fixedRuns) {
          if (run is! Map<String, dynamic>) continue;
          final runText = (run['text'] as String? ?? '').trim();
          if (RegExp(r'^\d{1,3}:\d{2}').hasMatch(runText)) {
            durationSec = parseDuration(runText);
            break;
          }
        }
      }
    }

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
        id: 'yt-${artistChannelId.isNotEmpty ? artistChannelId : artistName}',
        streamId: artistChannelId.isNotEmpty ? artistChannelId : null,
        name: artistName,
        handle: artistName,
      ),
      album: albumName != null
          ? AlbumRef(id: albumId ?? '', name: albumName)
          : null,
    );
  }

  RemotePlaylist? _parseCarouselAlbumRow(
    Map<String, dynamic> raw, {
    required String artistName,
  }) {
    final item = raw['musicTwoRowItemRenderer'] as Map<String, dynamic>? ?? raw;

    final name = digAs<String>(item, ['title', 'runs', 0, 'text']) ?? '';
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

    if (name.isEmpty || browseId == null) return null;

    final subRuns = dig(item, ['subtitle', 'runs']) as List?;
    final subText =
        subRuns
            ?.whereType<Map<String, dynamic>>()
            .map((r) => r['text'] as String? ?? '')
            .join(' ')
            .toLowerCase() ??
        '';

    final isSingle =
        subText.contains('single') ||
        subText.contains('sencillo') ||
        subText.contains('ep');
    final isAlbum = !isSingle;

    final artwork = parseArtwork(
      item['thumbnailRenderer'] ?? item['thumbnail'],
    );

    return RemotePlaylist(
      id: 'ytalb-$browseId',
      name: name,
      isAlbum: isAlbum,
      artwork: artwork,
      owner: Artist(id: 'yt-$artistName', name: artistName, handle: artistName),
    );
  }
}
