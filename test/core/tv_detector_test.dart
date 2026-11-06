import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/core/util/tv_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TvDetector & Layout tests', () {
    testWidgets('isTvLayout returns true on 1080p landscape TV display', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      late bool detected;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              detected = isTvLayout(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(detected, isTrue);
    });

    testWidgets('isTvLayout returns false on portrait phone display', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      late bool detected;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              detected = isTvLayout(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(detected, isFalse);
    });

    test('isTvModeProvider respects user settings toggle', () {
      final container = ProviderContainer(
        overrides: [
          settingsProvider.overrideWith(
            () => _FakeSettingsNotifier(const AppSettings(tvMode: 'on')),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(isTvModeProvider), isTrue);

      final containerOff = ProviderContainer(
        overrides: [
          settingsProvider.overrideWith(
            () => _FakeSettingsNotifier(const AppSettings(tvMode: 'off')),
          ),
        ],
      );
      addTearDown(containerOff.dispose);

      expect(containerOff.read(isTvModeProvider), isFalse);
    });
  });
}

class _FakeSettingsNotifier extends Notifier<AppSettings>
    implements SettingsNotifier {
  _FakeSettingsNotifier(this._initial);

  final AppSettings _initial;

  @override
  AppSettings build() => _initial;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
