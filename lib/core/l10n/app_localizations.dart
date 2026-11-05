import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n? of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n);
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
  ];

  /// original key: app.dismissUpdate
  ///
  /// In en, this message translates to:
  /// **'Dismiss update'**
  String get appDismissUpdate;

  /// original key: app.download
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get appDownload;

  /// original key: appOffline
  ///
  /// In en, this message translates to:
  /// **'You are offline. Showing downloaded and cached music'**
  String get appOffline;

  /// original key: app.restart
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get appRestart;

  /// original key: appUpdateAvail
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get appUpdateAvail;

  /// original key: app.updateManualHint
  ///
  /// In en, this message translates to:
  /// **'Download the new dmg'**
  String get appUpdateManualHint;

  /// original key: app.updateReady
  ///
  /// In en, this message translates to:
  /// **'v{version} ready'**
  String appUpdateReady(String version);

  /// original key: app.updateRestartHint
  ///
  /// In en, this message translates to:
  /// **'Restart to update'**
  String get appUpdateRestartHint;

  /// original key: card.album
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get cardAlbum;

  /// original key: card.artist
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get cardArtist;

  /// original key: card.followers
  ///
  /// In en, this message translates to:
  /// **'{n} followers'**
  String cardFollowers(String n);

  /// original key: card.open
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get cardOpen;

  /// original key: card.play
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get cardPlay;

  /// original key: card.playlist
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get cardPlaylist;

  /// original key: card.plays
  ///
  /// In en, this message translates to:
  /// **'{n} plays'**
  String cardPlays(String n);

  /// original key: card.scrollLeft
  ///
  /// In en, this message translates to:
  /// **'Scroll left'**
  String get cardScrollLeft;

  /// original key: card.scrollRight
  ///
  /// In en, this message translates to:
  /// **'Scroll right'**
  String get cardScrollRight;

  /// original key: card.tracks
  ///
  /// In en, this message translates to:
  /// **'{n} tracks'**
  String cardTracks(String n);

  /// original key: eqCrossfade
  ///
  /// In en, this message translates to:
  /// **'Crossfade'**
  String get eqCrossfade;

  /// original key: eq.drive
  ///
  /// In en, this message translates to:
  /// **'Drive'**
  String get eqDrive;

  /// original key: eq.echo
  ///
  /// In en, this message translates to:
  /// **'Echo'**
  String get eqEcho;

  /// original key: eq.enhance
  ///
  /// In en, this message translates to:
  /// **'Enhance'**
  String get eqEnhance;

  /// original key: eq.reverb
  ///
  /// In en, this message translates to:
  /// **'Reverb'**
  String get eqReverb;

  /// original key: eq.space
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get eqSpace;

  /// original key: eq.crossfadeSeconds
  ///
  /// In en, this message translates to:
  /// **'Crossfade seconds'**
  String get eqCrossfadeSeconds;

  /// original key: eq.custom
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get eqCustom;

  /// original key: eqNormalize
  ///
  /// In en, this message translates to:
  /// **'Normalize volume'**
  String get eqNormalize;

  /// original key: eq.off
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get eqOff;

  /// original key: eqPresetBass
  ///
  /// In en, this message translates to:
  /// **'Bass boost'**
  String get eqPresetBass;

  /// original key: eqPresetBright
  ///
  /// In en, this message translates to:
  /// **'Bright'**
  String get eqPresetBright;

  /// original key: eqPresetFlat
  ///
  /// In en, this message translates to:
  /// **'Flat'**
  String get eqPresetFlat;

  /// original key: eqPresetVocal
  ///
  /// In en, this message translates to:
  /// **'Vocal boost'**
  String get eqPresetVocal;

  /// original key: eqPresetVshape
  ///
  /// In en, this message translates to:
  /// **'V-Shape'**
  String get eqPresetVshape;

  /// original key: eq.resetAria
  ///
  /// In en, this message translates to:
  /// **'Reset equalizer'**
  String get eqResetAria;

  /// original key: eq.resetTitle
  ///
  /// In en, this message translates to:
  /// **'Reset to flat'**
  String get eqResetTitle;

  /// original key: eq.sleepIn
  ///
  /// In en, this message translates to:
  /// **'in {n} min'**
  String eqSleepIn(String n);

  /// original key: eq.sleepOff
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get eqSleepOff;

  /// original key: eq.sleepTimer
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get eqSleepTimer;

  /// original key: eq.title
  ///
  /// In en, this message translates to:
  /// **'Equalizer'**
  String get eqTitle;

  /// original key: nav.home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// original key: nav.homeAria
  ///
  /// In en, this message translates to:
  /// **'Awady Music home'**
  String get navHomeAria;

  /// original key: nav.library
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// original key: nav.search
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// original key: nav.settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// original key: nav.stats
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// original key: player.cancelLoading
  ///
  /// In en, this message translates to:
  /// **'Cancel loading'**
  String get playerCancelLoading;

  /// original key: player.like
  ///
  /// In en, this message translates to:
  /// **'Save to Liked Songs'**
  String get playerLike;

  /// original key: player.mute
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get playerMute;

  /// original key: player.next
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get playerNext;

  /// original key: player.nowPlaying
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get playerNowPlaying;

  /// original key: player.openNowPlaying
  ///
  /// In en, this message translates to:
  /// **'Open Now Playing'**
  String get playerOpenNowPlaying;

  /// original key: player.pause
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get playerPause;

  /// original key: player.pick
  ///
  /// In en, this message translates to:
  /// **'Pick something to play'**
  String get playerPick;

  /// original key: player.play
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playerPlay;

  /// original key: player.prev
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get playerPrev;

  /// original key: player.queue
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get playerQueue;

  /// original key: player.repeatAll
  ///
  /// In en, this message translates to:
  /// **'Repeat: all'**
  String get playerRepeatAll;

  /// original key: player.repeatOff
  ///
  /// In en, this message translates to:
  /// **'Repeat: off'**
  String get playerRepeatOff;

  /// original key: player.repeatOne
  ///
  /// In en, this message translates to:
  /// **'Repeat: one'**
  String get playerRepeatOne;

  /// original key: player.seek
  ///
  /// In en, this message translates to:
  /// **'Seek'**
  String get playerSeek;

  /// original key: player.shuffle
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get playerShuffle;

  /// original key: player.unlike
  ///
  /// In en, this message translates to:
  /// **'Remove from Liked Songs'**
  String get playerUnlike;

  /// original key: player.unmute
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get playerUnmute;

  /// original key: player.volume
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get playerVolume;

  /// original key: queueAutoplay
  ///
  /// In en, this message translates to:
  /// **'Autoplay similar songs'**
  String get queueAutoplay;

  /// original key: queue.clear
  ///
  /// In en, this message translates to:
  /// **'Clear queue'**
  String get queueClear;

  /// original key: queue.clearConfirmAria
  ///
  /// In en, this message translates to:
  /// **'Confirm: clear queue'**
  String get queueClearConfirmAria;

  /// original key: queue.clearConfirmTitle
  ///
  /// In en, this message translates to:
  /// **'Click again to clear the queue'**
  String get queueClearConfirmTitle;

  /// original key: queueClearQuestion
  ///
  /// In en, this message translates to:
  /// **'Clear the entire playback queue?'**
  String get queueClearQuestion;

  /// original key: queue.close
  ///
  /// In en, this message translates to:
  /// **'Close queue'**
  String get queueClose;

  /// original key: queueEmpty
  ///
  /// In en, this message translates to:
  /// **'Queue is empty'**
  String get queueEmpty;

  /// original key: queueEndHint
  ///
  /// In en, this message translates to:
  /// **'Autoplay will queue similar tracks when the queue runs low'**
  String get queueEndHint;

  /// original key: queue.nextUp
  ///
  /// In en, this message translates to:
  /// **'Next up'**
  String get queueNextUp;

  /// original key: queue.nowPlaying
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get queueNowPlaying;

  /// original key: queue.radio
  ///
  /// In en, this message translates to:
  /// **'Start radio from this song'**
  String get queueRadio;

  /// original key: queue.removeTrack
  ///
  /// In en, this message translates to:
  /// **'Remove {title} from queue'**
  String queueRemoveTrack(String title);

  /// original key: queue.saveAs
  ///
  /// In en, this message translates to:
  /// **'Save queue as playlist'**
  String get queueSaveAs;

  /// original key: queue.savedAsPlaylist
  ///
  /// In en, this message translates to:
  /// **'Saved queue as playlist'**
  String get queueSavedAsPlaylist;

  /// original key: queue.title
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queueTitle;

  /// original key: side.downloads
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get sideDownloads;

  /// original key: side.liked
  ///
  /// In en, this message translates to:
  /// **'Liked Songs'**
  String get sideLiked;

  /// original key: side.morePlaylists
  ///
  /// In en, this message translates to:
  /// **'+{n} more, see all'**
  String sideMorePlaylists(String n);

  /// original key: side.recentlyPlayed
  ///
  /// In en, this message translates to:
  /// **'Recently played'**
  String get sideRecentlyPlayed;

  /// original key: side.tracks
  ///
  /// In en, this message translates to:
  /// **'{n} tracks'**
  String sideTracks(String n);

  /// original key: side.yourLibrary
  ///
  /// In en, this message translates to:
  /// **'Your library'**
  String get sideYourLibrary;

  /// original key: table.addPlaylist
  ///
  /// In en, this message translates to:
  /// **'Add to playlist'**
  String get tableAddPlaylist;

  /// original key: table.addQueue
  ///
  /// In en, this message translates to:
  /// **'Add to queue'**
  String get tableAddQueue;

  /// original key: table.addedNewPlaylist
  ///
  /// In en, this message translates to:
  /// **'Added to new playlist'**
  String get tableAddedNewPlaylist;

  /// original key: table.addedToPlaylist
  ///
  /// In en, this message translates to:
  /// **'Added to \\\"{name}\\\"'**
  String tableAddedToPlaylist(String name);

  /// original key: table.badgeEdit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get tableBadgeEdit;

  /// original key: table.badgeSet
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get tableBadgeSet;

  /// original key: table.colArtist
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get tableColArtist;

  /// original key: table.colPlays
  ///
  /// In en, this message translates to:
  /// **'Plays'**
  String get tableColPlays;

  /// original key: table.colTime
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get tableColTime;

  /// original key: table.colTitle
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get tableColTitle;

  /// original key: table.copied
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get tableCopied;

  /// original key: table.copyLink
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get tableCopyLink;

  /// original key: table.download
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get tableDownload;

  /// original key: table.downloading
  ///
  /// In en, this message translates to:
  /// **'Downloading… {pct}%'**
  String tableDownloading(String pct);

  /// original key: table.empty
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get tableEmpty;

  /// original key: table.goAlbum
  ///
  /// In en, this message translates to:
  /// **'Go to album'**
  String get tableGoAlbum;

  /// original key: table.goArtist
  ///
  /// In en, this message translates to:
  /// **'Go to artist'**
  String get tableGoArtist;

  /// original key: table.like
  ///
  /// In en, this message translates to:
  /// **'Save to Liked Songs'**
  String get tableLike;

  /// original key: table.linkCopied
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get tableLinkCopied;

  /// original key: table.more
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get tableMore;

  /// original key: table.newPlaylist
  ///
  /// In en, this message translates to:
  /// **'New playlist'**
  String get tableNewPlaylist;

  /// original key: table.playNext
  ///
  /// In en, this message translates to:
  /// **'Play next'**
  String get tablePlayNext;

  /// original key: table.playTrack
  ///
  /// In en, this message translates to:
  /// **'Play {title}'**
  String tablePlayTrack(String title);

  /// original key: table.radioFail
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start a radio for this track'**
  String get tableRadioFail;

  /// original key: table.removeDownload
  ///
  /// In en, this message translates to:
  /// **'Remove download'**
  String get tableRemoveDownload;

  /// original key: table.removeFrom
  ///
  /// In en, this message translates to:
  /// **'Remove from playlist'**
  String get tableRemoveFrom;

  /// original key: table.removedFromPlaylist
  ///
  /// In en, this message translates to:
  /// **'Removed from \\\"{name}\\\"'**
  String tableRemovedFromPlaylist(String name);

  /// original key: table.startRadio
  ///
  /// In en, this message translates to:
  /// **'Start radio'**
  String get tableStartRadio;

  /// original key: table.unlike
  ///
  /// In en, this message translates to:
  /// **'Remove from Liked Songs'**
  String get tableUnlike;

  /// original key: top.back
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get topBack;

  /// original key: top.forward
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get topForward;

  /// original key: win.close
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get winClose;

  /// original key: win.closeToTray
  ///
  /// In en, this message translates to:
  /// **'Close to tray'**
  String get winCloseToTray;

  /// original key: win.maximize
  ///
  /// In en, this message translates to:
  /// **'Maximize'**
  String get winMaximize;

  /// original key: win.minimize
  ///
  /// In en, this message translates to:
  /// **'Minimize'**
  String get winMinimize;

  /// original key: win.restore
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get winRestore;

  /// original key: core.noConnection
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t play. Check your connection and try again'**
  String get coreNoConnection;

  /// original key: core.nothingPlayable
  ///
  /// In en, this message translates to:
  /// **'Nothing playable in this list'**
  String get coreNothingPlayable;

  /// original key: core.unavailable
  ///
  /// In en, this message translates to:
  /// **'That track isn\'t available for streaming'**
  String get coreUnavailable;

  /// original key: core.queueFull
  ///
  /// In en, this message translates to:
  /// **'Queue is full'**
  String get coreQueueFull;

  /// original key: core.addedQueue
  ///
  /// In en, this message translates to:
  /// **'Added to queue'**
  String get coreAddedQueue;

  /// original key: core.playNext
  ///
  /// In en, this message translates to:
  /// **'Will play next'**
  String get corePlayNext;

  /// original key: core.radioStarted
  ///
  /// In en, this message translates to:
  /// **'Radio started. Similar songs queued'**
  String get coreRadioStarted;

  /// original key: core.sleepPaused
  ///
  /// In en, this message translates to:
  /// **'Sleep timer: playback paused'**
  String get coreSleepPaused;

  /// original key: errorBody
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred while loading this view.'**
  String get errorBody;

  /// original key: errorReload
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get errorReload;

  /// original key: errorTitle
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// original key: np.accuracyNote
  ///
  /// In en, this message translates to:
  /// **'Lyrics may not be accurate for some songs'**
  String get npAccuracyNote;

  /// original key: np.close
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get npClose;

  /// original key: np.like
  ///
  /// In en, this message translates to:
  /// **'Save to Liked Songs'**
  String get npLike;

  /// original key: np.lineHint
  ///
  /// In en, this message translates to:
  /// **'Click to jump · Shift+click to sync this line to now'**
  String get npLineHint;

  /// original key: np.lyrics
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get npLyrics;

  /// original key: np.mute
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get npMute;

  /// original key: np.next
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get npNext;

  /// original key: np.noLyrics
  ///
  /// In en, this message translates to:
  /// **'No lyrics found for this track.'**
  String get npNoLyrics;

  /// original key: np.pause
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get npPause;

  /// original key: np.play
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get npPlay;

  /// original key: np.prev
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get npPrev;

  /// original key: np.queue
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get npQueue;

  /// original key: np.repeatAll
  ///
  /// In en, this message translates to:
  /// **'Repeat: all'**
  String get npRepeatAll;

  /// original key: np.repeatOff
  ///
  /// In en, this message translates to:
  /// **'Repeat: off'**
  String get npRepeatOff;

  /// original key: np.repeatOne
  ///
  /// In en, this message translates to:
  /// **'Repeat: one'**
  String get npRepeatOne;

  /// original key: np.seek
  ///
  /// In en, this message translates to:
  /// **'Seek'**
  String get npSeek;

  /// original key: np.shuffle
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get npShuffle;

  /// original key: np.title
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get npTitle;

  /// original key: np.unlike
  ///
  /// In en, this message translates to:
  /// **'Remove from Liked Songs'**
  String get npUnlike;

  /// original key: np.unmute
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get npUnmute;

  /// original key: np.volume
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get npVolume;

  /// original key: rewind.artistStats
  ///
  /// In en, this message translates to:
  /// **'{plays} plays · {time} this month'**
  String rewindArtistStats(String plays, String time);

  /// original key: rewind.chipArtists
  ///
  /// In en, this message translates to:
  /// **'{n} artists'**
  String rewindChipArtists(String n);

  /// original key: rewind.chipPlays
  ///
  /// In en, this message translates to:
  /// **'{n} plays'**
  String rewindChipPlays(String n);

  /// original key: rewind.chipTotal
  ///
  /// In en, this message translates to:
  /// **'{time} total'**
  String rewindChipTotal(String time);

  /// original key: rewind.chipTracks
  ///
  /// In en, this message translates to:
  /// **'{n} tracks'**
  String rewindChipTracks(String n);

  /// original key: rewind.close
  ///
  /// In en, this message translates to:
  /// **'Close rewind'**
  String get rewindClose;

  /// original key: rewind.durHm
  ///
  /// In en, this message translates to:
  /// **'{h}h {m}m'**
  String rewindDurHm(String h, String m);

  /// original key: rewind.durM
  ///
  /// In en, this message translates to:
  /// **'{m}m'**
  String rewindDurM(String m);

  /// original key: rewind.introLine
  ///
  /// In en, this message translates to:
  /// **'A month of yours: every play, counted on this device.'**
  String get rewindIntroLine;

  /// original key: rewind.introLinePartial
  ///
  /// In en, this message translates to:
  /// **'Your month so far: every play, counted on this device.'**
  String get rewindIntroLinePartial;

  /// original key: rewind.introTag
  ///
  /// In en, this message translates to:
  /// **'Awady Music · monthly'**
  String get rewindIntroTag;

  /// original key: rewind.introTagPartial
  ///
  /// In en, this message translates to:
  /// **'Awady Music · still counting'**
  String get rewindIntroTagPartial;

  /// original key: rewind.keepListening
  ///
  /// In en, this message translates to:
  /// **'Keep listening'**
  String get rewindKeepListening;

  /// original key: rewind.listenedFor
  ///
  /// In en, this message translates to:
  /// **'you listened for'**
  String get rewindListenedFor;

  /// original key: rewind.min
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get rewindMin;

  /// original key: rewind.next
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get rewindNext;

  /// original key: rewind.nextSlide
  ///
  /// In en, this message translates to:
  /// **'Next slide'**
  String get rewindNextSlide;

  /// original key: rewind.onRepeat
  ///
  /// In en, this message translates to:
  /// **'on repeat'**
  String get rewindOnRepeat;

  /// original key: rewind.playAgain
  ///
  /// In en, this message translates to:
  /// **'Play it again'**
  String get rewindPlayAgain;

  /// original key: rewind.playTop
  ///
  /// In en, this message translates to:
  /// **'Play your top tracks'**
  String get rewindPlayTop;

  /// original key: rewind.playsAcross
  ///
  /// In en, this message translates to:
  /// **'{time} · {plays} plays across {tracks} tracks'**
  String rewindPlaysAcross(String time, String plays, String tracks);

  /// original key: rewind.prev
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get rewindPrev;

  /// original key: rewind.prevSlide
  ///
  /// In en, this message translates to:
  /// **'Previous slide'**
  String get rewindPrevSlide;

  /// original key: rewind.thatWas
  ///
  /// In en, this message translates to:
  /// **'that was'**
  String get rewindThatWas;

  /// original key: rewind.title
  ///
  /// In en, this message translates to:
  /// **'{month} Rewind'**
  String rewindTitle(String month);

  /// original key: rewind.topArtist
  ///
  /// In en, this message translates to:
  /// **'your #1 artist'**
  String get rewindTopArtist;

  /// original key: rewind.tracksTitle
  ///
  /// In en, this message translates to:
  /// **'The songs you couldn\'t stop'**
  String get rewindTracksTitle;

  /// original key: downloads.cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel download'**
  String get downloadsCancel;

  /// original key: downloadsEmptyCta
  ///
  /// In en, this message translates to:
  /// **'Find music to download'**
  String get downloadsEmptyCta;

  /// original key: downloadsEmptyHint
  ///
  /// In en, this message translates to:
  /// **'Download tracks to listen offline anytime without an internet connection'**
  String get downloadsEmptyHint;

  /// original key: downloads.emptyNeedDesktop
  ///
  /// In en, this message translates to:
  /// **'Downloads need the desktop app.'**
  String get downloadsEmptyNeedDesktop;

  /// original key: downloadsEmptyTitle
  ///
  /// In en, this message translates to:
  /// **'No downloaded songs'**
  String get downloadsEmptyTitle;

  /// original key: downloads.kicker
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get downloadsKicker;

  /// original key: downloads.openFolder
  ///
  /// In en, this message translates to:
  /// **'Open folder'**
  String get downloadsOpenFolder;

  /// original key: downloads.playAll
  ///
  /// In en, this message translates to:
  /// **'Play all'**
  String get downloadsPlayAll;

  /// original key: downloads.queued
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get downloadsQueued;

  /// original key: downloads.removeLabel
  ///
  /// In en, this message translates to:
  /// **'Delete download'**
  String get downloadsRemoveLabel;

  /// original key: downloads.subtitle
  ///
  /// In en, this message translates to:
  /// **'{n} tracks, stored on this device, playable offline'**
  String downloadsSubtitle(String n);

  /// original key: downloads.title
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloadsTitle;

  /// original key: genre.kicker
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get genreKicker;

  /// original key: genre.loadError
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this genre right now.'**
  String get genreLoadError;

  /// original key: genre.play
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get genrePlay;

  /// original key: genre.retry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get genreRetry;

  /// original key: genre.time.allTime
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get genreTimeAllTime;

  /// original key: genre.time.month
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get genreTimeMonth;

  /// original key: genre.time.week
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get genreTimeWeek;

  /// original key: genre.topHits
  ///
  /// In en, this message translates to:
  /// **'Top hits'**
  String get genreTopHits;

  /// original key: genre.trending
  ///
  /// In en, this message translates to:
  /// **'· trending'**
  String get genreTrending;

  /// original key: home.becauseListened
  ///
  /// In en, this message translates to:
  /// **'Because you listened to {name}'**
  String homeBecauseListened(String name);

  /// original key: home.chart
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get homeChart;

  /// original key: home.greeting.afternoon
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGreetingAfternoon;

  /// original key: home.greeting.evening
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGreetingEvening;

  /// original key: home.greeting.late
  ///
  /// In en, this message translates to:
  /// **'Up late?'**
  String get homeGreetingLate;

  /// original key: home.greeting.morning
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreetingMorning;

  /// original key: home.hotPlaylists
  ///
  /// In en, this message translates to:
  /// **'Hot playlists'**
  String get homeHotPlaylists;

  /// original key: home.loadError
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your music'**
  String get homeLoadError;

  /// original key: home.loadErrorHint
  ///
  /// In en, this message translates to:
  /// **'Check your connection. Both catalogs are unreachable.'**
  String get homeLoadErrorHint;

  /// original key: home.moodMixes
  ///
  /// In en, this message translates to:
  /// **'{name} mixes'**
  String homeMoodMixes(String name);

  /// original key: home.newForYou
  ///
  /// In en, this message translates to:
  /// **'New for you'**
  String get homeNewForYou;

  /// original key: home.newReleases
  ///
  /// In en, this message translates to:
  /// **'New releases'**
  String get homeNewReleases;

  /// original key: home.retry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get homeRetry;

  /// original key: home.rewind.partialReady
  ///
  /// In en, this message translates to:
  /// **'Your {label} so far is ready'**
  String homeRewindPartialReady(String label);

  /// original key: home.rewind.ready
  ///
  /// In en, this message translates to:
  /// **'Your {label} Rewind is ready'**
  String homeRewindReady(String label);

  /// original key: home.rewind.sub
  ///
  /// In en, this message translates to:
  /// **'Every play, counted on this device.'**
  String get homeRewindSub;

  /// original key: home.rewind.watch
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get homeRewindWatch;

  /// original key: home.topArtists
  ///
  /// In en, this message translates to:
  /// **'Top artists'**
  String get homeTopArtists;

  /// original key: home.topSongs
  ///
  /// In en, this message translates to:
  /// **'Top songs this week'**
  String get homeTopSongs;

  /// original key: home.trending
  ///
  /// In en, this message translates to:
  /// **'Trending this week'**
  String get homeTrending;

  /// original key: mood.loadError
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this mood'**
  String get moodLoadError;

  /// original key: mood.mixes
  ///
  /// In en, this message translates to:
  /// **'Mixes'**
  String get moodMixes;

  /// original key: mood.playlists
  ///
  /// In en, this message translates to:
  /// **'{name} playlists'**
  String moodPlaylists(String name);

  /// original key: mood.retry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get moodRetry;

  /// original key: mood.topTracks
  ///
  /// In en, this message translates to:
  /// **'Top tracks'**
  String get moodTopTracks;

  /// original key: search.aria
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchAria;

  /// original key: search.artists
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get searchArtists;

  /// original key: search.browseGenres
  ///
  /// In en, this message translates to:
  /// **'Browse genres'**
  String get searchBrowseGenres;

  /// original key: search.clear
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchClear;

  /// original key: searchFailed
  ///
  /// In en, this message translates to:
  /// **'Search failed'**
  String get searchFailed;

  /// original key: searchFailedHint
  ///
  /// In en, this message translates to:
  /// **'Could not reach the music catalog. Please check your connection and retry'**
  String get searchFailedHint;

  /// original key: search.moods
  ///
  /// In en, this message translates to:
  /// **'Moods & moments'**
  String get searchMoods;

  /// original key: search.moreTracks
  ///
  /// In en, this message translates to:
  /// **'More tracks'**
  String get searchMoreTracks;

  /// original key: search.noResults
  ///
  /// In en, this message translates to:
  /// **'No results for “{q}”'**
  String searchNoResults(String q);

  /// original key: searchNoResultsHint
  ///
  /// In en, this message translates to:
  /// **'Check your spelling or try searching for another song, artist, or album'**
  String get searchNoResultsHint;

  /// original key: search.placeholder
  ///
  /// In en, this message translates to:
  /// **'Songs, artists, playlists…'**
  String get searchPlaceholder;

  /// original key: search.playlistsAlbums
  ///
  /// In en, this message translates to:
  /// **'Playlists & albums'**
  String get searchPlaylistsAlbums;

  /// original key: search.retry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get searchRetry;

  /// original key: search.song
  ///
  /// In en, this message translates to:
  /// **'Song'**
  String get searchSong;

  /// original key: search.songs
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get searchSongs;

  /// original key: search.topResult
  ///
  /// In en, this message translates to:
  /// **'Top result'**
  String get searchTopResult;

  /// original key: stats.artistsHeard
  ///
  /// In en, this message translates to:
  /// **'Artists heard'**
  String get statsArtistsHeard;

  /// original key: statsEmptyHint
  ///
  /// In en, this message translates to:
  /// **'Start playing songs to track your favorite artists, tracks, and listening habits'**
  String get statsEmptyHint;

  /// original key: statsEmptyTitle
  ///
  /// In en, this message translates to:
  /// **'No listening stats yet'**
  String get statsEmptyTitle;

  /// original key: stats.listeningTime
  ///
  /// In en, this message translates to:
  /// **'Listening time'**
  String get statsListeningTime;

  /// original key: stats.noListening
  ///
  /// In en, this message translates to:
  /// **'no listening'**
  String get statsNoListening;

  /// original key: stats.rewind.full
  ///
  /// In en, this message translates to:
  /// **'Watch your {label} Rewind'**
  String statsRewindFull(String label);

  /// original key: stats.rewind.partial
  ///
  /// In en, this message translates to:
  /// **'Watch your {label} so far'**
  String statsRewindPartial(String label);

  /// original key: stats.subtitle
  ///
  /// In en, this message translates to:
  /// **'Counted on this device. Never uploaded.'**
  String get statsSubtitle;

  /// original key: stats.thisWeek
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get statsThisWeek;

  /// original key: stats.title
  ///
  /// In en, this message translates to:
  /// **'Your stats'**
  String get statsTitle;

  /// original key: stats.topArtists
  ///
  /// In en, this message translates to:
  /// **'Top artists'**
  String get statsTopArtists;

  /// original key: stats.topTracks
  ///
  /// In en, this message translates to:
  /// **'Top tracks'**
  String get statsTopTracks;

  /// original key: stats.totalPlays
  ///
  /// In en, this message translates to:
  /// **'Total plays'**
  String get statsTotalPlays;

  /// original key: stats.tracksPlayed
  ///
  /// In en, this message translates to:
  /// **'Tracks played'**
  String get statsTracksPlayed;

  /// original key: stats.weekTotal
  ///
  /// In en, this message translates to:
  /// **'{t} this week'**
  String statsWeekTotal(String t);

  /// original key: artist.about
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get artistAbout;

  /// original key: artist.albums
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get artistAlbums;

  /// original key: artist.follow
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get artistFollow;

  /// original key: artist.following
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get artistFollowing;

  /// original key: artist.monthlyListeners
  ///
  /// In en, this message translates to:
  /// **'{n} monthly listeners'**
  String artistMonthlyListeners(String n);

  /// original key: artist.noTracks
  ///
  /// In en, this message translates to:
  /// **'This artist hasn\'t uploaded tracks yet.'**
  String get artistNoTracks;

  /// original key: artist.notFound
  ///
  /// In en, this message translates to:
  /// **'Artist not found'**
  String get artistNotFound;

  /// original key: artist.notFound.named
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load {name}\'s page. It may have moved or the network hiccuped.'**
  String artistNotFoundNamed(String name);

  /// original key: artist.notFound.sub
  ///
  /// In en, this message translates to:
  /// **'They may have moved or the network hiccuped.'**
  String get artistNotFoundSub;

  /// original key: artist.play
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get artistPlay;

  /// original key: artist.popular
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get artistPopular;

  /// original key: artist.retry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get artistRetry;

  /// original key: artist.showAll
  ///
  /// In en, this message translates to:
  /// **'Show all {n}'**
  String artistShowAll(String n);

  /// original key: artist.showLess
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get artistShowLess;

  /// original key: artist.singles
  ///
  /// In en, this message translates to:
  /// **'Singles & EPs'**
  String get artistSingles;

  /// original key: artist.stats
  ///
  /// In en, this message translates to:
  /// **'{followers} followers · {tracks} tracks'**
  String artistStats(String followers, String tracks);

  /// original key: artist.tracksError
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the tracks. The artist page itself is fine.'**
  String get artistTracksError;

  /// original key: artist.verified
  ///
  /// In en, this message translates to:
  /// **'Verified artist'**
  String get artistVerified;

  /// original key: import.badCsv
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read that CSV'**
  String get importBadCsv;

  /// original key: import.badJson
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read that file. Expected a .freebify.json playlist'**
  String get importBadJson;

  /// original key: import.button
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importButton;

  /// original key: import.chooseCsv
  ///
  /// In en, this message translates to:
  /// **'Choose .csv file'**
  String get importChooseCsv;

  /// original key: import.close
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get importClose;

  /// original key: import.csvHint
  ///
  /// In en, this message translates to:
  /// **'For longer or private playlists. Title + artist columns are detected automatically. Max 5000.'**
  String get importCsvHint;

  /// original key: import.csvLabel
  ///
  /// In en, this message translates to:
  /// **'CSV export'**
  String get importCsvLabel;

  /// original key: import.failed
  ///
  /// In en, this message translates to:
  /// **'Import failed. Try again'**
  String get importFailed;

  /// original key: import.imported
  ///
  /// In en, this message translates to:
  /// **'Imported {n} tracks'**
  String importImported(String n);

  /// original key: import.limited
  ///
  /// In en, this message translates to:
  /// **'Imported {n} tracks. Spotify only published the first 100, export a CSV to bring the rest.'**
  String importLimited(String n);

  /// original key: import.linkHint
  ///
  /// In en, this message translates to:
  /// **'Spotify: paste any public playlist link, full track list. YouTube Music: full list, no matching needed.'**
  String get importLinkHint;

  /// original key: import.linkLabel
  ///
  /// In en, this message translates to:
  /// **'Spotify or YouTube Music link'**
  String get importLinkLabel;

  /// original key: import.notFound
  ///
  /// In en, this message translates to:
  /// **'Playlist not found. Check it isn\'t private'**
  String get importNotFound;

  /// original key: import.pasteLink
  ///
  /// In en, this message translates to:
  /// **'Paste a Spotify or YouTube Music playlist link'**
  String get importPasteLink;

  /// original key: import.submit
  ///
  /// In en, this message translates to:
  /// **'Import playlist'**
  String get importSubmit;

  /// original key: import.title
  ///
  /// In en, this message translates to:
  /// **'Import a playlist'**
  String get importTitle;

  /// original key: import.unreadable
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read that playlist. Check it\'s public'**
  String get importUnreadable;

  /// original key: library.emptyLiked.cta
  ///
  /// In en, this message translates to:
  /// **'Find something to love'**
  String get libraryEmptyLikedCta;

  /// original key: library.emptyLiked.sub
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any track to save it.'**
  String get libraryEmptyLikedSub;

  /// original key: library.emptyLiked.title
  ///
  /// In en, this message translates to:
  /// **'Songs you like will live here'**
  String get libraryEmptyLikedTitle;

  /// original key: library.emptyPlaylists
  ///
  /// In en, this message translates to:
  /// **'Create a playlist and add songs from the ··· menu on any track.'**
  String get libraryEmptyPlaylists;

  /// original key: library.followed
  ///
  /// In en, this message translates to:
  /// **'Artists you follow'**
  String get libraryFollowed;

  /// original key: library.likedSongs
  ///
  /// In en, this message translates to:
  /// **'Liked Songs'**
  String get libraryLikedSongs;

  /// original key: library.newPlaylist
  ///
  /// In en, this message translates to:
  /// **'New playlist'**
  String get libraryNewPlaylist;

  /// original key: library.playAll
  ///
  /// In en, this message translates to:
  /// **'Play all'**
  String get libraryPlayAll;

  /// original key: library.playlistLabel
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get libraryPlaylistLabel;

  /// original key: library.recents
  ///
  /// In en, this message translates to:
  /// **'Recently played'**
  String get libraryRecents;

  /// original key: library.trackCount
  ///
  /// In en, this message translates to:
  /// **'{n} tracks'**
  String libraryTrackCount(String n);

  /// original key: library.yourPlaylists
  ///
  /// In en, this message translates to:
  /// **'Your playlists'**
  String get libraryYourPlaylists;

  /// original key: playlist.album
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get playlistAlbum;

  /// original key: playlist.alreadyDownloaded
  ///
  /// In en, this message translates to:
  /// **'Already downloaded'**
  String get playlistAlreadyDownloaded;

  /// original key: playlist.copyLink
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get playlistCopyLink;

  /// original key: playlist.copyLinkAria
  ///
  /// In en, this message translates to:
  /// **'Copy playlist link'**
  String get playlistCopyLinkAria;

  /// original key: playlist.delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get playlistDelete;

  /// original key: playlist.deleteConfirm
  ///
  /// In en, this message translates to:
  /// **'Delete?'**
  String get playlistDeleteConfirm;

  /// original key: playlist.downloadAll
  ///
  /// In en, this message translates to:
  /// **'Download all'**
  String get playlistDownloadAll;

  /// original key: playlist.downloadAllTitle
  ///
  /// In en, this message translates to:
  /// **'Download all tracks for offline playback'**
  String get playlistDownloadAllTitle;

  /// original key: playlist.downloading
  ///
  /// In en, this message translates to:
  /// **'Downloading {n} tracks'**
  String playlistDownloading(String n);

  /// original key: playlist.empty
  ///
  /// In en, this message translates to:
  /// **'This playlist is empty.'**
  String get playlistEmpty;

  /// original key: playlist.export
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get playlistExport;

  /// original key: playlist.exportTitle
  ///
  /// In en, this message translates to:
  /// **'Export as a shareable .freebify.json file'**
  String get playlistExportTitle;

  /// original key: playlist.exported
  ///
  /// In en, this message translates to:
  /// **'Playlist exported'**
  String get playlistExported;

  /// original key: playlist.emptyLocal.sub
  ///
  /// In en, this message translates to:
  /// **'Use the ··· menu on any track.'**
  String get playlistEmptyLocalSub;

  /// original key: playlist.emptyLocal.title
  ///
  /// In en, this message translates to:
  /// **'Songs you add will live here'**
  String get playlistEmptyLocalTitle;

  /// original key: playlist.findInPlaylist
  ///
  /// In en, this message translates to:
  /// **'Find in playlist'**
  String get playlistFindInPlaylist;

  /// original key: playlist.findSongs
  ///
  /// In en, this message translates to:
  /// **'Find songs'**
  String get playlistFindSongs;

  /// original key: playlist.noMatch
  ///
  /// In en, this message translates to:
  /// **'No tracks match “{q}”.'**
  String playlistNoMatch(String q);

  /// original key: playlist.notFound
  ///
  /// In en, this message translates to:
  /// **'Playlist not found'**
  String get playlistNotFound;

  /// original key: playlist.notFound.localSub
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted.'**
  String get playlistNotFoundLocalSub;

  /// original key: playlist.notFound.sub
  ///
  /// In en, this message translates to:
  /// **'It may have been removed or the network hiccuped.'**
  String get playlistNotFoundSub;

  /// original key: playlist.play
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playlistPlay;

  /// original key: playlist.playlist
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlistPlaylist;

  /// original key: playlist.plays
  ///
  /// In en, this message translates to:
  /// **'{n} plays'**
  String playlistPlays(String n);

  /// original key: playlist.removeLabel
  ///
  /// In en, this message translates to:
  /// **'Remove from playlist'**
  String get playlistRemoveLabel;

  /// original key: playlist.rename
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get playlistRename;

  /// original key: playlist.renameAria
  ///
  /// In en, this message translates to:
  /// **'Rename playlist'**
  String get playlistRenameAria;

  /// original key: playlist.retry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get playlistRetry;

  /// original key: playlist.saveToLibrary
  ///
  /// In en, this message translates to:
  /// **'Save to Library'**
  String get playlistSaveToLibrary;

  /// original key: playlist.sort
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get playlistSort;

  /// original key: playlist.sort.title
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get playlistSortTitle;

  /// original key: playlist.sort.artist
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get playlistSortArtist;

  /// original key: playlist.sort.duration
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get playlistSortDuration;

  /// original key: playlist.trackCount
  ///
  /// In en, this message translates to:
  /// **'{n} tracks'**
  String playlistTrackCount(String n);

  /// original key: playlist.tracksError
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the tracks. The playlist itself is fine.'**
  String get playlistTracksError;

  /// original key: playlist.unknown
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get playlistUnknown;

  /// original key: settings.about
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// original key: settings.aboutBody
  ///
  /// In en, this message translates to:
  /// **'Free, ad-free music. Awady Music is a player, not a host: all audio & metadata are fetched by your device, directly from YouTube Music & the Audius public API, under their own terms. For personal, non-commercial use. Not affiliated with Spotify, YouTube, Google or Audius.'**
  String get settingsAboutBody;

  /// original key: settings.aboutVersions
  ///
  /// In en, this message translates to:
  /// **'Electron {electron} · Chromium {chromium}'**
  String settingsAboutVersions(String electron, String chromium);

  /// original key: settings.autoplay
  ///
  /// In en, this message translates to:
  /// **'Autoplay similar songs'**
  String get settingsAutoplay;

  /// original key: settings.autoplay.sub
  ///
  /// In en, this message translates to:
  /// **'Keep the queue going when it ends'**
  String get settingsAutoplaySub;

  /// original key: settings.backupExported
  ///
  /// In en, this message translates to:
  /// **'Backup exported'**
  String get settingsBackupExported;

  /// original key: settings.cacheCleared
  ///
  /// In en, this message translates to:
  /// **'Cache cleared. Your library is untouched'**
  String get settingsCacheCleared;

  /// original key: settings.cacheFailed
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t clear the cache'**
  String get settingsCacheFailed;

  /// original key: settings.checkUpdates
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get settingsCheckUpdates;

  /// original key: settings.checking
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get settingsChecking;

  /// original key: settings.clearCache
  ///
  /// In en, this message translates to:
  /// **'Clear artwork & lyrics cache'**
  String get settingsClearCache;

  /// original key: settings.contribute
  ///
  /// In en, this message translates to:
  /// **'Open source. Contribute on GitHub'**
  String get settingsContribute;

  /// original key: settings.discord
  ///
  /// In en, this message translates to:
  /// **'Discord status'**
  String get settingsDiscord;

  /// original key: settings.discord.sub
  ///
  /// In en, this message translates to:
  /// **'Show what you\'re listening to on your profile'**
  String get settingsDiscordSub;

  /// original key: settings.export
  ///
  /// In en, this message translates to:
  /// **'Export library & stats'**
  String get settingsExport;

  /// original key: settings.exportFailed
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get settingsExportFailed;

  /// original key: settings.k.space
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get settingsKSpace;

  /// original key: settings.legal
  ///
  /// In en, this message translates to:
  /// **'Legal: disclaimer & terms'**
  String get settingsLegal;

  /// original key: settings.language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// original key: settings.language.sub
  ///
  /// In en, this message translates to:
  /// **'Applies to the whole app instantly.'**
  String get settingsLanguageSub;

  /// original key: settings.library
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get settingsLibrary;

  /// original key: settings.libraryStats
  ///
  /// In en, this message translates to:
  /// **'{liked} liked songs · {playlists} playlists, stored locally on this device.'**
  String settingsLibraryStats(String liked, String playlists);

  /// original key: settings.login
  ///
  /// In en, this message translates to:
  /// **'Open Awady Music when you sign in'**
  String get settingsLogin;

  /// original key: settings.login.sub
  ///
  /// In en, this message translates to:
  /// **'Start with your desktop, ready in the background'**
  String get settingsLoginSub;

  /// original key: settings.openLogs
  ///
  /// In en, this message translates to:
  /// **'Open logs folder'**
  String get settingsOpenLogs;

  /// original key: settings.playback
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get settingsPlayback;

  /// original key: settings.sc.closePanels
  ///
  /// In en, this message translates to:
  /// **'Close panels'**
  String get settingsScClosePanels;

  /// original key: settings.sc.like
  ///
  /// In en, this message translates to:
  /// **'Like current track'**
  String get settingsScLike;

  /// original key: settings.sc.mute
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get settingsScMute;

  /// original key: settings.sc.nowPlaying
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get settingsScNowPlaying;

  /// original key: settings.sc.playPause
  ///
  /// In en, this message translates to:
  /// **'Play / pause'**
  String get settingsScPlayPause;

  /// original key: settings.sc.queue
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get settingsScQueue;

  /// original key: settings.sc.search
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get settingsScSearch;

  /// original key: settings.sc.seek
  ///
  /// In en, this message translates to:
  /// **'Seek 10 seconds'**
  String get settingsScSeek;

  /// original key: settings.sc.volume
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get settingsScVolume;

  /// original key: settings.shortcuts
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts'**
  String get settingsShortcuts;

  /// original key: settings.title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// original key: settings.update.available
  ///
  /// In en, this message translates to:
  /// **'v{v} available, downloading in the background'**
  String settingsUpdateAvailable(String v);

  /// original key: settings.update.failed
  ///
  /// In en, this message translates to:
  /// **'Update check failed'**
  String get settingsUpdateFailed;

  /// original key: settings.update.failedLater
  ///
  /// In en, this message translates to:
  /// **'Update check failed. Try again later'**
  String get settingsUpdateFailedLater;

  /// original key: settings.update.latest
  ///
  /// In en, this message translates to:
  /// **'You\'re up to date'**
  String get settingsUpdateLatest;

  /// original key: settings.update.pending
  ///
  /// In en, this message translates to:
  /// **'v{v} is ready. Restart from the banner'**
  String settingsUpdatePending(String v);

  /// original key: themeMode
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeMode;

  /// original key: themeSystem
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystem;

  /// original key: themeLight
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// original key: themeDark
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// original key: reduceTransparency
  ///
  /// In en, this message translates to:
  /// **'Reduce transparency'**
  String get reduceTransparency;

  /// original key: reduceTransparencySubtitle
  ///
  /// In en, this message translates to:
  /// **'Use solid surfaces instead of translucent blur effects'**
  String get reduceTransparencySubtitle;

  /// original key: language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// original key: languageSystem
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// original key: streamQuality
  ///
  /// In en, this message translates to:
  /// **'Audio streaming quality'**
  String get streamQuality;

  /// original key: qualityHigh
  ///
  /// In en, this message translates to:
  /// **'High (best audio)'**
  String get qualityHigh;

  /// original key: qualityLow
  ///
  /// In en, this message translates to:
  /// **'Data saver (low)'**
  String get qualityLow;

  /// original key: wifiOnlyDownloads
  ///
  /// In en, this message translates to:
  /// **'Download over Wi-Fi only'**
  String get wifiOnlyDownloads;

  /// original key: clearCache
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// original key: cacheCleared
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheCleared;

  /// original key: exportBackup
  ///
  /// In en, this message translates to:
  /// **'Export library backup'**
  String get exportBackup;

  /// original key: importBackup
  ///
  /// In en, this message translates to:
  /// **'Import library backup'**
  String get importBackup;

  /// original key: importBackupSuccess
  ///
  /// In en, this message translates to:
  /// **'Library backup imported successfully'**
  String get importBackupSuccess;

  /// original key: importBackupConfirm
  ///
  /// In en, this message translates to:
  /// **'Importing this backup will merge playlists, liked songs, and listening history. Continue?'**
  String get importBackupConfirm;

  /// original key: shareLogs
  ///
  /// In en, this message translates to:
  /// **'Share logs'**
  String get shareLogs;

  /// original key: noLogs
  ///
  /// In en, this message translates to:
  /// **'No logs found to share'**
  String get noLogs;

  /// original key: synced
  ///
  /// In en, this message translates to:
  /// **'Synced line to current playback time'**
  String get synced;

  /// original key: syncLineToNow
  ///
  /// In en, this message translates to:
  /// **'Sync this line to now'**
  String get syncLineToNow;

  /// original key: accuracyNote
  ///
  /// In en, this message translates to:
  /// **'Lyrics timing may vary slightly between recordings'**
  String get accuracyNote;

  /// original key: appUpdateDownload
  ///
  /// In en, this message translates to:
  /// **'Download update'**
  String get appUpdateDownload;

  /// original key: nowPlaying
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlaying;

  /// original key: newPlaylist
  ///
  /// In en, this message translates to:
  /// **'New playlist'**
  String get newPlaylist;

  /// original key: createPlaylist
  ///
  /// In en, this message translates to:
  /// **'Create playlist'**
  String get createPlaylist;

  /// original key: playlistNamePlaceholder
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get playlistNamePlaceholder;

  /// original key: disclaimer
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get disclaimer;

  /// original key: terms
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get terms;

  /// original key: privacy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy;

  /// original key: legal
  ///
  /// In en, this message translates to:
  /// **'Legal & Licenses'**
  String get legal;

  /// original key: aboutAttribution
  ///
  /// In en, this message translates to:
  /// **'Based on the open-source Freebify design and concept'**
  String get aboutAttribution;

  /// original key: retry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// original key: cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// original key: confirm
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// original key: save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// original key: deleteAction
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// original key: editAction
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// original key: doneAction
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneAction;

  /// original key: removeAction
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeAction;

  /// original key: playAction
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playAction;

  /// original key: pauseAction
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseAction;

  /// original key: shuffleAction
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffleAction;

  /// original key: addTracks
  ///
  /// In en, this message translates to:
  /// **'Add tracks'**
  String get addTracks;

  /// original key: renamePlaylist
  ///
  /// In en, this message translates to:
  /// **'Rename playlist'**
  String get renamePlaylist;

  /// original key: deletePlaylistConfirm
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this playlist?'**
  String get deletePlaylistConfirm;

  /// original key: startRadio
  ///
  /// In en, this message translates to:
  /// **'Start radio'**
  String get startRadio;

  /// original key: goToArtist
  ///
  /// In en, this message translates to:
  /// **'Go to artist'**
  String get goToArtist;

  /// original key: goToAlbum
  ///
  /// In en, this message translates to:
  /// **'Go to album'**
  String get goToAlbum;

  /// original key: saveToLibrary
  ///
  /// In en, this message translates to:
  /// **'Save to library'**
  String get saveToLibrary;

  /// original key: removeFromLibrary
  ///
  /// In en, this message translates to:
  /// **'Remove from library'**
  String get removeFromLibrary;

  /// original key: downloadTrack
  ///
  /// In en, this message translates to:
  /// **'Download track'**
  String get downloadTrack;

  /// original key: removeDownload
  ///
  /// In en, this message translates to:
  /// **'Remove download'**
  String get removeDownload;

  /// original key: downloaded
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloaded;

  /// original key: downloading
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get downloading;

  /// original key: queued
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get queued;

  /// original key: shareTrack
  ///
  /// In en, this message translates to:
  /// **'Share track'**
  String get shareTrack;

  /// original key: sharePlaylist
  ///
  /// In en, this message translates to:
  /// **'Share playlist'**
  String get sharePlaylist;

  /// original key: copyLink
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// original key: linkCopied
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get linkCopied;

  /// original key: noLyrics
  ///
  /// In en, this message translates to:
  /// **'No lyrics available for this song'**
  String get noLyrics;

  /// original key: matchingProgress
  ///
  /// In en, this message translates to:
  /// **'Matching {matched} of {total} tracks…'**
  String matchingProgress(String matched, String total);

  /// original key: importPlaylistTitle
  ///
  /// In en, this message translates to:
  /// **'Import playlist'**
  String get importPlaylistTitle;

  /// original key: importUrlHint
  ///
  /// In en, this message translates to:
  /// **'Paste Spotify or YouTube Music playlist link'**
  String get importUrlHint;

  /// original key: importFileButton
  ///
  /// In en, this message translates to:
  /// **'Choose CSV or .freebify.json file'**
  String get importFileButton;

  /// original key: allFilter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilter;

  /// original key: songsFilter
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get songsFilter;

  /// original key: artistsFilter
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get artistsFilter;

  /// original key: playlistsFilter
  ///
  /// In en, this message translates to:
  /// **'Playlists & albums'**
  String get playlistsFilter;

  /// original key: topResult
  ///
  /// In en, this message translates to:
  /// **'Top result'**
  String get topResult;

  /// original key: moreTracks
  ///
  /// In en, this message translates to:
  /// **'More songs'**
  String get moreTracks;

  /// original key: popularTracks
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popularTracks;

  /// original key: discography
  ///
  /// In en, this message translates to:
  /// **'Discography'**
  String get discography;

  /// original key: albumsSection
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get albumsSection;

  /// original key: singlesSection
  ///
  /// In en, this message translates to:
  /// **'Singles & EPs'**
  String get singlesSection;

  /// original key: aboutArtist
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutArtist;

  /// original key: monthlyListenersCount
  ///
  /// In en, this message translates to:
  /// **'{n} monthly listeners'**
  String monthlyListenersCount(String n);

  /// original key: followersCount
  ///
  /// In en, this message translates to:
  /// **'{n} followers'**
  String followersCount(String n);

  /// original key: trackCountLabel
  ///
  /// In en, this message translates to:
  /// **'{n} tracks'**
  String trackCountLabel(String n);

  /// original key: listeningTime
  ///
  /// In en, this message translates to:
  /// **'Listening time'**
  String get listeningTime;

  /// original key: totalPlays
  ///
  /// In en, this message translates to:
  /// **'Total plays'**
  String get totalPlays;

  /// original key: tracksPlayed
  ///
  /// In en, this message translates to:
  /// **'Tracks played'**
  String get tracksPlayed;

  /// original key: artistsHeard
  ///
  /// In en, this message translates to:
  /// **'Artists heard'**
  String get artistsHeard;

  /// original key: thisWeek
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// original key: topTracks
  ///
  /// In en, this message translates to:
  /// **'Top tracks'**
  String get topTracks;

  /// original key: topArtists
  ///
  /// In en, this message translates to:
  /// **'Top artists'**
  String get topArtists;

  /// original key: rewindAction
  ///
  /// In en, this message translates to:
  /// **'Watch Rewind'**
  String get rewindAction;

  /// original key: equalizerTitle
  ///
  /// In en, this message translates to:
  /// **'Equalizer'**
  String get equalizerTitle;

  /// original key: eqPresetCustom
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get eqPresetCustom;

  /// original key: sleepTimerTitle
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get sleepTimerTitle;

  /// original key: sleepTimerOff
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get sleepTimerOff;

  /// original key: sleepTimer5
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get sleepTimer5;

  /// original key: sleepTimer15
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get sleepTimer15;

  /// original key: sleepTimer30
  ///
  /// In en, this message translates to:
  /// **'30 minutes'**
  String get sleepTimer30;

  /// original key: sleepTimer45
  ///
  /// In en, this message translates to:
  /// **'45 minutes'**
  String get sleepTimer45;

  /// original key: sleepTimer60
  ///
  /// In en, this message translates to:
  /// **'60 minutes'**
  String get sleepTimer60;

  /// original key: sleepTimerTrackEnd
  ///
  /// In en, this message translates to:
  /// **'End of current track'**
  String get sleepTimerTrackEnd;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return L10nAr();
    case 'en':
      return L10nEn();
    case 'es':
      return L10nEs();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
