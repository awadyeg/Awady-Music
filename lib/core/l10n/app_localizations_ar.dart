// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class L10nAr extends L10n {
  L10nAr([String locale = 'ar']) : super(locale);

  @override
  String get appDismissUpdate => 'Dismiss update';

  @override
  String get appDownload => 'تنزيل';

  @override
  String get appOffline =>
      'أنت غير متصل بالإنترنت. يتم عرض الموسيقى المنزلة والمحفوظة مؤقتاً';

  @override
  String get appRestart => 'Restart';

  @override
  String get appUpdateAvail => 'يتوفر تحديث جديد';

  @override
  String get appUpdateManualHint => 'Download the new dmg';

  @override
  String appUpdateReady(String version) {
    return 'v$version ready';
  }

  @override
  String get appUpdateRestartHint => 'Restart to update';

  @override
  String get cardAlbum => 'الألبوم';

  @override
  String get cardArtist => 'الفنان';

  @override
  String cardFollowers(String n) {
    return '$n متابع';
  }

  @override
  String get cardOpen => 'Open';

  @override
  String get cardPlay => 'تشغيل';

  @override
  String get cardPlaylist => 'تشغيلlist';

  @override
  String cardPlays(String n) {
    return '$n استماع';
  }

  @override
  String get cardScrollLeft => 'Scroll left';

  @override
  String get cardScrollRight => 'Scroll right';

  @override
  String cardTracks(String n) {
    return '$n مقطع صوتي';
  }

  @override
  String get eqCrossfade => 'التلاشي المتقاطع';

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
  String get eqNormalize => 'موازنة مستوى الصوت';

  @override
  String get eqOff => 'off';

  @override
  String get eqPresetBass => 'تعزيز الباس';

  @override
  String get eqPresetBright => 'صوت نقي';

  @override
  String get eqPresetFlat => 'متوازن';

  @override
  String get eqPresetVocal => 'تعزيز الصوت البشري';

  @override
  String get eqPresetVshape => 'منحنى V';

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
  String get navHome => 'الرئيسية';

  @override
  String get navHomeAria => 'Freebify home';

  @override
  String get navLibrary => 'المكتبة';

  @override
  String get navSearch => 'بحث';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get navStats => 'الإحصائيات';

  @override
  String get playerCancelLoading => 'إلغاء loading';

  @override
  String get playerLike => 'حفظ to Liked الأغاني';

  @override
  String get playerMute => 'Mute';

  @override
  String get playerNext => 'التالي';

  @override
  String get playerNowPlaying => 'Now playing';

  @override
  String get playerOpenNowPlaying => 'Open Now تشغيلing';

  @override
  String get playerPause => 'إيقاف مؤقت';

  @override
  String get playerPick => 'Pick something to play';

  @override
  String get playerPlay => 'تشغيل';

  @override
  String get playerPrev => 'السابق';

  @override
  String get playerQueue => 'قائمة الانتظار';

  @override
  String get playerRepeatAll => 'Repeat: all';

  @override
  String get playerRepeatOff => 'Repeat: off';

  @override
  String get playerRepeatOne => 'Repeat: one';

  @override
  String get playerSeek => 'Seek';

  @override
  String get playerShuffle => 'تشغيل عشوائي';

  @override
  String get playerUnlike => 'إزالة from Liked الأغاني';

  @override
  String get playerUnmute => 'Unmute';

  @override
  String get playerVolume => 'Volume';

  @override
  String get queueAutoplay => 'تشغيل تلقائي لأغانٍ مشابهة';

  @override
  String get queueClear => 'مسح قائمة الانتظار';

  @override
  String get queueClearConfirmAria => 'مسح قائمة الانتظار';

  @override
  String get queueClearConfirmTitle => 'مسح قائمة الانتظار';

  @override
  String get queueClearQuestion => 'هل تريد مسح كامل قائمة الانتظار؟';

  @override
  String get queueClose => 'Close queue';

  @override
  String get queueEmpty => 'قائمة الانتظار فارغة';

  @override
  String get queueEndHint =>
      'سيقوم التشغيل التلقائي بإضافة أغانٍ مشابهة عند اقتراب انتهاء القائمة';

  @override
  String get queueNextUp => 'التالي في قائمة الانتظار';

  @override
  String get queueNowPlaying => 'قيد التشغيل الآن';

  @override
  String get queueRadio => 'Start radio from this song';

  @override
  String queueRemoveTrack(String title) {
    return 'إزالة $title from queue';
  }

  @override
  String get queueSaveAs => 'حفظ queue as playlist';

  @override
  String get queueSavedAsPlaylist => 'حفظd queue as playlist';

  @override
  String get queueTitle => 'قائمة الانتظار';

  @override
  String get sideDownloads => 'التنزيلات';

  @override
  String get sideLiked => 'Liked الأغاني';

  @override
  String sideMorePlaylists(String n) {
    return '+$n more, see all';
  }

  @override
  String get sideRecentlyPlayed => 'تم تشغيله مؤخراً';

  @override
  String sideTracks(String n) {
    return '$n مقطع صوتي';
  }

  @override
  String get sideYourLibrary => 'مكتبتك';

  @override
  String get tableAddPlaylist => 'إضافة إلى قائمة تشغيل';

  @override
  String get tableAddQueue => 'إضافة إلى قائمة الانتظار';

  @override
  String get tableAddedNewPlaylist => 'Added to new playlist';

  @override
  String tableAddedToPlaylist(String name) {
    return 'Added to \\\"$name\\\"';
  }

  @override
  String get tableBadgeEdit => 'تعديل';

  @override
  String get tableBadgeSet => 'Set';

  @override
  String get tableColArtist => 'الفنان';

  @override
  String get tableColPlays => 'تشغيلs';

  @override
  String get tableColTime => 'Time';

  @override
  String get tableColTitle => 'Title';

  @override
  String get tableCopied => 'Copied';

  @override
  String get tableCopyLink => 'نسخ الرابط';

  @override
  String get tableDownload => 'تنزيل';

  @override
  String tableDownloading(String pct) {
    return 'جارٍ التنزيل… $pct%';
  }

  @override
  String get tableEmpty => 'Nothing here yet.';

  @override
  String get tableGoAlbum => 'الانتقال إلى الألبوم';

  @override
  String get tableGoArtist => 'الانتقال إلى الفنان';

  @override
  String get tableLike => 'حفظ to Liked الأغاني';

  @override
  String get tableLinkCopied => 'Link copied';

  @override
  String get tableMore => 'More options';

  @override
  String get tableNewPlaylist => 'New playlist';

  @override
  String get tablePlayNext => 'تشغيل تالياً';

  @override
  String tablePlayTrack(String title) {
    return 'تشغيل $title';
  }

  @override
  String get tableRadioFail => 'Couldn\'t start a radio for this track';

  @override
  String get tableRemoveDownload => 'إزالة التنزيل';

  @override
  String get tableRemoveFrom => 'إزالة from playlist';

  @override
  String tableRemovedFromPlaylist(String name) {
    return 'إزالةd from \\\"$name\\\"';
  }

  @override
  String get tableStartRadio => 'بدء الراديو';

  @override
  String get tableUnlike => 'إزالة from Liked الأغاني';

  @override
  String get topBack => 'رجوع';

  @override
  String get topForward => 'Forward';

  @override
  String get winClose => 'إغلاق';

  @override
  String get winCloseToTray => 'Close to tray';

  @override
  String get winMaximize => 'Maximize';

  @override
  String get winMinimize => 'Minimize';

  @override
  String get winRestore => 'Restore';

  @override
  String get coreNoConnection => 'تعذر التشغيل. تحقق من اتصالك وحاول مرة أخرى';

  @override
  String get coreNothingPlayable => 'لا يوجد محتوى قابل للتشغيل في هذه القائمة';

  @override
  String get coreUnavailable => 'هذا المقطع غير متوفر للبث';

  @override
  String get coreQueueFull => 'قائمة الانتظار ممتلئة';

  @override
  String get coreAddedQueue => 'تمت الإضافة إلى قائمة الانتظار';

  @override
  String get corePlayNext => 'سيتم التشغيل تالياً';

  @override
  String get coreRadioStarted => 'تم بدء الراديو وإضافة أغانٍ مشابهة';

  @override
  String get coreSleepPaused => 'مؤقت النوم: تم إيقاف التشغيل مؤقتاً';

  @override
  String get errorBody => 'حدث خطأ غير متوقع أثناء تحميل هذه الصفحة.';

  @override
  String get errorReload => 'إعادة التحميل';

  @override
  String get errorTitle => 'حدث خطأ ما';

  @override
  String get npAccuracyNote => 'Lyrics may not be accurate for some songs';

  @override
  String get npClose => 'إغلاق';

  @override
  String get npLike => 'حفظ to Liked الأغاني';

  @override
  String get npLineHint =>
      'Click to jump · Shift+click to sync this line to now';

  @override
  String get npLyrics => 'كلمات الأغاني';

  @override
  String get npMute => 'Mute';

  @override
  String get npNext => 'التالي';

  @override
  String get npNoLyrics => 'No lyrics found for this track.';

  @override
  String get npPause => 'إيقاف مؤقت';

  @override
  String get npPlay => 'تشغيل';

  @override
  String get npPrev => 'السابق';

  @override
  String get npQueue => 'قائمة الانتظار';

  @override
  String get npRepeatAll => 'Repeat: all';

  @override
  String get npRepeatOff => 'Repeat: off';

  @override
  String get npRepeatOne => 'Repeat: one';

  @override
  String get npSeek => 'Seek';

  @override
  String get npShuffle => 'تشغيل عشوائي';

  @override
  String get npTitle => 'Now playing';

  @override
  String get npUnlike => 'إزالة from Liked الأغاني';

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
    return '$n فنان';
  }

  @override
  String rewindChipPlays(String n) {
    return '$n تشغيل';
  }

  @override
  String rewindChipTotal(String time) {
    return '$time إجمالي';
  }

  @override
  String rewindChipTracks(String n) {
    return '$n أغنية';
  }

  @override
  String get rewindClose => 'Close rewind';

  @override
  String rewindDurHm(String h, String m) {
    return '$h س $m د';
  }

  @override
  String rewindDurM(String m) {
    return '$m د';
  }

  @override
  String get rewindIntroLine =>
      'A month of yours: every play, counted on this device.';

  @override
  String get rewindIntroLinePartial =>
      'Your month so far: every play, counted on this device.';

  @override
  String get rewindIntroTag => 'Freebify · monthly';

  @override
  String get rewindIntroTagPartial => 'Freebify · still counting';

  @override
  String get rewindKeepListening => 'Keep listening';

  @override
  String get rewindListenedFor => 'you listened for';

  @override
  String get rewindMin => 'min';

  @override
  String get rewindNext => 'التالي';

  @override
  String get rewindNextSlide => 'Next slide';

  @override
  String get rewindOnRepeat => 'on repeat';

  @override
  String get rewindPlayAgain => 'تشغيل it again';

  @override
  String get rewindPlayTop => 'تشغيل your top tracks';

  @override
  String rewindPlaysAcross(String time, String plays, String tracks) {
    return '$time · $plays plays across $tracks tracks';
  }

  @override
  String get rewindPrev => 'السابق';

  @override
  String get rewindPrevSlide => 'Previous slide';

  @override
  String get rewindThatWas => 'that was';

  @override
  String rewindTitle(String month) {
    return 'ملخص $month';
  }

  @override
  String get rewindTopArtist => 'your #1 artist';

  @override
  String get rewindTracksTitle => 'The songs you couldn\'t stop';

  @override
  String get downloadsCancel => 'إلغاء download';

  @override
  String get downloadsEmptyCta => 'البحث عن موسيقى لتنزيلها';

  @override
  String get downloadsEmptyHint =>
      'قم بتنزيل المقاطع للاستماع إليها بدون اتصال بالإنترنت في أي وقت';

  @override
  String get downloadsEmptyNeedDesktop => 'Downloads need the desktop app.';

  @override
  String get downloadsEmptyTitle => 'لا توجد أغانٍ منزلة بعد';

  @override
  String get downloadsKicker => 'غير متصل بالإنترنت';

  @override
  String get downloadsOpenFolder => 'Open folder';

  @override
  String get downloadsPlayAll => 'تشغيل الكل';

  @override
  String get downloadsQueued => 'Queued';

  @override
  String get downloadsRemoveLabel => 'حذف download';

  @override
  String downloadsSubtitle(String n) {
    return '$n مقطع صوتي، مخزنة على هذا الجهاز وقابلة للتشغيل بدون إنترنت';
  }

  @override
  String get downloadsTitle => 'التنزيلات';

  @override
  String get genreKicker => 'Genre';

  @override
  String get genreLoadError => 'Couldn\'t load this genre right now.';

  @override
  String get genrePlay => 'تشغيل';

  @override
  String get genreRetry => 'إعادة المحاولة';

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
    return 'لأنك استمعت إلى $name';
  }

  @override
  String get homeChart => 'قائمة الصدارة';

  @override
  String get homeGreetingAfternoon => 'مساء الخير';

  @override
  String get homeGreetingEvening => 'مساء الخير';

  @override
  String get homeGreetingLate => 'استماع في وقت متأخر';

  @override
  String get homeGreetingMorning => 'صباح الخير';

  @override
  String get homeHotPlaylists => 'أشهر قوائم التشغيل';

  @override
  String get homeLoadError => 'Couldn\'t load your music';

  @override
  String get homeLoadErrorHint =>
      'Check your connection. Both catalogs are unreachable.';

  @override
  String homeMoodMixes(String name) {
    return 'ميكسات $name';
  }

  @override
  String get homeNewForYou => 'جديد لك';

  @override
  String get homeNewReleases => 'إصدارات جديدة';

  @override
  String get homeRetry => 'إعادة المحاولة';

  @override
  String homeRewindPartialReady(String label) {
    return 'ملخص $label حتى الآن جاهز';
  }

  @override
  String homeRewindReady(String label) {
    return 'ملخص $label الخاص بك جاهز';
  }

  @override
  String get homeRewindSub => 'Every play, counted on this device.';

  @override
  String get homeRewindWatch => 'مشاهدة الملخص';

  @override
  String get homeTopArtists => 'أبرز الفنانين';

  @override
  String get homeTopSongs => 'أفضل الأغاني هذا الأسبوع';

  @override
  String get homeTrending => 'الأكثر رواجاً هذا الأسبوع';

  @override
  String get moodLoadError => 'Couldn\'t load this mood';

  @override
  String get moodMixes => 'Mixes';

  @override
  String moodPlaylists(String name) {
    return '$name playlists';
  }

  @override
  String get moodRetry => 'إعادة المحاولة';

  @override
  String get moodTopTracks => 'Top tracks';

  @override
  String get searchAria => 'بحث';

  @override
  String get searchArtists => 'الفنانون';

  @override
  String get searchBrowseGenres => 'تصفح الأنواع';

  @override
  String get searchClear => 'مسح البحث';

  @override
  String get searchFailed => 'فشل البحث';

  @override
  String get searchFailedHint =>
      'تعذر الاتصال بكتالوج الموسيقى. يرجى التحقق من اتصالك وإعادة المحاولة';

  @override
  String get searchMoods => 'حالات وأجواء';

  @override
  String get searchMoreTracks => 'More tracks';

  @override
  String searchNoResults(String q) {
    return 'لا توجد نتائج لـ “$q”';
  }

  @override
  String get searchNoResultsHint =>
      'تحقق من صحة الكلمات أو جرب البحث عن أغنية أو فنان أو ألبوم آخر';

  @override
  String get searchPlaceholder => 'ما الذي تريد الاستماع إليه؟';

  @override
  String get searchPlaylistsAlbums => 'تشغيلlists & albums';

  @override
  String get searchRetry => 'إعادة المحاولة';

  @override
  String get searchSong => 'الأغنية';

  @override
  String get searchSongs => 'الأغاني';

  @override
  String get searchTopResult => 'Top result';

  @override
  String get statsArtistsHeard => 'الفنانون المستمع إليهم';

  @override
  String get statsEmptyHint =>
      'ابدأ بتشغيل الأغاني لتتبع فنانيك المفضلين وعادات الاستماع الخاصة بك هنا';

  @override
  String get statsEmptyTitle => 'لا توجد إحصائيات استماع حتى الآن';

  @override
  String get statsListeningTime => 'وقت الاستماع';

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
  String get statsSubtitle => 'ملخص نشاطك وعادات الاستماع الخاصة بك';

  @override
  String get statsThisWeek => 'This week';

  @override
  String get statsTitle => 'إحصائياتك';

  @override
  String get statsTopArtists => 'أفضل الفنانين';

  @override
  String get statsTopTracks => 'أفضل الأغاني';

  @override
  String get statsTotalPlays => 'إجمالي مرات التشغيل';

  @override
  String get statsTracksPlayed => 'الأغاني المستمع إليها';

  @override
  String statsWeekTotal(String t) {
    return '$t هذا الأسبوع';
  }

  @override
  String get artistAbout => 'نبذة عن الفنان';

  @override
  String get artistAlbums => 'الألبومات';

  @override
  String get artistFollow => 'متابعة';

  @override
  String get artistFollowing => 'متابعة';

  @override
  String artistMonthlyListeners(String n) {
    return '$n مستمع شهرياً';
  }

  @override
  String get artistNoTracks => 'This artist hasn\'t uploaded tracks yet.';

  @override
  String get artistNotFound => 'الفنان not found';

  @override
  String artistNotFoundNamed(String name) {
    return 'Couldn\'t load $name\'s page. It may have moved or the network hiccuped.';
  }

  @override
  String get artistNotFoundSub =>
      'They may have moved or the network hiccuped.';

  @override
  String get artistPlay => 'تشغيل';

  @override
  String get artistPopular => 'الأكثر شعبية';

  @override
  String get artistRetry => 'إعادة المحاولة';

  @override
  String artistShowAll(String n) {
    return 'Show all $n';
  }

  @override
  String get artistShowLess => 'Show less';

  @override
  String get artistSingles => 'الأغاني الفردية';

  @override
  String artistStats(String followers, String tracks) {
    return '$followers followers · $tracks tracks';
  }

  @override
  String get artistTracksError =>
      'Couldn\'t load the tracks. The artist page itself is fine.';

  @override
  String get artistVerified => 'فنان موثق';

  @override
  String get importBadCsv => 'Couldn\'t read that CSV';

  @override
  String get importBadJson =>
      'Couldn\'t read that file. Expected a .freebify.json playlist';

  @override
  String get importButton => 'استيراد';

  @override
  String get importChooseCsv => 'Choose .csv file';

  @override
  String get importClose => 'إغلاق';

  @override
  String get importCsvHint =>
      'For longer or private playlists. Title + artist columns are detected automatically. Max 5000.';

  @override
  String get importCsvLabel => 'CSV export';

  @override
  String get importFailed => 'استيراد failed. Try again';

  @override
  String importImported(String n) {
    return 'استيرادed $n tracks';
  }

  @override
  String importLimited(String n) {
    return 'استيرادed $n tracks. Spotify only published the first 100, export a CSV to bring the rest.';
  }

  @override
  String get importLinkHint =>
      'Spotify: paste any public playlist link, full track list. YouTube Music: full list, no matching needed.';

  @override
  String get importLinkLabel => 'Spotify or YouTube Music link';

  @override
  String get importNotFound => 'تشغيلlist not found. Check it isn\'t private';

  @override
  String get importPasteLink =>
      'Paste a Spotify or YouTube Music playlist link';

  @override
  String get importSubmit => 'استيراد playlist';

  @override
  String get importTitle => 'استيراد a playlist';

  @override
  String get importUnreadable =>
      'Couldn\'t read that playlist. Check it\'s public';

  @override
  String get libraryEmptyLikedCta => 'Find something to love';

  @override
  String get libraryEmptyLikedSub => 'Tap the heart on any track to save it.';

  @override
  String get libraryEmptyLikedTitle => 'الأغاني you like will live here';

  @override
  String get libraryEmptyPlaylists =>
      'Create a playlist and add songs from the ··· menu on any track.';

  @override
  String get libraryFollowed => 'الفنانون you follow';

  @override
  String get libraryLikedSongs => 'Liked الأغاني';

  @override
  String get libraryNewPlaylist => 'New playlist';

  @override
  String get libraryPlayAll => 'تشغيل all';

  @override
  String get libraryPlaylistLabel => 'تشغيلlist';

  @override
  String get libraryRecents => 'تم تشغيله مؤخراً';

  @override
  String libraryTrackCount(String n) {
    return '$n مقطع صوتي';
  }

  @override
  String get libraryYourPlaylists => 'Your playlists';

  @override
  String get playlistAlbum => 'الألبوم';

  @override
  String get playlistAlreadyDownloaded => 'Already downloaded';

  @override
  String get playlistCopyLink => 'نسخ الرابط';

  @override
  String get playlistCopyLinkAria => 'Copy playlist link';

  @override
  String get playlistDelete => 'حذف';

  @override
  String get playlistDeleteConfirm => 'حذف?';

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
  String get playlistExport => 'تصدير';

  @override
  String get playlistExportTitle => 'تصدير as a shareable .freebify.json file';

  @override
  String get playlistExported => 'تشغيلlist exported';

  @override
  String get playlistEmptyLocalSub => 'Use the ··· menu on any track.';

  @override
  String get playlistEmptyLocalTitle => 'الأغاني you add will live here';

  @override
  String get playlistFindInPlaylist => 'Find in playlist';

  @override
  String get playlistFindSongs => 'Find songs';

  @override
  String playlistNoMatch(String q) {
    return 'No tracks match “$q”.';
  }

  @override
  String get playlistNotFound => 'تشغيلlist not found';

  @override
  String get playlistNotFoundLocalSub => 'It may have been deleted.';

  @override
  String get playlistNotFoundSub =>
      'It may have been removed or the network hiccuped.';

  @override
  String get playlistPlay => 'تشغيل';

  @override
  String get playlistPlaylist => 'تشغيلlist';

  @override
  String playlistPlays(String n) {
    return '$n plays';
  }

  @override
  String get playlistRemoveLabel => 'إزالة from playlist';

  @override
  String get playlistRename => 'إعادة تسمية';

  @override
  String get playlistRenameAria => 'Rename playlist';

  @override
  String get playlistRetry => 'إعادة المحاولة';

  @override
  String get playlistSaveToLibrary => 'حفظ في المكتبة';

  @override
  String get playlistSort => 'Sort';

  @override
  String get playlistSortTitle => 'Title';

  @override
  String get playlistSortArtist => 'الفنان';

  @override
  String get playlistSortDuration => 'Length';

  @override
  String playlistTrackCount(String n) {
    return '$n مقطع صوتي';
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
      'Free, ad-free music. Freebify is a player, not a host: all audio & metadata are fetched by your device, directly from YouTube Music & the Audius public API, under their own terms. For personal, non-commercial use. Not affiliated with Spotify, YouTube, Google or Audius.';

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
  String get settingsExport => 'تصدير library & stats';

  @override
  String get settingsExportFailed => 'تصدير failed';

  @override
  String get settingsKSpace => 'Space';

  @override
  String get settingsLegal => 'Legal: disclaimer & terms';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSub => 'Applies to the whole app instantly.';

  @override
  String get settingsLibrary => 'المكتبة';

  @override
  String settingsLibraryStats(String liked, String playlists) {
    return '$liked liked songs · $playlists playlists, stored locally on this device.';
  }

  @override
  String get settingsLogin => 'Open Freebify when you sign in';

  @override
  String get settingsLoginSub =>
      'Start with your desktop, ready in the background';

  @override
  String get settingsOpenLogs => 'Open logs folder';

  @override
  String get settingsPlayback => 'تشغيلback';

  @override
  String get settingsScClosePanels => 'Close panels';

  @override
  String get settingsScLike => 'Like current track';

  @override
  String get settingsScMute => 'Mute';

  @override
  String get settingsScNowPlaying => 'قيد التشغيل الآن';

  @override
  String get settingsScPlayPause => 'تشغيل / pause';

  @override
  String get settingsScQueue => 'قائمة الانتظار';

  @override
  String get settingsScSearch => 'بحث';

  @override
  String get settingsScSeek => 'Seek 10 seconds';

  @override
  String get settingsScVolume => 'Volume';

  @override
  String get settingsShortcuts => 'Keyboard shortcuts';

  @override
  String get settingsTitle => 'الإعدادات';

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
  String get themeMode => 'المظهر';

  @override
  String get themeSystem => 'الافتراضي للنظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get reduceTransparency => 'تقليل الشفافية';

  @override
  String get reduceTransparencySubtitle =>
      'استخدام خلفيات صلبة بدلاً من تأثيرات التمويه والشفافية';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'الافتراضي للنظام';

  @override
  String get streamQuality => 'جودة بث الصوت';

  @override
  String get qualityHigh => 'عالية (أفضل صوت)';

  @override
  String get qualityLow => 'توفير البيانات (منخفضة)';

  @override
  String get wifiOnlyDownloads => 'التنزيل عبر شبكة Wi-Fi فقط';

  @override
  String get clearCache => 'مسح التخزين المؤقت';

  @override
  String get cacheCleared => 'تم مسح الذاكرة المؤقتة بنجاح';

  @override
  String get exportBackup => 'تصدير نسخة احتياطية للمكتبة';

  @override
  String get importBackup => 'استيراد نسخة احتياطية للمكتبة';

  @override
  String get importBackupSuccess => 'تم استيراد النسخة الاحتياطية بنجاح';

  @override
  String get importBackupConfirm =>
      'سيؤدي استيراد هذه النسخة إلى دمج قوائم التشغيل والإعجابات وسجل الاستماع. هل تريد المتابعة؟';

  @override
  String get shareLogs => 'مشاركة السجلات';

  @override
  String get noLogs => 'لا توجد سجلات للمشاركة';

  @override
  String get synced => 'تمت مزامنة هذا السطر مع وقت التشغيل الحالي';

  @override
  String get syncLineToNow => 'مزامنة هذا السطر مع الوقت الحالي';

  @override
  String get accuracyNote =>
      'قد يختلف توقيت الكلمات قليلاً بحسب التسجيل الصوتي';

  @override
  String get appUpdateDownload => 'تنزيل التحديث';

  @override
  String get nowPlaying => 'قيد التشغيل الآن';

  @override
  String get newPlaylist => 'قائمة تشغيل جديدة';

  @override
  String get createPlaylist => 'إنشاء قائمة تشغيل';

  @override
  String get playlistNamePlaceholder => 'اسم قائمة التشغيل';

  @override
  String get disclaimer => 'إخلاء المسؤولية';

  @override
  String get terms => 'شروط الخدمة';

  @override
  String get privacy => 'سياسة الخصوصية';

  @override
  String get legal => 'إشعارات قانونية وتراخيص';

  @override
  String get aboutAttribution =>
      'مبني على تطبيق Freebify بواسطة govu — https://github.com/govu/freebify';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get save => 'حفظ';

  @override
  String get deleteAction => 'حذف';

  @override
  String get editAction => 'تعديل';

  @override
  String get doneAction => 'تم';

  @override
  String get removeAction => 'إزالة';

  @override
  String get playAction => 'تشغيل';

  @override
  String get pauseAction => 'إيقاف مؤقت';

  @override
  String get shuffleAction => 'تشغيل عشوائي';

  @override
  String get addTracks => 'إضافة أغانٍ';

  @override
  String get renamePlaylist => 'إعادة تسمية قائمة التشغيل';

  @override
  String get deletePlaylistConfirm =>
      'هل أنت متأكد من رغبتك في حذف قائمة التشغيل هذه؟';

  @override
  String get startRadio => 'بدء الراديو';

  @override
  String get goToArtist => 'الانتقال إلى الفنان';

  @override
  String get goToAlbum => 'الانتقال إلى الألبوم';

  @override
  String get saveToLibrary => 'حفظ في المكتبة';

  @override
  String get removeFromLibrary => 'إزالة من المكتبة';

  @override
  String get downloadTrack => 'تنزيل المقطع الصوتي';

  @override
  String get removeDownload => 'إزالة التنزيل';

  @override
  String get downloaded => 'تم التنزيل';

  @override
  String get downloading => 'جارٍ التنزيل';

  @override
  String get queued => 'في الانتظار';

  @override
  String get shareTrack => 'مشاركة المقطع';

  @override
  String get sharePlaylist => 'مشاركة قائمة التشغيل';

  @override
  String get copyLink => 'نسخ الرابط';

  @override
  String get linkCopied => 'تم نسخ الرابط إلى الحافظة';

  @override
  String get noLyrics => 'لا تتوفر كلمات لهذه الأغنية';

  @override
  String matchingProgress(String matched, String total) {
    return 'جارٍ مطابقة $matched من $total أغنية…';
  }

  @override
  String get importPlaylistTitle => 'استيراد قائمة تشغيل';

  @override
  String get importUrlHint =>
      'الصق رابط قائمة تشغيل من Spotify أو YouTube Music';

  @override
  String get importFileButton => 'اختيار ملف CSV أو .freebify.json';

  @override
  String get allFilter => 'الكل';

  @override
  String get songsFilter => 'الأغاني';

  @override
  String get artistsFilter => 'الفنانون';

  @override
  String get playlistsFilter => 'القوائم والألبومات';

  @override
  String get topResult => 'النتيجة الأولى';

  @override
  String get moreTracks => 'المزيد من الأغاني';

  @override
  String get popularTracks => 'الأكثر شعبية';

  @override
  String get discography => 'الأعمال الغنائية';

  @override
  String get albumsSection => 'الألبومات';

  @override
  String get singlesSection => 'الأغاني الفردية والقصيرة';

  @override
  String get aboutArtist => 'نبذة عن الفنان';

  @override
  String monthlyListenersCount(String n) {
    return '$n مستمع شهرياً';
  }

  @override
  String followersCount(String n) {
    return '$n متابع';
  }

  @override
  String trackCountLabel(String n) {
    return '$n مقطع صوتي';
  }

  @override
  String get listeningTime => 'وقت الاستماع';

  @override
  String get totalPlays => 'إجمالي مرات التشغيل';

  @override
  String get tracksPlayed => 'المقاطع المستمع إليها';

  @override
  String get artistsHeard => 'الفنانون المستمع إليهم';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get topTracks => 'أفضل الأغاني';

  @override
  String get topArtists => 'أبرز الفنانين';

  @override
  String get rewindAction => 'مشاهدة الملخص';

  @override
  String get equalizerTitle => 'المعادل الصوتي';

  @override
  String get eqPresetCustom => 'مخصص';

  @override
  String get sleepTimerTitle => 'مؤقت النوم';

  @override
  String get sleepTimerOff => 'إيقاف';

  @override
  String get sleepTimer5 => '5 دقائق';

  @override
  String get sleepTimer15 => '15 دقيقة';

  @override
  String get sleepTimer30 => '30 دقيقة';

  @override
  String get sleepTimer45 => '45 دقيقة';

  @override
  String get sleepTimer60 => '60 دقيقة';

  @override
  String get sleepTimerTrackEnd => 'عند نهاية المقطع الحالي';
}
