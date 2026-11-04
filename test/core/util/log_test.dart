import 'dart:io';

import 'package:awady_music/core/util/log.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;

  setUp(() async {
    Log.resetForTesting();
    tempDir = await Directory.systemTemp.createTemp('log_test_');
  });

  tearDown(() async {
    Log.resetForTesting();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('Log writes info, warning, and error messages to main.log', () async {
    await Log.init(directory: tempDir);

    Log.i('Test info message');
    Log.w('Test warning message');
    Log.e('Test error message', Exception('Test error'));

    final logFile = File(p.join(tempDir.path, 'main.log'));
    expect(logFile.existsSync(), isTrue);

    final content = await logFile.readAsString();
    expect(content, contains('[INFO ] Test info message'));
    expect(content, contains('[WARN ] Test warning message'));
    expect(content, contains('[ERROR] Test error message'));
    expect(content, contains('Exception: Test error'));
  });

  test('Log rotates files when maxSizeBytes is reached', () async {
    await Log.init(directory: tempDir, maxSizeBytes: 200);

    for (var i = 0; i < 20; i++) {
      Log.i('Message number $i: padding text to exceed byte limits quickly');
    }

    final mainLog = File(p.join(tempDir.path, 'main.log'));
    final backup1 = File(p.join(tempDir.path, 'main.1.log'));

    expect(mainLog.existsSync(), isTrue);
    expect(backup1.existsSync(), isTrue);

    final files = Log.getLogFiles();
    expect(files.length, greaterThanOrEqualTo(2));
    expect(files.length, lessThanOrEqualTo(4));
  });
}
