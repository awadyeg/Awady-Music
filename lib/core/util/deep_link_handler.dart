import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';

class DeepLinkHandler {
  DeepLinkHandler({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  void init(GoRouter router) {
    unawaited(
      _appLinks
          .getInitialLink()
          .then((uri) {
            if (uri != null) {
              handleUri(uri, router);
            }
          })
          .catchError((_) {}),
    );

    _sub = _appLinks.uriLinkStream.listen((uri) {
      handleUri(uri, router);
    }, onError: (_) {});
  }

  static void handleUri(Uri uri, GoRouter router) {
    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();
    final path = uri.path;

    // Handle custom scheme: awadymusic://...
    if (scheme == 'awadymusic') {
      if (host == 'playlist' || path.startsWith('/playlist')) {
        final id = host == 'playlist'
            ? path.replaceFirst('/', '')
            : path.replaceFirst('/playlist/', '');
        if (id.isNotEmpty) {
          unawaited(router.push('/playlist/$id'));
          return;
        }
      }

      if (host == 'artist' || path.startsWith('/artist')) {
        final id = host == 'artist'
            ? path.replaceFirst('/', '')
            : path.replaceFirst('/artist/', '');
        if (id.isNotEmpty) {
          unawaited(router.push('/artist/$id'));
          return;
        }
      }

      if (host == 'import' || path.startsWith('/import')) {
        final url = uri.queryParameters['url'] ?? '';
        unawaited(router.push('/import?url=${Uri.encodeComponent(url)}'));
        return;
      }
    }

    // Handle shared Spotify or YouTube links
    final urlStr = uri.toString();
    if (urlStr.contains('spotify.com') ||
        urlStr.contains('youtube.com') ||
        urlStr.contains('youtu.be')) {
      unawaited(router.push('/import?url=${Uri.encodeComponent(urlStr)}'));
    }
  }

  void dispose() {
    unawaited(_sub?.cancel());
  }
}
