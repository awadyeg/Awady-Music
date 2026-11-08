import 'package:awady_music/core/l10n/l10n.dart';

/// Maps a player notice key to a localized message.
///
/// Unknown keys are returned unchanged so already-localized text still shows.
String? playerNoticeMessage(L10n l10n, String? key) {
  return switch (key) {
    null || '' => null,
    'core.nothingPlayable' => l10n.coreNothingPlayable,
    'core.unavailable' => l10n.coreUnavailable,
    'core.queueFull' => l10n.coreQueueFull,
    'core.addedQueue' => l10n.coreAddedQueue,
    'core.playNext' => l10n.corePlayNext,
    'core.noConnection' => l10n.coreNoConnection,
    'core.radioStarted' => l10n.coreRadioStarted,
    'table.radioFail' => l10n.tableRadioFail,
    _ => key,
  };
}
