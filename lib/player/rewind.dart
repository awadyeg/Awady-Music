import 'dart:async';

import 'package:awady_music/core/settings/settings_provider.dart';
import 'package:awady_music/data/models/stats_models.dart';
import 'package:awady_music/data/repositories/stats_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimum milliseconds required for a completed month Rewind (10 minutes).
const int minRewindMs = 10 * 60 * 1000;

/// Minimum play count required for a completed month Rewind.
const int minRewindPlays = 5;

/// Minimum play count required for an in-progress ("so far") partial month.
const int minRewindPlaysPartial = 3;

const String rewindSeenKey = 'awady_rewind_seen';
const String legacyRewindSeenKey = 'freebify-rewind-seen';

String formatMonthLabel(DateTime date, [String? locale]) {
  try {
    return DateFormat('MMMM', locale).format(date);
  } on Object catch (_) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[date.month - 1];
  }
}

String formatMonthFull(DateTime date, [String? locale]) {
  try {
    return DateFormat('MMMM yyyy', locale).format(date);
  } on Object catch (_) {
    return '${formatMonthLabel(date, locale)} ${date.year}';
  }
}

/// Builds a [RewindData] object from [stats] for the given [key] (format
/// `YYYY-MM`). Returns null if the month data does not meet the qualification
/// threshold.
RewindData? buildRewind(
  String key, {
  required StatsState stats,
  bool partial = false,
  String? locale,
}) {
  final m = stats.months[key];
  if (m == null) return null;

  final qualifies = partial
      ? m.plays >= minRewindPlaysPartial
      : m.ms >= minRewindMs && m.plays >= minRewindPlays;
  if (!qualifies) return null;

  final tracks = m.tracks.values.toList()..sort((a, b) => b.ms.compareTo(a.ms));
  final artists = m.artists.values.toList()
    ..sort((a, b) => b.ms.compareTo(a.ms));
  if (tracks.isEmpty) return null;

  final parts = key.split('-').map(int.parse).toList();
  if (parts.length < 2) return null;
  final year = parts[0];
  final month = parts[1];
  final d = DateTime(year, month);

  final label = formatMonthLabel(d, locale);
  final full = formatMonthFull(d, locale);

  return RewindData(
    key: key,
    label: label,
    full: full,
    partial: partial,
    ms: m.ms,
    plays: m.plays,
    tracks: tracks.take(5).toList(),
    artists: artists.take(5).toList(),
    trackCount: m.tracks.length,
    artistCount: m.artists.length,
  );
}

/// Returns the newest closed month's rewind that qualifies, or null.
RewindData? latestRewind({
  required StatsState stats,
  String? locale,
  DateTime? now,
}) {
  final cur = monthKey(now);
  final closedKeys =
      stats.months.keys.where((k) => k.compareTo(cur) < 0).toList()..sort();
  if (closedKeys.isEmpty) return null;
  final newestKey = closedKeys.last;
  return buildRewind(newestKey, stats: stats, locale: locale);
}

/// Returns the current in-progress month's partial rewind, or null if below
/// threshold.
RewindData? currentRewind({
  required StatsState stats,
  String? locale,
  DateTime? now,
}) {
  return buildRewind(
    monthKey(now),
    stats: stats,
    partial: true,
    locale: locale,
  );
}

/// Returns the freshest available rewind, preferring latest closed month over
/// current partial.
RewindData? availableRewind({
  required StatsState stats,
  String? locale,
  DateTime? now,
}) {
  return latestRewind(stats: stats, locale: locale, now: now) ??
      currentRewind(stats: stats, locale: locale, now: now);
}

/// Checks if the rewind for [key] has been marked as seen by the user.
bool isRewindSeen(String key, SharedPreferences? prefs) {
  if (prefs == null) return false;
  final seen =
      prefs.getString(rewindSeenKey) ?? prefs.getString(legacyRewindSeenKey);
  return seen == key;
}

/// Marks the rewind for [key] as seen in preferences.
Future<void> markRewindSeen(String key, SharedPreferences? prefs) async {
  if (prefs == null) return;
  await prefs.setString(rewindSeenKey, key);
}

/// Manages the currently active (opened) Rewind story.
class RewindController extends Notifier<RewindData?> {
  @override
  RewindData? build() => null;

  void open(RewindData data, [SharedPreferences? prefs]) {
    state = data;
    final p = prefs ?? ref.read(sharedPreferencesProvider);
    unawaited(markRewindSeen(data.key, p));
  }

  void close() {
    state = null;
  }
}

/// Provider for the active [RewindData] story state.
final rewindControllerProvider =
    NotifierProvider<RewindController, RewindData?>(RewindController.new);
