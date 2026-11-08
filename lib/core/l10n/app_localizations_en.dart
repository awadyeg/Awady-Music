// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appDismissUpdate => 'Dismiss update';

  @override
  String get appDownload => 'Download';

  @override
  String get appOffline =>
      'You are offline. Showing downloaded and cached music';

  @override
  String get appRestart => 'Restart';

  @override
  String get appUpdateAvail => 'Update available';

  @override
  String get appUpdateManualHint => 'Download the new dmg';

  @override
  String appUpdateReady(String version) {
    return 'v$version ready';
  }

  @override
  String get appUpdateRestartHint => 'Restart to update';

  @override
  String get cardAlbum => 'Album';

  @override
  String get cardArtist => 'Artist';

  @override
  String cardFollowers(String n) {
    return '$n followers';
  }

  @override
  String get cardOpen => 'Open';

  @override
  String get cardPlay => 'Play';

  @override
  String get cardPlaylist => 'Playlist';

  @override
  String cardPlays(String n) {
    return '$n plays';
  }

  @override
  String get cardScrollLeft => 'Scroll left';

  @override
  String get cardScrollRight => 'Scroll right';

  @override
  String cardTracks(String n) {
    return '$n tracks';
  }

  @override
  String get eqCrossfade => 'Crossfade';

  @override
  String get eqDrive => 'Drive';

  @override
  String get eqEcho => 'Echo';

  @override
  String get eqEnhance => 'Enhance';

  @override
  String get eqReverb => 'Reverb';

  @override
  String get eqSpace => 'Space';

  @override
  String get eqCrossfadeSeconds => 'Crossfade seconds';

  @override
  String get eqCustom => 'Custom';

  @override
  String get eqNormalize => 'Normalize volume';

  @override
  String get eqOff => 'off';

  @override
  String get eqPresetBass => 'Bass boost';

  @override
  String get eqPresetBright => 'Bright';

  @override
  String get eqPresetFlat => 'Flat';

  @override
  String get eqPresetVocal => 'Vocal boost';

  @override
  String get eqPresetVshape => 'V-Shape';

  @override
  String get eqResetAria => 'Reset equalizer';

  @override
  String get eqResetTitle => 'Reset to flat';

  @override
  String eqSleepIn(String n) {
    return 'in $n min';
  }

  @override
  String get eqSleepOff => 'Off';

  @override
  String get eqSleepTimer => 'Sleep timer';

  @override
  String get eqTitle => 'Equalizer';

  @override
  String get navHome => 'Home';

  @override
  String get navHomeAria => 'Awady Music home';

  @override
  String get navLibrary => 'Library';

  @override
  String get navSearch => 'Search';

  @override
  String get navSettings => 'Settings';

  @override
  String get navStats => 'Stats';

  @override
  String get playerCancelLoading => 'Cancel loading';

  @override
  String get playerLike => 'Save to Liked Songs';

  @override
  String get playerMute => 'Mute';

  @override
  String get playerNext => 'Next';

  @override
  String get playerNowPlaying => 'Now playing';

  @override
  String get playerOpenNowPlaying => 'Open Now Playing';

  @override
  String get playerPause => 'Pause';

  @override
  String get playerPick => 'Pick something to play';

  @override
  String get playerPlay => 'Play';

  @override
  String get playerPrev => 'Previous';

  @override
  String get playerQueue => 'Queue';

  @override
  String get playerRepeatAll => 'Repeat: all';

  @override
  String get playerRepeatOff => 'Repeat: off';

  @override
  String get playerRepeatOne => 'Repeat: one';

  @override
  String get playerSeek => 'Seek';

  @override
  String get playerShuffle => 'Shuffle';

  @override
  String get playerUnlike => 'Remove from Liked Songs';

  @override
  String get playerUnmute => 'Unmute';

  @override
  String get playerVolume => 'Volume';

  @override
  String get queueAutoplay => 'Autoplay similar songs';

  @override
  String get queueClear => 'Clear queue';

  @override
  String get queueClearConfirmAria => 'Confirm: clear queue';

  @override
  String get queueClearConfirmTitle => 'Click again to clear the queue';

  @override
  String get queueClearQuestion => 'Clear the entire playback queue?';

  @override
  String get queueClose => 'Close queue';

  @override
  String get queueEmpty => 'Queue is empty';

  @override
  String get queueEndHint =>
      'Autoplay will queue similar tracks when the queue runs low';

  @override
  String get queueNextUp => 'Next up';

  @override
  String get queueNowPlaying => 'Now playing';

  @override
  String get queueRadio => 'Start radio from this song';

  @override
  String queueRemoveTrack(String title) {
    return 'Remove $title from queue';
  }

  @override
  String get queueSaveAs => 'Save queue as playlist';

  @override
  String get queueSavedAsPlaylist => 'Saved queue as playlist';

  @override
  String get queueTitle => 'Queue';

  @override
  String get sideDownloads => 'Downloads';

  @override
  String get sideLiked => 'Liked Songs';

  @override
  String sideMorePlaylists(String n) {
    return '+$n more, see all';
  }

  @override
  String get sideRecentlyPlayed => 'Recently played';

  @override
  String sideTracks(String n) {
    return '$n tracks';
  }

  @override
  String get sideYourLibrary => 'Your library';

  @override
  String get tableAddPlaylist => 'Add to playlist';

  @override
  String get tableAddQueue => 'Add to queue';

  @override
  String get tableAddedNewPlaylist => 'Added to new playlist';

  @override
  String tableAddedToPlaylist(String name) {
    return 'Added to \\\"$name\\\"';
  }

  @override
  String get tableBadgeEdit => 'Edit';

  @override
  String get tableBadgeSet => 'Set';

  @override
  String get tableColArtist => 'Artist';

  @override
  String get tableColPlays => 'Plays';

  @override
  String get tableColTime => 'Time';

  @override
  String get tableColTitle => 'Title';

  @override
  String get tableCopied => 'Copied';

  @override
  String get tableCopyLink => 'Copy link';

  @override
  String get tableDownload => 'Download';

  @override
  String tableDownloading(String pct) {
    return 'Downloading… $pct%';
  }

  @override
  String get tableEmpty => 'Nothing here yet.';

  @override
  String get tableGoAlbum => 'Go to album';

  @override
  String get tableGoArtist => 'Go to artist';

  @override
  String get tableLike => 'Save to Liked Songs';

  @override
  String get tableLinkCopied => 'Link copied';

  @override
  String get tableMore => 'More options';

  @override
  String get tableNewPlaylist => 'New playlist';

  @override
  String get tablePlayNext => 'Play next';

  @override
  String tablePlayTrack(String title) {
    return 'Play $title';
  }

  @override
  String get tableRadioFail => 'Couldn\'t start a radio for this track';

  @override
  String get tableRemoveDownload => 'Remove download';

  @override
  String get tableRemoveFrom => 'Remove from playlist';

  @override
  String tableRemovedFromPlaylist(String name) {
    return 'Removed from \\\"$name\\\"';
  }

  @override
  String get tableStartRadio => 'Start radio';

  @override
  String get tableUnlike => 'Remove from Liked Songs';

  @override
  String get topBack => 'Back';

  @override
  String get topForward => 'Forward';

  @override
  String get winClose => 'Close';

  @override
  String get winCloseToTray => 'Close to tray';

  @override
  String get winMaximize => 'Maximize';

  @override
  String get winMinimize => 'Minimize';

  @override
  String get winRestore => 'Restore';

  @override
  String get coreNoConnection =>
      'Couldn\'t play. Check your connection and try again';

  @override
  String get coreNothingPlayable => 'Nothing playable in this list';

  @override
  String get coreUnavailable => 'That track isn\'t available for streaming';

  @override
  String get coreQueueFull => 'Queue is full';

  @override
  String get coreAddedQueue => 'Added to queue';

  @override
  String get corePlayNext => 'Will play next';

  @override
  String get coreRadioStarted => 'Radio started. Similar songs queued';

  @override
  String get coreSleepPaused => 'Sleep timer: playback paused';

  @override
  String get errorBody =>
      'An unexpected error occurred while loading this view.';

  @override
  String get errorReload => 'Reload';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get npAccuracyNote => 'Lyrics may not be accurate for some songs';

  @override
  String get npClose => 'Close';

  @override
  String get npLike => 'Save to Liked Songs';

  @override
  String get npLineHint =>
      'Click to jump · Shift+click to sync this line to now';

  @override
  String get npLyrics => 'Lyrics';

  @override
  String get npMute => 'Mute';

  @override
  String get npNext => 'Next';

  @override
  String get npNoLyrics => 'No lyrics found for this track.';

  @override
  String get npPause => 'Pause';

  @override
  String get npPlay => 'Play';

  @override
  String get npPrev => 'Previous';

  @override
  String get npQueue => 'Queue';

  @override
  String get npRepeatAll => 'Repeat: all';

  @override
  String get npRepeatOff => 'Repeat: off';

  @override
  String get npRepeatOne => 'Repeat: one';

  @override
  String get npSeek => 'Seek';

  @override
  String get npShuffle => 'Shuffle';

  @override
  String get npTitle => 'Now playing';

  @override
  String get npUnlike => 'Remove from Liked Songs';

  @override
  String get npUnmute => 'Unmute';

  @override
  String get npVolume => 'Volume';

  @override
  String rewindArtistStats(String plays, String time) {
    return '$plays plays · $time this month';
  }

  @override
  String rewindChipArtists(String n) {
    return '$n artists';
  }

  @override
  String rewindChipPlays(String n) {
    return '$n plays';
  }

  @override
  String rewindChipTotal(String time) {
    return '$time total';
  }

  @override
  String rewindChipTracks(String n) {
    return '$n tracks';
  }

  @override
  String get rewindClose => 'Close rewind';

  @override
  String rewindDurHm(String h, String m) {
    return '${h}h ${m}m';
  }

  @override
  String rewindDurM(String m) {
    return '${m}m';
  }

  @override
  String get rewindIntroLine =>
      'A month of yours: every play, counted on this device.';

  @override
  String get rewindIntroLinePartial =>
      'Your month so far: every play, counted on this device.';

  @override
  String get rewindIntroTag => 'Awady Music · monthly';

  @override
  String get rewindIntroTagPartial => 'Awady Music · still counting';

  @override
  String get rewindKeepListening => 'Keep listening';

  @override
  String get rewindListenedFor => 'you listened for';

  @override
  String get rewindMin => 'min';

  @override
  String get rewindNext => 'Next';

  @override
  String get rewindNextSlide => 'Next slide';

  @override
  String get rewindOnRepeat => 'on repeat';

  @override
  String get rewindPlayAgain => 'Play it again';

  @override
  String get rewindPlayTop => 'Play your top tracks';

  @override
  String rewindPlaysAcross(String time, String plays, String tracks) {
    return '$time · $plays plays across $tracks tracks';
  }

  @override
  String get rewindPrev => 'Previous';

  @override
  String get rewindPrevSlide => 'Previous slide';

  @override
  String get rewindThatWas => 'that was';

  @override
  String rewindTitle(String month) {
    return '$month Rewind';
  }

  @override
  String get rewindTopArtist => 'your #1 artist';

  @override
  String get rewindTracksTitle => 'The songs you couldn\'t stop';

  @override
  String get downloadsCancel => 'Cancel download';

  @override
  String get downloadsEmptyCta => 'Find music to download';

  @override
  String get downloadsEmptyHint =>
      'Download tracks to listen offline anytime without an internet connection';

  @override
  String get downloadsEmptyNeedDesktop => 'Downloads need the desktop app.';

  @override
  String get downloadsEmptyTitle => 'No downloaded songs';

  @override
  String get downloadsKicker => 'Offline';

  @override
  String get downloadsOpenFolder => 'Open folder';

  @override
  String get downloadsPlayAll => 'Play all';

  @override
  String get downloadsQueued => 'Queued';

  @override
  String get downloadsRemoveLabel => 'Delete download';

  @override
  String downloadsSubtitle(String n) {
    return '$n tracks, stored on this device, playable offline';
  }

  @override
  String get downloadsTitle => 'Downloads';

  @override
  String get genreKicker => 'Genre';

  @override
  String get genreLoadError => 'Couldn\'t load this genre right now.';

  @override
  String get genrePlay => 'Play';

  @override
  String get genreRetry => 'Retry';

  @override
  String get genreTimeAllTime => 'All time';

  @override
  String get genreTimeMonth => 'This month';

  @override
  String get genreTimeWeek => 'This week';

  @override
  String get genreTopHits => 'Top hits';

  @override
  String get genreTrending => '· trending';

  @override
  String homeBecauseListened(String name) {
    return 'Because you listened to $name';
  }

  @override
  String get homeChart => 'Chart';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String get homeGreetingLate => 'Up late?';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeHotPlaylists => 'Hot playlists';

  @override
  String get homeLoadError => 'Couldn\'t load your music';

  @override
  String get homeLoadErrorHint =>
      'Check your connection. Both catalogs are unreachable.';

  @override
  String homeMoodMixes(String name) {
    return '$name mixes';
  }

  @override
  String get homeNewForYou => 'New for you';

  @override
  String get homeNewReleases => 'New releases';

  @override
  String get homeRetry => 'Retry';

  @override
  String homeRewindPartialReady(String label) {
    return 'Your $label so far is ready';
  }

  @override
  String homeRewindReady(String label) {
    return 'Your $label Rewind is ready';
  }

  @override
  String get homeRewindSub => 'Every play, counted on this device.';

  @override
  String get homeRewindWatch => 'Watch';

  @override
  String get homeTopArtists => 'Top artists';

  @override
  String get homeTopSongs => 'Top songs this week';

  @override
  String get homeTrending => 'Trending this week';

  @override
  String get moodLoadError => 'Couldn\'t load this mood';

  @override
  String get moodMixes => 'Mixes';

  @override
  String moodPlaylists(String name) {
    return '$name playlists';
  }

  @override
  String get moodRetry => 'Retry';

  @override
  String get moodTopTracks => 'Top tracks';

  @override
  String get searchAria => 'Search';

  @override
  String get searchArtists => 'Artists';

  @override
  String get searchBrowseGenres => 'Browse genres';

  @override
  String get searchClear => 'Clear';

  @override
  String get searchFailed => 'Search failed';

  @override
  String get searchFailedHint =>
      'Could not reach the music catalog. Please check your connection and retry';

  @override
  String get searchMoods => 'Moods & moments';

  @override
  String get searchMoreTracks => 'More tracks';

  @override
  String searchNoResults(String q) {
    return 'No results for “$q”';
  }

  @override
  String get searchNoResultsHint =>
      'Check your spelling or try searching for another song, artist, or album';

  @override
  String get searchPlaceholder => 'Songs, artists, playlists…';

  @override
  String get searchPlaylistsAlbums => 'Playlists & albums';

  @override
  String get searchRetry => 'Retry';

  @override
  String get searchSong => 'Song';

  @override
  String get searchSongs => 'Songs';

  @override
  String get searchTopResult => 'Top result';

  @override
  String get statsArtistsHeard => 'Artists heard';

  @override
  String get statsEmptyHint =>
      'Start playing songs to track your favorite artists, tracks, and listening habits';

  @override
  String get statsEmptyTitle => 'No listening stats yet';

  @override
  String get statsListeningTime => 'Listening time';

  @override
  String get statsNoListening => 'no listening';

  @override
  String statsRewindFull(String label) {
    return 'Watch your $label Rewind';
  }

  @override
  String statsRewindPartial(String label) {
    return 'Watch your $label so far';
  }

  @override
  String get statsSubtitle => 'Counted on this device. Never uploaded.';

  @override
  String get statsThisWeek => 'This week';

  @override
  String get statsTitle => 'Your stats';

  @override
  String get statsTopArtists => 'Top artists';

  @override
  String get statsTopTracks => 'Top tracks';

  @override
  String get statsTotalPlays => 'Total plays';

  @override
  String get statsTracksPlayed => 'Tracks played';

  @override
  String statsWeekTotal(String t) {
    return '$t this week';
  }

  @override
  String get artistAbout => 'About';

  @override
  String get artistAlbums => 'Albums';

  @override
  String get artistFollow => 'Follow';

  @override
  String get artistFollowing => 'Following';

  @override
  String artistMonthlyListeners(String n) {
    return '$n monthly listeners';
  }

  @override
  String get artistNoTracks => 'This artist hasn\'t uploaded tracks yet.';

  @override
  String get artistNotFound => 'Artist not found';

  @override
  String artistNotFoundNamed(String name) {
    return 'Couldn\'t load $name\'s page. It may have moved or the network hiccuped.';
  }

  @override
  String get artistNotFoundSub =>
      'They may have moved or the network hiccuped.';

  @override
  String get artistPlay => 'Play';

  @override
  String get artistPopular => 'Popular';

  @override
  String get artistRetry => 'Retry';

  @override
  String artistShowAll(String n) {
    return 'Show all $n';
  }

  @override
  String get artistShowLess => 'Show less';

  @override
  String get artistSingles => 'Singles & EPs';

  @override
  String artistStats(String followers, String tracks) {
    return '$followers followers · $tracks tracks';
  }

  @override
  String get artistTracksError =>
      'Couldn\'t load the tracks. The artist page itself is fine.';

  @override
  String get artistVerified => 'Verified artist';

  @override
  String get importBadCsv => 'Couldn\'t read that CSV';

  @override
  String get importBadJson =>
      'Couldn\'t read that file. Expected a .freebify.json playlist';

  @override
  String get importButton => 'Import';

  @override
  String get importChooseCsv => 'Choose .csv file';

  @override
  String get importClose => 'Close';

  @override
  String get importCsvHint =>
      'For longer or private playlists. Title + artist columns are detected automatically. Max 5000.';

  @override
  String get importCsvLabel => 'CSV export';

  @override
  String get importFailed => 'Import failed. Try again';

  @override
  String importImported(String n) {
    return 'Imported $n tracks';
  }

  @override
  String importLimited(String n) {
    return 'Imported $n tracks. Spotify only published the first 100, export a CSV to bring the rest.';
  }

  @override
  String get importLinkHint =>
      'Spotify: paste any public playlist link, full track list. YouTube Music: full list, no matching needed.';

  @override
  String get importLinkLabel => 'Spotify or YouTube Music link';

  @override
  String get importNotFound => 'Playlist not found. Check it isn\'t private';

  @override
  String get importPasteLink =>
      'Paste a Spotify or YouTube Music playlist link';

  @override
  String get importSubmit => 'Import playlist';

  @override
  String get importTitle => 'Import a playlist';

  @override
  String get importUnreadable =>
      'Couldn\'t read that playlist. Check it\'s public';

  @override
  String get libraryEmptyLikedCta => 'Find something to love';

  @override
  String get libraryEmptyLikedSub => 'Tap the heart on any track to save it.';

  @override
  String get libraryEmptyLikedTitle => 'Songs you like will live here';

  @override
  String get libraryEmptyPlaylists =>
      'Create a playlist and add songs from the ··· menu on any track.';

  @override
  String get libraryFollowed => 'Artists you follow';

  @override
  String get libraryLikedSongs => 'Liked Songs';

  @override
  String get libraryNewPlaylist => 'New playlist';

  @override
  String get libraryPlayAll => 'Play all';

  @override
  String get libraryPlaylistLabel => 'Playlist';

  @override
  String get libraryRecents => 'Recently played';

  @override
  String libraryTrackCount(String n) {
    return '$n tracks';
  }

  @override
  String get libraryYourPlaylists => 'Your playlists';

  @override
  String get playlistAlbum => 'Album';

  @override
  String get playlistAlreadyDownloaded => 'Already downloaded';

  @override
  String get playlistCopyLink => 'Copy link';

  @override
  String get playlistCopyLinkAria => 'Copy playlist link';

  @override
  String get playlistDelete => 'Delete';

  @override
  String get playlistDeleteConfirm => 'Delete?';

  @override
  String get playlistDownloadAll => 'Download all';

  @override
  String get playlistDownloadAllTitle =>
      'Download all tracks for offline playback';

  @override
  String playlistDownloading(String n) {
    return 'Downloading $n tracks';
  }

  @override
  String get playlistEmpty => 'This playlist is empty.';

  @override
  String get playlistExport => 'Export';

  @override
  String get playlistExportTitle => 'Export as a shareable .freebify.json file';

  @override
  String get playlistExported => 'Playlist exported';

  @override
  String get playlistEmptyLocalSub => 'Use the ··· menu on any track.';

  @override
  String get playlistEmptyLocalTitle => 'Songs you add will live here';

  @override
  String get playlistFindInPlaylist => 'Find in playlist';

  @override
  String get playlistFindSongs => 'Find songs';

  @override
  String playlistNoMatch(String q) {
    return 'No tracks match “$q”.';
  }

  @override
  String get playlistNotFound => 'Playlist not found';

  @override
  String get playlistNotFoundLocalSub => 'It may have been deleted.';

  @override
  String get playlistNotFoundSub =>
      'It may have been removed or the network hiccuped.';

  @override
  String get playlistPlay => 'Play';

  @override
  String get playlistPlaylist => 'Playlist';

  @override
  String playlistPlays(String n) {
    return '$n plays';
  }

  @override
  String get playlistRemoveLabel => 'Remove from playlist';

  @override
  String get playlistRename => 'Rename';

  @override
  String get playlistRenameAria => 'Rename playlist';

  @override
  String get playlistRetry => 'Retry';

  @override
  String get playlistSaveToLibrary => 'Save to Library';

  @override
  String get playlistSort => 'Sort';

  @override
  String get playlistSortTitle => 'Title';

  @override
  String get playlistSortArtist => 'Artist';

  @override
  String get playlistSortDuration => 'Length';

  @override
  String playlistTrackCount(String n) {
    return '$n tracks';
  }

  @override
  String get playlistTracksError =>
      'Couldn\'t load the tracks. The playlist itself is fine.';

  @override
  String get playlistUnknown => 'Unknown';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutBody =>
      'Free, ad-free music. Awady Music is a player, not a host: all audio & metadata are fetched by your device, directly from YouTube Music & the Audius public API, under their own terms. For personal, non-commercial use. Not affiliated with Spotify, YouTube, Google or Audius.';

  @override
  String settingsAboutVersions(String electron, String chromium) {
    return 'Electron $electron · Chromium $chromium';
  }

  @override
  String get settingsAutoplay => 'Autoplay similar songs';

  @override
  String get settingsAutoplaySub => 'Keep the queue going when it ends';

  @override
  String get settingsBackupExported => 'Backup exported';

  @override
  String get settingsCacheCleared => 'Cache cleared. Your library is untouched';

  @override
  String get settingsCacheFailed => 'Couldn\'t clear the cache';

  @override
  String get settingsCheckUpdates => 'Check for updates';

  @override
  String get settingsChecking => 'Checking…';

  @override
  String get settingsClearCache => 'Clear artwork & lyrics cache';

  @override
  String get settingsContribute => 'Open source. Contribute on GitHub';

  @override
  String get settingsDiscord => 'Discord status';

  @override
  String get settingsDiscordSub =>
      'Show what you\'re listening to on your profile';

  @override
  String get settingsExport => 'Export library & stats';

  @override
  String get settingsExportFailed => 'Export failed';

  @override
  String get settingsKSpace => 'Space';

  @override
  String get settingsLegal => 'Legal: disclaimer & terms';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSub => 'Applies to the whole app instantly.';

  @override
  String get settingsLibrary => 'Library';

  @override
  String settingsLibraryStats(String liked, String playlists) {
    return '$liked liked songs · $playlists playlists, stored locally on this device.';
  }

  @override
  String get settingsLogin => 'Open Awady Music when you sign in';

  @override
  String get settingsLoginSub =>
      'Start with your desktop, ready in the background';

  @override
  String get settingsOpenLogs => 'Open logs folder';

  @override
  String get settingsPlayback => 'Playback';

  @override
  String get settingsScClosePanels => 'Close panels';

  @override
  String get settingsScLike => 'Like current track';

  @override
  String get settingsScMute => 'Mute';

  @override
  String get settingsScNowPlaying => 'Now Playing';

  @override
  String get settingsScPlayPause => 'Play / pause';

  @override
  String get settingsScQueue => 'Queue';

  @override
  String get settingsScSearch => 'Search';

  @override
  String get settingsScSeek => 'Seek 10 seconds';

  @override
  String get settingsScVolume => 'Volume';

  @override
  String get settingsShortcuts => 'Keyboard shortcuts';

  @override
  String get settingsTitle => 'Settings';

  @override
  String settingsUpdateAvailable(String v) {
    return 'v$v available, downloading in the background';
  }

  @override
  String get settingsUpdateFailed => 'Update check failed';

  @override
  String get settingsUpdateFailedLater =>
      'Update check failed. Try again later';

  @override
  String get settingsUpdateLatest => 'You\'re up to date';

  @override
  String settingsUpdatePending(String v) {
    return 'v$v is ready. Restart from the banner';
  }

  @override
  String get themeMode => 'Theme';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get reduceTransparency => 'Reduce transparency';

  @override
  String get reduceTransparencySubtitle =>
      'Use solid surfaces instead of translucent blur effects';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get streamQuality => 'Audio streaming quality';

  @override
  String get qualityHigh => 'High (best audio)';

  @override
  String get qualityLow => 'Data saver (low)';

  @override
  String get wifiOnlyDownloads => 'Download over Wi-Fi only';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get cacheCleared => 'Cache cleared successfully';

  @override
  String get exportBackup => 'Export library backup';

  @override
  String get importBackup => 'Import library backup';

  @override
  String get importBackupSuccess => 'Library backup imported successfully';

  @override
  String get importBackupConfirm =>
      'Importing this backup will merge playlists, liked songs, and listening history. Continue?';

  @override
  String get shareLogs => 'Share logs';

  @override
  String get noLogs => 'No logs found to share';

  @override
  String get synced => 'Synced line to current playback time';

  @override
  String get syncLineToNow => 'Sync this line to now';

  @override
  String get accuracyNote =>
      'Lyrics timing may vary slightly between recordings';

  @override
  String get appUpdateDownload => 'Download update';

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String get newPlaylist => 'New playlist';

  @override
  String get createPlaylist => 'Create playlist';

  @override
  String get playlistNamePlaceholder => 'Playlist name';

  @override
  String get disclaimer => 'Disclaimer';

  @override
  String get terms => 'Terms of Service';

  @override
  String get privacy => 'Privacy Policy';

  @override
  String get legal => 'Legal & Licenses';

  @override
  String get aboutAttribution =>
      'Based on the open-source Freebify design and concept';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get deleteAction => 'Delete';

  @override
  String get editAction => 'Edit';

  @override
  String get doneAction => 'Done';

  @override
  String get removeAction => 'Remove';

  @override
  String get playAction => 'Play';

  @override
  String get pauseAction => 'Pause';

  @override
  String get shuffleAction => 'Shuffle';

  @override
  String get addTracks => 'Add tracks';

  @override
  String get renamePlaylist => 'Rename playlist';

  @override
  String get deletePlaylistConfirm =>
      'Are you sure you want to delete this playlist?';

  @override
  String get startRadio => 'Start radio';

  @override
  String get goToArtist => 'Go to artist';

  @override
  String get goToAlbum => 'Go to album';

  @override
  String get saveToLibrary => 'Save to library';

  @override
  String get removeFromLibrary => 'Remove from library';

  @override
  String get downloadTrack => 'Download track';

  @override
  String get removeDownload => 'Remove download';

  @override
  String get downloaded => 'Downloaded';

  @override
  String get downloading => 'Downloading';

  @override
  String get queued => 'Queued';

  @override
  String get shareTrack => 'Share track';

  @override
  String get sharePlaylist => 'Share playlist';

  @override
  String get copyLink => 'Copy link';

  @override
  String get linkCopied => 'Link copied to clipboard';

  @override
  String get noLyrics => 'No lyrics available for this song';

  @override
  String matchingProgress(String matched, String total) {
    return 'Matching $matched of $total tracks…';
  }

  @override
  String get importPlaylistTitle => 'Import playlist';

  @override
  String get importUrlHint => 'Paste Spotify or YouTube Music playlist link';

  @override
  String get importFileButton => 'Choose CSV or .freebify.json file';

  @override
  String get allFilter => 'All';

  @override
  String get songsFilter => 'Songs';

  @override
  String get artistsFilter => 'Artists';

  @override
  String get playlistsFilter => 'Playlists & albums';

  @override
  String get topResult => 'Top result';

  @override
  String get moreTracks => 'More songs';

  @override
  String get popularTracks => 'Popular';

  @override
  String get discography => 'Discography';

  @override
  String get albumsSection => 'Albums';

  @override
  String get singlesSection => 'Singles & EPs';

  @override
  String get aboutArtist => 'About';

  @override
  String monthlyListenersCount(String n) {
    return '$n monthly listeners';
  }

  @override
  String followersCount(String n) {
    return '$n followers';
  }

  @override
  String trackCountLabel(String n) {
    return '$n tracks';
  }

  @override
  String get listeningTime => 'Listening time';

  @override
  String get totalPlays => 'Total plays';

  @override
  String get tracksPlayed => 'Tracks played';

  @override
  String get artistsHeard => 'Artists heard';

  @override
  String get thisWeek => 'This week';

  @override
  String get topTracks => 'Top tracks';

  @override
  String get topArtists => 'Top artists';

  @override
  String get rewindAction => 'Watch Rewind';

  @override
  String get equalizerTitle => 'Equalizer';

  @override
  String get eqPresetCustom => 'Custom';

  @override
  String get sleepTimerTitle => 'Sleep timer';

  @override
  String get sleepTimerOff => 'Off';

  @override
  String get sleepTimer5 => '5 minutes';

  @override
  String get sleepTimer15 => '15 minutes';

  @override
  String get sleepTimer30 => '30 minutes';

  @override
  String get sleepTimer45 => '45 minutes';

  @override
  String get sleepTimer60 => '60 minutes';

  @override
  String get sleepTimerTrackEnd => 'End of current track';

  @override
  String get librarySearchHint => 'Search your library';

  @override
  String get librarySortRecent => 'Recent';

  @override
  String get librarySortName => 'Name';

  @override
  String get librarySortTracks => 'Track count';

  @override
  String get libraryNoResults => 'No matches in your library';

  @override
  String get libraryMatchingSongs => 'Matching songs';

  @override
  String get libraryEmptyArtists => 'No followed artists yet.';

  @override
  String get libraryArtistLabel => 'Artist';
}
