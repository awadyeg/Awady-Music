import 'package:awady_music/data/sources/lyrics/lrc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LRC Parser', () {
    test('Parses standard LRC timestamps and text', () {
      const lrc = '''
[ti:Sample Song]
[ar:Artist Name]
[00:12.50] Hello world
[00:15.80] This is a second line
[01:02.00] Third line in minute one
''';

      final lines = parseLrc(lrc);
      expect(lines.length, 3);
      expect(lines[0].startMs, 12500);
      expect(lines[0].text, 'Hello world');
      expect(lines[1].startMs, 15800);
      expect(lines[1].text, 'This is a second line');
      expect(lines[2].startMs, 62000);
      expect(lines[2].text, 'Third line in minute one');
    });

    test('Parses repeated multi-stamps on single line and sorts results', () {
      const lrc = '''
[00:10.00][00:40.00] Repeated chorus line
[00:25.00] Verse line in between
''';

      final lines = parseLrc(lrc);
      expect(lines.length, 3);
      expect(lines[0].startMs, 10000);
      expect(lines[0].text, 'Repeated chorus line');
      expect(lines[1].startMs, 25000);
      expect(lines[1].text, 'Verse line in between');
      expect(lines[2].startMs, 40000);
      expect(lines[2].text, 'Repeated chorus line');
    });

    test('Applies [offset:±ms] metadata tag to shift timestamps', () {
      const lrcWithOffset = '''
[offset:+500]
[00:10.00] Shifted by half a second
''';

      final lines = parseLrc(lrcWithOffset);
      expect(lines.length, 1);
      expect(lines[0].startMs, 10500);

      const lrcNegative = '''
[offset:-500]
[00:10.00] Shifted earlier
[00:00.20] Clamped to zero
''';
      final negLines = parseLrc(lrcNegative);
      expect(negLines[0].startMs, 0); // clamped at 0
      expect(negLines[1].startMs, 9500);
    });

    test('Strips enhanced LRC inline word markers and tags', () {
      const enhancedLrc = '''
[00:05.20] <00:05.20> Never <00:05.80> gonna <00:06.10> give [00:06.50] you up
''';

      final lines = parseLrc(enhancedLrc);
      expect(lines.length, 1);
      expect(lines[0].startMs, 5200);
      expect(lines[0].text, 'Never gonna give you up');
    });

    test('Handles 3-digit and 1-digit fractional seconds', () {
      const lrc = '''
[00:01.5] Tenths of a second
[00:02.123] Milliseconds
''';

      final lines = parseLrc(lrc);
      expect(lines.length, 2);
      expect(lines[0].startMs, 1500);
      expect(lines[1].startMs, 2123);
    });
  });

  group('sheetFingerprint', () {
    test('Generates normalized token fingerprint from tail lines', () {
      final lines = parseLrc('''
[00:01.00] Spoken intro line
[00:05.00] First verse
[00:10.00] Second verse
[00:15.00] One more time!
[00:20.00] Yeah, we are dancing!
[00:25.00] Goodnight, café résumé!
''');

      final fp = sheetFingerprint(lines);
      // Takes last 3 lines: "One more time!", "Yeah, we are dancing!",
      // "Goodnight, café résumé!"
      // Strips diacritics and lowercases
      expect(fp, contains('one more time'));
      expect(fp, contains('yeah we are dancing'));
      expect(fp, contains('goodnight cafe resume'));
      expect(fp.length, lessThanOrEqualTo(64));
    });

    test('Ignores ♪ display markers in fingerprint calculation', () {
      final lines = parseLrc('''
[00:01.00] Real lyric line 1
[00:05.00] Real lyric line 2
[00:10.00] Real lyric line 3
[00:15.00] ♪
''');

      final fp = sheetFingerprint(lines);
      expect(fp, isNot(contains('♪')));
      expect(fp, contains('real lyric line 1'));
      expect(fp, contains('real lyric line 3'));
    });
  });

  group('formatLrc', () {
    test('Round-trips formatted lines', () {
      final lines = parseLrc('''
[00:10.50] Hello
[01:20.00] World
''');

      final formatted = formatLrc(lines);
      final reparsed = parseLrc(formatted);
      expect(reparsed.length, 2);
      expect(reparsed[0].startMs, 10500);
      expect(reparsed[0].text, 'Hello');
      expect(reparsed[1].startMs, 80000);
      expect(reparsed[1].text, 'World');
    });
  });
}
