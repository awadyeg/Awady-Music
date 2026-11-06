import 'dart:io';

import 'package:awady_music/data/db/app_database.dart';
import 'package:awady_music/data/models/artist.dart';
import 'package:awady_music/data/models/stream_info.dart';
import 'package:awady_music/data/models/track.dart';
import 'package:awady_music/data/repositories/downloads_repository.dart';
import 'package:awady_music/data/sources/ytstream/stream_resolver_impl.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

class _FakeStreamResolver extends Fake implements StreamResolver {
  @override
  Future<StreamInfo> resolve(String videoId, {bool forceFresh = false}) async {
    return StreamInfo(
      url: Uri.parse('https://example.com/audio/$videoId.m4a'),
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late _FakeStreamResolver streamResolver;
  late Dio dio;
  late DioAdapter dioAdapter;
  late Directory tempDir;
  late DownloadsRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    streamResolver = _FakeStreamResolver();
    dio = Dio(BaseOptions());
    dioAdapter = DioAdapter(dio: dio);
    tempDir = await Directory.systemTemp.createTemp('awady_dl_test_');

    repo = DownloadsRepository(
      db: db,
      streamResolver: streamResolver,
      dio: dio,
      getDownloadsDir: () async => tempDir,
    );
  });

  tearDown(() async {
    repo.dispose();
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('DownloadsRepository tests', () {
    test('sanitizeFilename removes illegal path characters', () {
      final sanitized = DownloadsRepository.sanitizeFilename(
        'AC/DC* & Co.',
        'Track: Title? <Live> | Special',
      );
      expect(sanitized, 'AC_DC_ & Co. - Track_ Title_ _Live_ _ Special');
    });

    test(
      'enqueueDownload downloads audio, renames .part, and persists in DB',
      () async {
        const track = Track(
          id: 'track123',
          title: 'Song Title',
          artist: Artist(id: 'a1', name: 'Cool Artist'),
          duration: 180,
        );

        dioAdapter.onGet(
          'https://example.com/audio/track123.m4a',
          (server) => server.reply(200, [1, 2, 3, 4, 5]),
        );

        await repo.enqueueDownload(track);

        // Wait a moment for async download to finish
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final isDownloaded = await repo.isDownloaded('track123');
        expect(isDownloaded, isTrue);

        final dlRecord = await db.downloadsDao.getDownload('track123');
        expect(dlRecord, isNotNull);
        expect(File(dlRecord!.filePath).existsSync(), isTrue);

        final downloadedTracks = await repo.getDownloadedTracks();
        expect(downloadedTracks.length, 1);
        expect(downloadedTracks.first.title, 'Song Title');
      },
    );

    test('deleteDownload removes file and deletes record from DB', () async {
      const track = Track(
        id: 'delTrack',
        title: 'Delete Me',
        artist: Artist(id: 'a2', name: 'Artist'),
        duration: 200,
      );

      dioAdapter.onGet(
        'https://example.com/audio/delTrack.m4a',
        (server) => server.reply(200, [10, 20, 30]),
      );

      await repo.enqueueDownload(track);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(await repo.isDownloaded('delTrack'), isTrue);

      await repo.deleteDownload('delTrack');

      expect(await repo.isDownloaded('delTrack'), isFalse);
      expect(await db.downloadsDao.getDownload('delTrack'), isNull);
    });

    test('pruneMissing cleans up entries whose files were deleted', () async {
      final dummyPath = '${tempDir.path}/non_existent.m4a';
      await db.downloadsDao.insertDownload(
        'missing_track',
        dummyPath,
        DateTime.now(),
      );

      expect(await db.downloadsDao.getDownload('missing_track'), isNotNull);

      await repo.pruneMissing();

      expect(await db.downloadsDao.getDownload('missing_track'), isNull);
    });
  });
}
