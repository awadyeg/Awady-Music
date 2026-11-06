import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Checks if the host Android OS identifies as an Android TV device.
final isNativeTvProvider = FutureProvider<bool>((ref) async {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    try {
      const channel = MethodChannel('com.awady.awady_music/tv');
      final isTv = await channel.invokeMethod<bool>('isTelevision');
      return isTv ?? false;
    } on Object catch (_) {
      return false;
    }
  }
  return false;
});

/// Indicates whether TV mode is currently active based on user settings
/// and system detection.
final isTvModeProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  if (settings.tvMode == 'on') return true;
  if (settings.tvMode == 'off') return false;
  final nativeTv = ref.watch(isNativeTvProvider).value ?? false;
  return nativeTv;
});

/// Utility for detecting 16:9 big screen / TV layout.
bool isTvLayout(BuildContext context, [WidgetRef? ref]) {
  if (ref != null && ref.watch(isTvModeProvider)) {
    return true;
  }
  final size = MediaQuery.sizeOf(context);
  final isLandscape = size.width > size.height;
  final isBigScreen = size.width >= 960 && (size.width / size.height) >= 1.5;
  return isLandscape && isBigScreen;
}
