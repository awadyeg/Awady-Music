import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:awady_music/app.dart';
import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/core/util/log.dart';
import 'package:awady_music/player/audio_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    JustAudioMediaKit.ensureInitialized();
  }
  await Log.init();
  await initAudioSession();
  final prefs = await SharedPreferences.getInstance();

  AwadyAudioHandler audioHandler;
  try {
    audioHandler = await AudioService.init(
      builder: AwadyAudioHandler.create,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.awady.awady_music.channel.audio',
        androidNotificationChannelName: 'Playback',
        androidNotificationOngoing: true,
        androidShowNotificationBadge: true,
      ),
    );
  } on Object catch (e, st) {
    Log.w('AudioService.init fallback: $e', e, st);
    audioHandler = AwadyAudioHandler.create();
  }

  runApp(
    ProviderScope(
      overrides: [
        audioHandlerProvider.overrideWithValue(audioHandler),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const AwadyMusicApp(),
    ),
  );
}
