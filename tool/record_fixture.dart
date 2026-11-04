import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final outDir = Directory('test/fixtures/innertube');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  final client = HttpClient();

  // 1. Session bootstrap from music.youtube.com
  stdout.writeln('Bootstrapping session from music.youtube.com...');
  final bootReq = await client.getUrl(Uri.parse('https://music.youtube.com/'));
  bootReq.headers.set(
    'User-Agent',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36',
  );
  bootReq.headers.set('Accept-Language', 'en-US,en;q=0.9');
  final bootRes = await bootReq.close();
  final html = await bootRes.transform(utf8.decoder).join();

  final apiKey =
      RegExp('"INNERTUBE_API_KEY":"([^"]+)"').firstMatch(html)?.group(1) ??
      'AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8';
  final clientVersion =
      RegExp('"INNERTUBE_CLIENT_VERSION":"([^"]+)"')
          .firstMatch(html)
          ?.group(1) ??
      '1.20241028.01.00';
  final visitorData = RegExp('"VISITOR_DATA":"([^"]+)"')
      .firstMatch(html)
      ?.group(1);

  stdout.writeln(
    'Session bootstrapped: version=$clientVersion, visitorData=$visitorData',
  );

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse(
      'https://music.youtube.com/youtubei/v1/$endpoint?prettyPrint=false&key=$apiKey',
    );
    final req = await client.postUrl(uri);
    req.headers.set('Content-Type', 'application/json');
    req.headers.set(
      'User-Agent',
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36',
    );
    req.headers.set('X-YouTube-Client-Name', '67');
    req.headers.set('X-YouTube-Client-Version', clientVersion);
    req.headers.set('X-Origin', 'https://music.youtube.com');

    final payload = {
      'context': {
        'client': {
          'clientName': 'WEB_REMIX',
          'clientVersion': clientVersion,
          'visitorData': ?visitorData,
          'hl': 'en',
          'gl': 'US',
        },
      },
      ...body,
    };
    req.add(utf8.encode(jsonEncode(payload)));
    final res = await req.close();
    final resText = await res.transform(utf8.decoder).join();
    return jsonDecode(resText) as Map<String, dynamic>;
  }

  void saveFixture(String filename, Map<String, dynamic> data) {
    final file = File('${outDir.path}/$filename');
    const encoder = JsonEncoder.withIndent('  ');
    file.writeAsStringSync(encoder.convert(data));
    stdout.writeln('Saved ${file.path} (${file.lengthSync()} bytes)');
  }

  // Record all required fixtures
  stdout.writeln('Recording search "adele"...');
  final search = await post('search', {'query': 'adele'});
  saveFixture('search_adele.json', search);

  stdout.writeln('Recording suggestions for "adele"...');
  final suggestions = await post('music/get_search_suggestions', {
    'input': 'adele',
  });
  saveFixture('suggestions.json', suggestions);

  stdout.writeln('Recording artist "adele"...');
  final artist = await post('browse', {'browseId': 'UCRw0x9_EfawqmgDI2IgQLLg'});
  saveFixture('artist_adele.json', artist);

  stdout.writeln('Recording album...');
  final album = await post('browse', {'browseId': 'MPREb_PiyfuVl6aYd'});
  saveFixture('album.json', album);

  stdout.writeln('Recording playlist...');
  final playlist = await post('browse', {
    'browseId': 'VLPLxWkvkj3MUF9nih7I2YHwny7GU3Cd9WN0',
  });
  saveFixture('playlist.json', playlist);

  stdout.writeln('Recording home...');
  final home = await post('browse', {'browseId': 'FEmusic_home'});
  saveFixture('home.json', home);

  stdout.writeln('Recording explore...');
  final explore = await post('browse', {'browseId': 'FEmusic_explore'});
  saveFixture('explore.json', explore);

  stdout.writeln('Recording charts...');
  final charts = await post('browse', {'browseId': 'FEmusic_charts'});
  saveFixture('charts.json', charts);

  stdout.writeln('Recording new releases...');
  final newReleases = await post('browse', {
    'browseId': 'FEmusic_new_releases',
  });
  saveFixture('new_releases.json', newReleases);

  stdout.writeln('Recording moods...');
  final moods = await post('browse', {'browseId': 'FEmusic_moods_and_genres'});
  saveFixture('moods.json', moods);

  stdout.writeln('Recording one mood...');
  final moodPage = await post('browse', {
    'browseId': 'FEmusic_moods_and_genres_category',
    'params': 'ggMPOg1uX1JOQWZFeDByc2Jm',
  });
  saveFixture('mood_page.json', moodPage);

  stdout.writeln('Recording next(videoId)...');
  final next = await post('next', {'videoId': 'jb5g4UFHmfQ'});
  saveFixture('next.json', next);

  stdout.writeln('Done recording all fixtures!');
}
