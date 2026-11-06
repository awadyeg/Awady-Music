import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicCountry {
  const MusicCountry({
    required this.code,
    required this.flag,
    required this.nameEn,
    required this.nameAr,
    required this.nameEs,
  });

  final String code;
  final String flag;
  final String nameEn;
  final String nameAr;
  final String nameEs;

  String localizedName(String languageCode) {
    return switch (languageCode) {
      'ar' => nameAr,
      'es' => nameEs,
      _ => nameEn,
    };
  }
}

const List<MusicCountry> supportedCountries = [
  MusicCountry(
    code: 'EG',
    flag: '🇪🇬',
    nameEn: 'Egypt',
    nameAr: 'مصر',
    nameEs: 'Egipto',
  ),
  MusicCountry(
    code: 'SA',
    flag: '🇸🇦',
    nameEn: 'Saudi Arabia',
    nameAr: 'السعودية',
    nameEs: 'Arabia Saudita',
  ),
  MusicCountry(
    code: 'AE',
    flag: '🇦🇪',
    nameEn: 'United Arab Emirates',
    nameAr: 'الإمارات',
    nameEs: 'Emiratos Árabes Unidos',
  ),
  MusicCountry(
    code: 'KW',
    flag: '🇰🇼',
    nameEn: 'Kuwait',
    nameAr: 'الكويت',
    nameEs: 'Kuwait',
  ),
  MusicCountry(
    code: 'QA',
    flag: '🇶🇦',
    nameEn: 'Qatar',
    nameAr: 'قطر',
    nameEs: 'Catar',
  ),
  MusicCountry(
    code: 'BH',
    flag: '🇧🇭',
    nameEn: 'Bahrain',
    nameAr: 'البحرين',
    nameEs: 'Baréin',
  ),
  MusicCountry(
    code: 'OM',
    flag: '🇴🇲',
    nameEn: 'Oman',
    nameAr: 'عُمان',
    nameEs: 'Omán',
  ),
  MusicCountry(
    code: 'JO',
    flag: '🇯🇴',
    nameEn: 'Jordan',
    nameAr: 'الأردن',
    nameEs: 'Jordania',
  ),
  MusicCountry(
    code: 'LB',
    flag: '🇱🇧',
    nameEn: 'Lebanon',
    nameAr: 'لبنان',
    nameEs: 'Líbano',
  ),
  MusicCountry(
    code: 'IQ',
    flag: '🇮🇶',
    nameEn: 'Iraq',
    nameAr: 'العراق',
    nameEs: 'Irak',
  ),
  MusicCountry(
    code: 'PS',
    flag: '🇵🇸',
    nameEn: 'Palestine',
    nameAr: 'فلسطين',
    nameEs: 'Palestina',
  ),
  MusicCountry(
    code: 'SY',
    flag: '🇸🇾',
    nameEn: 'Syria',
    nameAr: 'سوريا',
    nameEs: 'Siria',
  ),
  MusicCountry(
    code: 'YE',
    flag: '🇾🇪',
    nameEn: 'Yemen',
    nameAr: 'اليمن',
    nameEs: 'Yemen',
  ),
  MusicCountry(
    code: 'SD',
    flag: '🇸🇩',
    nameEn: 'Sudan',
    nameAr: 'السودان',
    nameEs: 'Sudán',
  ),
  MusicCountry(
    code: 'LY',
    flag: '🇱🇾',
    nameEn: 'Libya',
    nameAr: 'ليبيا',
    nameEs: 'Libia',
  ),
  MusicCountry(
    code: 'TN',
    flag: '🇹🇳',
    nameEn: 'Tunisia',
    nameAr: 'تونس',
    nameEs: 'Túnez',
  ),
  MusicCountry(
    code: 'DZ',
    flag: '🇩🇿',
    nameEn: 'Algeria',
    nameAr: 'الجزائر',
    nameEs: 'Argelia',
  ),
  MusicCountry(
    code: 'MA',
    flag: '🇲🇦',
    nameEn: 'Morocco',
    nameAr: 'المغرب',
    nameEs: 'Marruecos',
  ),
  MusicCountry(
    code: 'US',
    flag: '🇺🇸',
    nameEn: 'United States',
    nameAr: 'الولايات المتحدة',
    nameEs: 'Estados Unidos',
  ),
  MusicCountry(
    code: 'GB',
    flag: '🇬🇧',
    nameEn: 'United Kingdom',
    nameAr: 'المملكة المتحدة',
    nameEs: 'Reino Unido',
  ),
  MusicCountry(
    code: 'CA',
    flag: '🇨🇦',
    nameEn: 'Canada',
    nameAr: 'كندا',
    nameEs: 'Canadá',
  ),
  MusicCountry(
    code: 'DE',
    flag: '🇩🇪',
    nameEn: 'Germany',
    nameAr: 'ألمانيا',
    nameEs: 'Alemania',
  ),
  MusicCountry(
    code: 'FR',
    flag: '🇫🇷',
    nameEn: 'France',
    nameAr: 'فرنسا',
    nameEs: 'Francia',
  ),
  MusicCountry(
    code: 'ES',
    flag: '🇪🇸',
    nameEn: 'Spain',
    nameAr: 'إسبانيا',
    nameEs: 'España',
  ),
  MusicCountry(
    code: 'IT',
    flag: '🇮🇹',
    nameEn: 'Italy',
    nameAr: 'إيطاليا',
    nameEs: 'Italia',
  ),
  MusicCountry(
    code: 'TR',
    flag: '🇹🇷',
    nameEn: 'Turkey',
    nameAr: 'تركيا',
    nameEs: 'Turquía',
  ),
  MusicCountry(
    code: 'IN',
    flag: '🇮🇳',
    nameEn: 'India',
    nameAr: 'الهند',
    nameEs: 'India',
  ),
  MusicCountry(
    code: 'BR',
    flag: '🇧🇷',
    nameEn: 'Brazil',
    nameAr: 'البرازيل',
    nameEs: 'Brasil',
  ),
  MusicCountry(
    code: 'MX',
    flag: '🇲🇽',
    nameEn: 'Mexico',
    nameAr: 'المكسيك',
    nameEs: 'México',
  ),
  MusicCountry(
    code: 'JP',
    flag: '🇯🇵',
    nameEn: 'Japan',
    nameAr: 'اليابان',
    nameEs: 'Japón',
  ),
  MusicCountry(
    code: 'KR',
    flag: '🇰🇷',
    nameEn: 'South Korea',
    nameAr: 'كوريا الجنوبية',
    nameEs: 'Corea del Sur',
  ),
  MusicCountry(
    code: 'AU',
    flag: '🇦🇺',
    nameEn: 'Australia',
    nameAr: 'أستراليا',
    nameEs: 'Australia',
  ),
];

