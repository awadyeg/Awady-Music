import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.reduceTransparency = false,
    this.autoplay = true,
  });

  final ThemeMode themeMode;
  final Locale? locale;
  final bool reduceTransparency;
  final bool autoplay;

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? Function()? locale,
    bool? reduceTransparency,
    bool? autoplay,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale != null ? locale() : this.locale,
      reduceTransparency: reduceTransparency ?? this.reduceTransparency,
      autoplay: autoplay ?? this.autoplay,
    );
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

class SettingsNotifier extends Notifier<AppSettings> {
  static const _keyThemeMode = 'settings_theme_mode';
  static const _keyLocale = 'settings_locale';
  static const _keyReduceTransparency = 'settings_reduce_transparency';
  static const _keyAutoplay = 'settings_autoplay';

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    if (prefs == null) {
      unawaited(_initPrefs());
      return const AppSettings();
    }
    return _loadFromPrefs(prefs);
  }

  Future<void> _initPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = _loadFromPrefs(prefs);
  }

  AppSettings _loadFromPrefs(SharedPreferences prefs) {
    final themeStr = prefs.getString(_keyThemeMode);
    final themeMode = switch (themeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final localeStr = prefs.getString(_keyLocale);
    final locale = localeStr != null && localeStr.isNotEmpty
        ? Locale(localeStr)
        : null;

    final reduceTransparency = prefs.getBool(_keyReduceTransparency) ?? false;
    final autoplay = prefs.getBool(_keyAutoplay) ?? true;

    return AppSettings(
      themeMode: themeMode,
      locale: locale,
      reduceTransparency: reduceTransparency,
      autoplay: autoplay,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs =
        ref.read(sharedPreferencesProvider) ??
        await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode.name);
  }

  Future<void> setLocale(Locale? locale) async {
    state = state.copyWith(locale: () => locale);
    final prefs =
        ref.read(sharedPreferencesProvider) ??
        await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_keyLocale);
    } else {
      await prefs.setString(_keyLocale, locale.languageCode);
    }
  }

  Future<void> setReduceTransparency({required bool reduce}) async {
    state = state.copyWith(reduceTransparency: reduce);
    final prefs =
        ref.read(sharedPreferencesProvider) ??
        await SharedPreferences.getInstance();
    await prefs.setBool(_keyReduceTransparency, reduce);
  }

  Future<void> setAutoplay({required bool autoplay}) async {
    state = state.copyWith(autoplay: autoplay);
    final prefs =
        ref.read(sharedPreferencesProvider) ??
        await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoplay, autoplay);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
