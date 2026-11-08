import 'dart:io';

import 'package:awady_music/widgets/update_banner.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  test('current version matches pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(
      pubspec,
      contains(
        'version: ${UpdateChecker.currentVersion}+'
        '${UpdateChecker.currentBuild}',
      ),
    );
  });

  group('UpdateChecker tests', () {
    late Dio dio;
    late DioAdapter dioAdapter;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://api.github.com'));
      dioAdapter = DioAdapter(dio: dio);
    });

    test('returns AppUpdateInfo when newer release is found', () async {
      dioAdapter.onGet(
        'https://api.github.com/repos/awadyeg/Awady-Music/releases/latest',
        (server) => server.reply(200, {
          'tag_name': 'v1.1.0',
          'body': 'Exciting new features and bug fixes',
          'html_url':
              'https://github.com/awadyeg/Awady-Music/releases/tag/v1.1.0',
          'assets': [
            {
              'name': 'app-arm64-v8a-release.apk',
              'browser_download_url': 'https://github.com/awadyeg/Awady-Music/releases/download/v1.1.0/app-arm64-v8a-release.apk',
            },
          ],
        }),
      );

      final update = await UpdateChecker.checkForUpdate(dio: dio);
      expect(update, isNotNull);
      expect(update!.version, '1.1.0');
      expect(
        update.downloadUrl,
        'https://github.com/awadyeg/Awady-Music/releases/download/v1.1.0/app-arm64-v8a-release.apk',
      );
      expect(update.releaseNotes, 'Exciting new features and bug fixes');
    });

    test('returns null when current version is up to date', () async {
      dioAdapter.onGet(
        'https://api.github.com/repos/awadyeg/Awady-Music/releases/latest',
        (server) => server.reply(200, {
          'tag_name': 'v1.0.2',
          'body': 'Initial release',
        }),
      );

      final update = await UpdateChecker.checkForUpdate(dio: dio);
      expect(update, isNull);
    });

    test('returns null gracefully on server error', () async {
      dioAdapter.onGet(
        'https://api.github.com/repos/awadyeg/Awady-Music/releases/latest',
        (server) => server.reply(500, {'message': 'Server error'}),
      );

      final update = await UpdateChecker.checkForUpdate(dio: dio);
      expect(update, isNull);
    });
  });
}