MusicCountry findMusicCountry(String code) {
  final upper = code.toUpperCase();
  for (final c in supportedCountries) {
    if (c.code == upper) return c;
  }
  return supportedCountries.first;
}

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.countryCode = 'EG',
    this.reduceTransparency = false,
    this.autoplay = true,
    this.wifiOnlyDownloads = false,
    this.autoDownloadLikes = true,
    this.userName = '',
  });

  final ThemeMode themeMode;
  final Locale? locale;
  final String countryCode;
  final bool reduceTransparency;
  final bool autoplay;
  final bool wifiOnlyDownloads;
  final bool autoDownloadLikes;
  final String userName;

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? Function()? locale,
    String? countryCode,
    bool? reduceTransparency,
    bool? autoplay,
    bool? wifiOnlyDownloads,
    bool? autoDownloadLikes,
    String? userName,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale != null ? locale() : this.locale,
      countryCode: countryCode ?? this.countryCode,
      reduceTransparency: reduceTransparency ?? this.reduceTransparency,
      autoplay: autoplay ?? this.autoplay,
      wifiOnlyDownloads: wifiOnlyDownloads ?? this.wifiOnlyDownloads,
      autoDownloadLikes: autoDownloadLikes ?? this.autoDownloadLikes,
      userName: userName ?? this.userName,
    );
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

class SettingsNotifier extends Notifier<AppSettings> {
  static const _keyThemeMode = 'settings_theme_mode';
  static const _keyLocale = 'settings_locale';
  static const _keyCountryCode = 'settings_country_code';
  static const _keyReduceTransparency = 'settings_reduce_transparency';
  static const _keyAutoplay = 'settings_autoplay';
  static const _keyWifiOnlyDownloads = 'settings_wifi_only_downloads';
  static const _keyAutoDownloadLikes = 'settings_auto_download_likes';
  static const _keyUserName = 'settings_user_name';

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
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!ref.mounted) return;
      state = _loadFromPrefs(prefs);
    } on Object catch (_) {}
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

    final savedCountry = prefs.getString(_keyCountryCode);
    final countryCode = (savedCountry != null && savedCountry.isNotEmpty)
        ? savedCountry.toUpperCase()
        : 'EG';

    final reduceTransparency = prefs.getBool(_keyReduceTransparency) ?? false;
    final autoplay = prefs.getBool(_keyAutoplay) ?? true;
    final wifiOnlyDownloads = prefs.getBool(_keyWifiOnlyDownloads) ?? false;
    final autoDownloadLikes = prefs.getBool(_keyAutoDownloadLikes) ?? true;
    final userName = prefs.getString(_keyUserName) ?? '';

    return AppSettings(
      themeMode: themeMode,
      locale: locale,
      countryCode: countryCode,
      reduceTransparency: reduceTransparency,
      autoplay: autoplay,
      wifiOnlyDownloads: wifiOnlyDownloads,
      autoDownloadLikes: autoDownloadLikes,
      userName: userName,
    );
  }

  Future<void> setCountryCode(String code) async {
    final normalized = code.trim().toUpperCase();
    state = state.copyWith(countryCode: normalized);
    final prefs =
        ref.read(sharedPreferencesProvider) ??
        await SharedPreferences.getInstance();
    await prefs.setString(_keyCountryCode, normalized);
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

  Future<void> setWifiOnlyDownloads({required bool wifiOnly}) async {
    state = state.copyWith(wifiOnlyDownloads: wifiOnly);
    final prefs =
        ref.read(sharedPreferencesProvider) ??
        await SharedPreferences.getInstance();
    await prefs.setBool(_keyWifiOnlyDownloads, wifiOnly);
  }

  Future<void> setAutoDownloadLikes({required bool enabled}) async {
    state = state.copyWith(autoDownloadLikes: enabled);
    final prefs =
        ref.read(sharedPreferencesProvider) ??
        await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoDownloadLikes, enabled);
  }

  Future<void> setUserName(String name) async {
    final trimmed = name.trim();
    state = state.copyWith(userName: trimmed);
    final prefs =
        ref.read(sharedPreferencesProvider) ??
        await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, trimmed);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
