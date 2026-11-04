const fs = require('fs');
const path = require('path');

const en = JSON.parse(fs.readFileSync('tool/en_keys.json', 'utf8'));
const es = JSON.parse(fs.readFileSync('tool/es_keys.json', 'utf8'));

function toCamelCase(str) {
  return str.replace(/[-_.]+(.)?/g, (_, c) => (c ? c.toUpperCase() : ''));
}

// Mobile-only keys
const mobileKeysEn = {
  themeMode: "Theme",
  themeSystem: "System default",
  themeLight: "Light",
  themeDark: "Dark",
  reduceTransparency: "Reduce transparency",
  reduceTransparencySubtitle: "Use solid surfaces instead of translucent blur effects",
  language: "Language",
  languageSystem: "System default",
  streamQuality: "Audio streaming quality",
  qualityHigh: "High (best audio)",
  qualityLow: "Data saver (low)",
  wifiOnlyDownloads: "Download over Wi-Fi only",
  clearCache: "Clear cache",
  cacheCleared: "Cache cleared successfully",
  exportBackup: "Export library backup",
  importBackup: "Import library backup",
  importBackupSuccess: "Library backup imported successfully",
  importBackupConfirm: "Importing this backup will merge playlists, liked songs, and listening history. Continue?",
  shareLogs: "Share logs",
  noLogs: "No logs found to share",
  synced: "Synced line to current playback time",
  syncLineToNow: "Sync this line to now",
  accuracyNote: "Lyrics timing may vary slightly between recordings",
  appOffline: "You are offline. Showing downloaded and cached music",
  appUpdateAvail: "Update available",
  appUpdateDownload: "Download update",
  errorTitle: "Something went wrong",
  errorBody: "An unexpected error occurred while loading this view.",
  errorReload: "Reload",
  queueEmpty: "Queue is empty",
  queueEndHint: "Autoplay will queue similar tracks when the queue runs low",
  queueAutoplay: "Autoplay similar songs",
  queueClearQuestion: "Clear the entire playback queue?",
  nowPlaying: "Now Playing",
  newPlaylist: "New playlist",
  createPlaylist: "Create playlist",
  playlistNamePlaceholder: "Playlist name",
  searchNoResultsHint: "Check your spelling or try searching for another song, artist, or album",
  searchFailed: "Search failed",
  searchFailedHint: "Could not reach the music catalog. Please check your connection and retry",
  downloadsEmptyTitle: "No downloaded songs",
  downloadsEmptyHint: "Download tracks to listen offline anytime without an internet connection",
  downloadsEmptyCta: "Find music to download",
  statsEmptyTitle: "No listening stats yet",
  statsEmptyHint: "Start playing songs to track your favorite artists, tracks, and listening habits",
  disclaimer: "Disclaimer",
  terms: "Terms of Service",
  privacy: "Privacy Policy",
  legal: "Legal & Licenses",
  aboutAttribution: "Based on Freebify by govu — https://github.com/govu/freebify",
  retry: "Retry",
  cancel: "Cancel",
  confirm: "Confirm",
  save: "Save",
  deleteAction: "Delete",
  editAction: "Edit",
  doneAction: "Done",
  removeAction: "Remove",
  playAction: "Play",
  pauseAction: "Pause",
  shuffleAction: "Shuffle",
  addTracks: "Add tracks",
  renamePlaylist: "Rename playlist",
  deletePlaylistConfirm: "Are you sure you want to delete this playlist?",
  startRadio: "Start radio",
  goToArtist: "Go to artist",
  goToAlbum: "Go to album",
  saveToLibrary: "Save to library",
  removeFromLibrary: "Remove from library",
  downloadTrack: "Download track",
  removeDownload: "Remove download",
  downloaded: "Downloaded",
  downloading: "Downloading",
  queued: "Queued",
  shareTrack: "Share track",
  sharePlaylist: "Share playlist",
  copyLink: "Copy link",
  linkCopied: "Link copied to clipboard",
  noLyrics: "No lyrics available for this song",
  matchingProgress: "Matching {matched} of {total} tracks…",
  importPlaylistTitle: "Import playlist",
  importUrlHint: "Paste Spotify or YouTube Music playlist link",
  importFileButton: "Choose CSV or .freebify.json file",
  allFilter: "All",
  songsFilter: "Songs",
  artistsFilter: "Artists",
  playlistsFilter: "Playlists & albums",
  topResult: "Top result",
  moreTracks: "More songs",
  popularTracks: "Popular",
  discography: "Discography",
  albumsSection: "Albums",
  singlesSection: "Singles & EPs",
  aboutArtist: "About",
  monthlyListenersCount: "{n} monthly listeners",
  followersCount: "{n} followers",
  trackCountLabel: "{n} tracks",
  listeningTime: "Listening time",
  totalPlays: "Total plays",
  tracksPlayed: "Tracks played",
  artistsHeard: "Artists heard",
  thisWeek: "This week",
  topTracks: "Top tracks",
  topArtists: "Top artists",
  rewindAction: "Watch Rewind",
  equalizerTitle: "Equalizer",
  eqPresetFlat: "Flat",
  eqPresetBass: "Bass boost",
  eqPresetBright: "Bright",
  eqPresetVocal: "Vocal boost",
  eqPresetVshape: "V-Shape",
  eqPresetCustom: "Custom",
  eqNormalize: "Normalize volume",
  eqCrossfade: "Crossfade",
  sleepTimerTitle: "Sleep timer",
  sleepTimerOff: "Off",
  sleepTimer5: "5 minutes",
  sleepTimer15: "15 minutes",
  sleepTimer30: "30 minutes",
  sleepTimer45: "45 minutes",
  sleepTimer60: "60 minutes",
  sleepTimerTrackEnd: "End of current track"
};

const mobileKeysEs = {
  themeMode: "Tema",
  themeSystem: "Predeterminado del sistema",
  themeLight: "Claro",
  themeDark: "Oscuro",
  reduceTransparency: "Reducir transparencia",
  reduceTransparencySubtitle: "Usar superficies sólidas en lugar de efectos translúcidos de desenfoque",
  language: "Idioma",
  languageSystem: "Predeterminado del sistema",
  streamQuality: "Calidad de transmisión de audio",
  qualityHigh: "Alta (mejor audio)",
  qualityLow: "Ahorro de datos (baja)",
  wifiOnlyDownloads: "Descargar solo por Wi-Fi",
  clearCache: "Borrar caché",
  cacheCleared: "Caché borrada con éxito",
  exportBackup: "Exportar copia de seguridad",
  importBackup: "Importar copia de seguridad",
  importBackupSuccess: "Copia de seguridad importada con éxito",
  importBackupConfirm: "Importar esta copia combinará listas, canciones favoritas e historial. ¿Continuar?",
  shareLogs: "Compartir registros",
  noLogs: "No se encontraron registros para compartir",
  synced: "Línea sincronizada con el momento actual",
  syncLineToNow: "Sincronizar esta línea con ahora",
  accuracyNote: "La sincronización de la letra puede variar según la grabación",
  appOffline: "Estás desconectado. Mostrando música descargada y en caché",
  appUpdateAvail: "Actualización disponible",
  appUpdateDownload: "Descargar actualización",
  errorTitle: "Algo salió mal",
  errorBody: "Ocurrió un error inesperado al cargar esta vista.",
  errorReload: "Recargar",
  queueEmpty: "La cola está vacía",
  queueEndHint: "La reproducción automática añadirá canciones similares cuando la cola se agote",
  queueAutoplay: "Reproducción automática de canciones similares",
  queueClearQuestion: "¿Vaciar toda la cola de reproducción?",
  nowPlaying: "Reproduciendo ahora",
  newPlaylist: "Nueva lista de reproducción",
  createPlaylist: "Crear lista de reproducción",
  playlistNamePlaceholder: "Nombre de la lista",
  searchNoResultsHint: "Comprueba la ortografía o intenta buscar otra canción, artista o álbum",
  searchFailed: "Error en la búsqueda",
  searchFailedHint: "No se pudo conectar con el catálogo de música. Comprueba tu conexión e intenta de nuevo",
  downloadsEmptyTitle: "No hay canciones descargadas",
  downloadsEmptyHint: "Descarga pistas para escuchar sin conexión en cualquier momento",
  downloadsEmptyCta: "Buscar música para descargar",
  statsEmptyTitle: "Aún no hay estadísticas",
  statsEmptyHint: "Comienza a reproducir canciones para ver aquí tus hábitos y tendencias de escucha",
  disclaimer: "Descargo de responsabilidad",
  terms: "Términos del servicio",
  privacy: "Política de privacidad",
  legal: "Avisos legales y licencias",
  aboutAttribution: "Basado en Freebify por govu — https://github.com/govu/freebify",
  retry: "Reintentar",
  cancel: "Cancelar",
  confirm: "Confirmar",
  save: "Guardar",
  deleteAction: "Eliminar",
  editAction: "Editar",
  doneAction: "Listo",
  removeAction: "Quitar",
  playAction: "Reproducir",
  pauseAction: "Pausar",
  shuffleAction: "Aleatorio",
  addTracks: "Añadir canciones",
  renamePlaylist: "Renombrar lista",
  deletePlaylistConfirm: "¿Seguro que quieres eliminar esta lista de reproducción?",
  startRadio: "Iniciar radio",
  goToArtist: "Ir al artista",
  goToAlbum: "Ir al álbum",
  saveToLibrary: "Guardar en tu biblioteca",
  removeFromLibrary: "Quitar de tu biblioteca",
  downloadTrack: "Descargar canción",
  removeDownload: "Eliminar descarga",
  downloaded: "Descargado",
  downloading: "Descargando",
  queued: "En cola",
  shareTrack: "Compartir canción",
  sharePlaylist: "Compartir lista",
  copyLink: "Copiar enlace",
  linkCopied: "Enlace copiado al portapapeles",
  noLyrics: "No hay letras disponibles para esta canción",
  matchingProgress: "Coincidiendo {matched} de {total} canciones…",
  importPlaylistTitle: "Importar lista de reproducción",
  importUrlHint: "Pega el enlace de Spotify o YouTube Music",
  importFileButton: "Elegir archivo CSV o .freebify.json",
  allFilter: "Todo",
  songsFilter: "Canciones",
  artistsFilter: "Artistas",
  playlistsFilter: "Listas y álbumes",
  topResult: "Resultado principal",
  moreTracks: "Más canciones",
  popularTracks: "Populares",
  discography: "Discografía",
  albumsSection: "Álbumes",
  singlesSection: "Sencillos y EPs",
  aboutArtist: "Información",
  monthlyListenersCount: "{n} oyentes mensuales",
  followersCount: "{n} seguidores",
  trackCountLabel: "{n} canciones",
  listeningTime: "Tiempo de escucha",
  totalPlays: "Reproducciones totales",
  tracksPlayed: "Canciones reproducidas",
  artistsHeard: "Artistas escuchados",
  thisWeek: "Esta semana",
  topTracks: "Canciones más escuchadas",
  topArtists: "Artistas principales",
  rewindAction: "Ver Rewind",
  equalizerTitle: "Ecualizador",
  eqPresetFlat: "Plano",
  eqPresetBass: "Realce de graves",
  eqPresetBright: "Brillante",
  eqPresetVocal: "Realce vocal",
  eqPresetVshape: "En V",
  eqPresetCustom: "Personalizado",
  eqNormalize: "Normalizar volumen",
  eqCrossfade: "Fundido cruzado",
  sleepTimerTitle: "Temporizador de apagado",
  sleepTimerOff: "Desactivado",
  sleepTimer5: "5 minutos",
  sleepTimer15: "15 minutos",
  sleepTimer30: "30 minutos",
  sleepTimer45: "45 minutos",
  sleepTimer60: "60 minutos",
  sleepTimerTrackEnd: "Al final de la canción actual"
};

// Arabic translations dictionary mapping English strings / keys
const arabicDict = {
  // Common terms
  "Good morning": "صباح الخير",
  "Good afternoon": "مساء الخير",
  "Good evening": "مساء الخير",
  "Late night listening": "استماع في وقت متأخر",
  "Home": "الرئيسية",
  "Search": "بحث",
  "Your library": "مكتبتك",
  "Your stats": "إحصائياتك",
  "Stats": "الإحصائيات",
  "Settings": "الإعدادات",
  "Now Playing": "قيد التشغيل الآن",
  "Queue": "قائمة الانتظار",
  "Lyrics": "كلمات الأغاني",
  "Trending this week": "الأكثر رواجاً هذا الأسبوع",
  "Top songs": "أفضل الأغاني",
  "Top songs this week": "أفضل الأغاني هذا الأسبوع",
  "Charts": "قوائم الصدارة",
  "Chart": "قائمة الصدارة",
  "New releases": "إصدارات جديدة",
  "Hot playlists": "أشهر قوائم التشغيل",
  "Top artists": "أبرز الفنانين",
  "New for you": "جديد لك",
  "Browse genres": "تصفح الأنواع",
  "Moods & moments": "حالات وأجواء",
  "Liked songs": "الأغاني المعجب بها",
  "Downloads": "التنزيلات",
  "Recently played": "تم تشغيله مؤخراً",
  "Playlists": "قوائم التشغيل",
  "Artists": "الفنانون",
  "Albums": "الألبومات",
  "Songs": "الأغاني",
  "All": "الكل",
  "Play": "تشغيل",
  "Pause": "إيقاف مؤقت",
  "Shuffle": "تشغيل عشوائي",
  "Repeat": "تكرار",
  "Next": "التالي",
  "Previous": "السابق",
  "Clear": "مسح",
  "Done": "تم",
  "Cancel": "إلغاء",
  "Delete": "حذف",
  "Rename": "إعادة تسمية",
  "Save": "حفظ",
  "Edit": "تعديل",
  "Retry": "إعادة المحاولة",
  "Confirm": "تأكيد",
  "Close": "إغلاق",
  "Back": "رجوع",
  "Add to playlist": "إضافة إلى قائمة تشغيل",
  "Add to queue": "إضافة إلى قائمة الانتظار",
  "Play next": "تشغيل تالياً",
  "Start radio": "بدء الراديو",
  "Go to artist": "الانتقال إلى الفنان",
  "Go to album": "الانتقال إلى الألبوم",
  "Save to Library": "حفظ في المكتبة",
  "Remove from Library": "إزالة من المكتبة",
  "Download": "تنزيل",
  "Remove download": "إزالة التنزيل",
  "Share": "مشاركة",
  "Copy link": "نسخ الرابط",
  "Follow": "متابعة",
  "Following": "مُتابَع",
  "Offline": "غير متصل بالإنترنت"
};

// Build Arabic value from English key & text
function translateToArabic(key, enVal) {
  // Handle mobile keys
  if (mobileKeysAr[key]) return mobileKeysAr[key];

  // Specific key patterns
  if (key.startsWith("homeGreetingMorning")) return "صباح الخير";
  if (key.startsWith("homeGreetingAfternoon")) return "مساء الخير";
  if (key.startsWith("homeGreetingEvening")) return "مساء الخير";
  if (key.startsWith("homeGreetingLate")) return "استماع في وقت متأخر";
  if (key.startsWith("homeRewindReady")) return "ملخص {label} الخاص بك جاهز";
  if (key.startsWith("homeRewindPartialReady")) return "ملخص {label} حتى الآن جاهز";
  if (key.startsWith("homeRewindWatch")) return "مشاهدة الملخص";
  if (key.startsWith("homeBecauseListened")) return "لأنك استمعت إلى {name}";
  if (key.startsWith("homeMoodMixes")) return "ميكسات {name}";

  if (key === "searchPlaceholder") return "ما الذي تريد الاستماع إليه؟";
  if (key === "searchClear") return "مسح البحث";
  if (key === "searchRecent") return "عمليات البحث الأخيرة";
  if (key === "searchNoResults") return "لا توجد نتائج لـ “{q}”";
  if (key === "searchFailed") return "فشل البحث";
  if (key === "searchFailedHint") return "تعذر الاتصال بقائمة الموسيقى. يرجى إعادة المحاولة";

  if (key.startsWith("artistMonthlyListeners")) return "{n} مستمع شهرياً";
  if (key.startsWith("artistFollowers")) return "{n} متابع";
  if (key.startsWith("artistFollow")) return "متابعة";
  if (key.startsWith("artistFollowing")) return "مُتابَع";
  if (key.startsWith("artistPopular")) return "الأكثر شعبية";
  if (key.startsWith("artistAlbums")) return "الألبومات";
  if (key.startsWith("artistSingles")) return "الأغاني الفردية";
  if (key.startsWith("artistAbout")) return "نبذة عن الفنان";
  if (key.startsWith("artistVerified")) return "فنان موثق";

  if (key.startsWith("playlistTrackCount") || key.startsWith("cardTracks") || key.startsWith("sideTracks") || key.startsWith("libraryTrackCount")) return "{n} مقطع صوتي";
  if (key.startsWith("cardFollowers")) return "{n} متابع";
  if (key.startsWith("cardPlays")) return "{n} استماع";

  if (key.startsWith("statsSubtitle")) return "ملخص نشاطك وعادات الاستماع الخاصة بك";
  if (key.startsWith("statsListeningTime")) return "وقت الاستماع";
  if (key.startsWith("statsTotalPlays")) return "إجمالي مرات التشغيل";
  if (key.startsWith("statsTracksPlayed")) return "الأغاني المستمع إليها";
  if (key.startsWith("statsArtistsHeard")) return "الفنانون المستمع إليهم";
  if (key.startsWith("statsWeekTotal")) return "{t} هذا الأسبوع";
  if (key.startsWith("statsTopTracks")) return "أفضل الأغاني";
  if (key.startsWith("statsTopArtists")) return "أفضل الفنانين";

  if (key.startsWith("rewindTitle")) return "ملخص {month}";
  if (key.startsWith("rewindDurHm")) return "{h} س {m} د";
  if (key.startsWith("rewindDurM")) return "{m} د";
  if (key.startsWith("rewindChipArtists")) return "{n} فنان";
  if (key.startsWith("rewindChipPlays")) return "{n} تشغيل";
  if (key.startsWith("rewindChipTotal")) return "{time} إجمالي";
  if (key.startsWith("rewindChipTracks")) return "{n} أغنية";

  if (key.startsWith("queueNowPlaying")) return "قيد التشغيل الآن";
  if (key.startsWith("queueNextUp")) return "التالي في قائمة الانتظار";
  if (key.startsWith("queueAutoplay")) return "تشغيل تلقائي لموسيقى مشابهة";
  if (key.startsWith("queueClear")) return "مسح قائمة الانتظار";
  if (key.startsWith("queueSaveAsPlaylist")) return "حفظ قائمة الانتظار كقائمة تشغيل";

  if (key.startsWith("coreNoConnection")) return "تعذر التشغيل. تحقق من اتصالك وحاول مرة أخرى";
  if (key.startsWith("coreNothingPlayable")) return "لا يوجد محتوى قابل للتشغيل في هذه القائمة";
  if (key.startsWith("coreUnavailable")) return "هذا المقطع غير متوفر للبث";
  if (key.startsWith("coreQueueFull")) return "قائمة الانتظار ممتلئة";
  if (key.startsWith("coreAddedQueue")) return "تمت الإضافة إلى قائمة الانتظار";
  if (key.startsWith("corePlayNext")) return "سيتم التشغيل تالياً";
  if (key.startsWith("coreRadioStarted")) return "تم بدء الراديو وإضافة أغانٍ مشابهة";
  if (key.startsWith("coreSleepPaused")) return "مؤقت النوم: تم إيقاف التشغيل مؤقتاً";

  if (key.startsWith("downloadsSubtitle")) return "{n} مقطع صوتي، مخزنة على هذا الجهاز وقابلة للتشغيل بدون إنترنت";
  if (key.startsWith("downloadsPlayAll")) return "تشغيل الكل";

  // Check dictionary
  if (arabicDict[enVal]) return arabicDict[enVal];

  // Fallback translation rules based on text content
  return defaultArabicTranslate(enVal);
}

const mobileKeysAr = {
  themeMode: "المظهر",
  themeSystem: "الافتراضي للنظام",
  themeLight: "فاتح",
  themeDark: "داكن",
  reduceTransparency: "تقليل الشفافية",
  reduceTransparencySubtitle: "استخدام خلفيات صلبة بدلاً من تأثيرات التمويه والشفافية",
  language: "اللغة",
  languageSystem: "الافتراضي للنظام",
  streamQuality: "جودة بث الصوت",
  qualityHigh: "عالية (أفضل صوت)",
  qualityLow: "توفير البيانات (منخفضة)",
  wifiOnlyDownloads: "التنزيل عبر شبكة Wi-Fi فقط",
  clearCache: "مسح التخزين المؤقت",
  cacheCleared: "تم مسح الذاكرة المؤقتة بنجاح",
  exportBackup: "تصدير نسخة احتياطية للمكتبة",
  importBackup: "استيراد نسخة احتياطية للمكتبة",
  importBackupSuccess: "تم استيراد النسخة الاحتياطية بنجاح",
  importBackupConfirm: "سيؤدي استيراد هذه النسخة إلى دمج قوائم التشغيل والإعجابات وسجل الاستماع. هل تريد المتابعة؟",
  shareLogs: "مشاركة السجلات",
  noLogs: "لا توجد سجلات للمشاركة",
  synced: "تمت مزامنة هذا السطر مع وقت التشغيل الحالي",
  syncLineToNow: "مزامنة هذا السطر مع الوقت الحالي",
  accuracyNote: "قد يختلف توقيت الكلمات قليلاً بحسب التسجيل الصوتي",
  appOffline: "أنت غير متصل بالإنترنت. يتم عرض الموسيقى المنزلة والمحفوظة مؤقتاً",
  appUpdateAvail: "يتوفر تحديث جديد",
  appUpdateDownload: "تنزيل التحديث",
  errorTitle: "حدث خطأ ما",
  errorBody: "حدث خطأ غير متوقع أثناء تحميل هذه الصفحة.",
  errorReload: "إعادة التحميل",
  queueEmpty: "قائمة الانتظار فارغة",
  queueEndHint: "سيقوم التشغيل التلقائي بإضافة أغانٍ مشابهة عند اقتراب انتهاء القائمة",
  queueAutoplay: "تشغيل تلقائي لأغانٍ مشابهة",
  queueClearQuestion: "هل تريد مسح كامل قائمة الانتظار؟",
  nowPlaying: "قيد التشغيل الآن",
  newPlaylist: "قائمة تشغيل جديدة",
  createPlaylist: "إنشاء قائمة تشغيل",
  playlistNamePlaceholder: "اسم قائمة التشغيل",
  searchNoResultsHint: "تحقق من صحة الكلمات أو جرب البحث عن أغنية أو فنان أو ألبوم آخر",
  searchFailed: "فشل البحث",
  searchFailedHint: "تعذر الاتصال بكتالوج الموسيقى. يرجى التحقق من اتصالك وإعادة المحاولة",
  downloadsEmptyTitle: "لا توجد أغانٍ منزلة بعد",
  downloadsEmptyHint: "قم بتنزيل المقاطع للاستماع إليها بدون اتصال بالإنترنت في أي وقت",
  downloadsEmptyCta: "البحث عن موسيقى لتنزيلها",
  statsEmptyTitle: "لا توجد إحصائيات استماع حتى الآن",
  statsEmptyHint: "ابدأ بتشغيل الأغاني لتتبع فنانيك المفضلين وعادات الاستماع الخاصة بك هنا",
  disclaimer: "إخلاء المسؤولية",
  terms: "شروط الخدمة",
  privacy: "سياسة الخصوصية",
  legal: "إشعارات قانونية وتراخيص",
  aboutAttribution: "مبني على تطبيق Freebify بواسطة govu — https://github.com/govu/freebify",
  retry: "إعادة المحاولة",
  cancel: "إلغاء",
  confirm: "تأكيد",
  save: "حفظ",
  deleteAction: "حذف",
  editAction: "تعديل",
  doneAction: "تم",
  removeAction: "إزالة",
  playAction: "تشغيل",
  pauseAction: "إيقاف مؤقت",
  shuffleAction: "تشغيل عشوائي",
  addTracks: "إضافة أغانٍ",
  renamePlaylist: "إعادة تسمية قائمة التشغيل",
  deletePlaylistConfirm: "هل أنت متأكد من رغبتك في حذف قائمة التشغيل هذه؟",
  startRadio: "بدء الراديو",
  goToArtist: "الانتقال إلى الفنان",
  goToAlbum: "الانتقال إلى الألبوم",
  saveToLibrary: "حفظ في المكتبة",
  removeFromLibrary: "إزالة من المكتبة",
  downloadTrack: "تنزيل المقطع الصوتي",
  removeDownload: "إزالة التنزيل",
  downloaded: "تم التنزيل",
  downloading: "جارٍ التنزيل",
  queued: "في الانتظار",
  shareTrack: "مشاركة المقطع",
  sharePlaylist: "مشاركة قائمة التشغيل",
  copyLink: "نسخ الرابط",
  linkCopied: "تم نسخ الرابط إلى الحافظة",
  noLyrics: "لا تتوفر كلمات لهذه الأغنية",
  matchingProgress: "جارٍ مطابقة {matched} من {total} أغنية…",
  importPlaylistTitle: "استيراد قائمة تشغيل",
  importUrlHint: "الصق رابط قائمة تشغيل من Spotify أو YouTube Music",
  importFileButton: "اختيار ملف CSV أو .freebify.json",
  allFilter: "الكل",
  songsFilter: "الأغاني",
  artistsFilter: "الفنانون",
  playlistsFilter: "القوائم والألبومات",
  topResult: "النتيجة الأولى",
  moreTracks: "المزيد من الأغاني",
  popularTracks: "الأكثر شعبية",
  discography: "الأعمال الغنائية",
  albumsSection: "الألبومات",
  singlesSection: "الأغاني الفردية والقصيرة",
  aboutArtist: "نبذة عن الفنان",
  monthlyListenersCount: "{n} مستمع شهرياً",
  followersCount: "{n} متابع",
  trackCountLabel: "{n} مقطع صوتي",
  listeningTime: "وقت الاستماع",
  totalPlays: "إجمالي مرات التشغيل",
  tracksPlayed: "المقاطع المستمع إليها",
  artistsHeard: "الفنانون المستمع إليهم",
  thisWeek: "هذا الأسبوع",
  topTracks: "أفضل الأغاني",
  topArtists: "أبرز الفنانين",
  rewindAction: "مشاهدة الملخص",
  equalizerTitle: "المعادل الصوتي",
  eqPresetFlat: "متوازن",
  eqPresetBass: "تعزيز الباس",
  eqPresetBright: "صوت نقي",
  eqPresetVocal: "تعزيز الصوت البشري",
  eqPresetVshape: "منحنى V",
  eqPresetCustom: "مخصص",
  eqNormalize: "موازنة مستوى الصوت",
  eqCrossfade: "التلاشي المتقاطع",
  sleepTimerTitle: "مؤقت النوم",
  sleepTimerOff: "إيقاف",
  sleepTimer5: "5 دقائق",
  sleepTimer15: "15 دقيقة",
  sleepTimer30: "30 دقيقة",
  sleepTimer45: "45 دقيقة",
  sleepTimer60: "60 دقيقة",
  sleepTimerTrackEnd: "عند نهاية المقطع الحالي"
};

function defaultArabicTranslate(text) {
  // Common phrase replacements for automated fallback
  let t = text;
  t = t.replace(/Delete/g, "حذف");
  t = t.replace(/Remove/g, "إزالة");
  t = t.replace(/Cancel/g, "إلغاء");
  t = t.replace(/Save/g, "حفظ");
  t = t.replace(/Done/g, "تم");
  t = t.replace(/Edit/g, "تعديل");
  t = t.replace(/Play/g, "تشغيل");
  t = t.replace(/Pause/g, "إيقاف مؤقت");
  t = t.replace(/Loading…/g, "جارٍ التحميل…");
  t = t.replace(/Downloading…/g, "جارٍ التنزيل…");
  t = t.replace(/Import/g, "استيراد");
  t = t.replace(/Export/g, "تصدير");
  t = t.replace(/Library/g, "المكتبة");
  t = t.replace(/Playlists/g, "قوائم التشغيل");
  t = t.replace(/Playlist/g, "قائمة التشغيل");
  t = t.replace(/Artists/g, "الفنانون");
  t = t.replace(/Artist/g, "الفنان");
  t = t.replace(/Songs/g, "الأغاني");
  t = t.replace(/Song/g, "الأغنية");
  t = t.replace(/Tracks/g, "المقاطع");
  t = t.replace(/Track/g, "المقطع");
  t = t.replace(/Albums/g, "الألبومات");
  t = t.replace(/Album/g, "الألبوم");
  t = t.replace(/Settings/g, "الإعدادات");
  t = t.replace(/Search/g, "بحث");
  return t;
}

// Build all keys
const allEn = {};
const allEs = {};
const allAr = {};

// Add upstream keys
for (const [key, val] of Object.entries(en)) {
  const camel = toCamelCase(key);
  allEn[camel] = { val: val, orig: key };
  allEs[camel] = { val: es[key] || val, orig: key };
  allAr[camel] = { val: translateToArabic(camel, val), orig: key };
}

// Add mobile keys
for (const [camel, val] of Object.entries(mobileKeysEn)) {
  allEn[camel] = { val: val, orig: camel };
  allEs[camel] = { val: mobileKeysEs[camel] || val, orig: camel };
  allAr[camel] = { val: mobileKeysAr[camel] || translateToArabic(camel, val), orig: camel };
}

// Generate ARB objects
const arbEn = { "@@locale": "en" };
const arbEs = { "@@locale": "es" };
const arbAr = { "@@locale": "ar" };

for (const [camel, item] of Object.entries(allEn)) {
  arbEn[camel] = item.val;
  arbEs[camel] = allEs[camel].val;
  arbAr[camel] = allAr[camel].val;

  // Metadata for en
  const vars = (item.val.match(/\{(\w+)\}/g) || []).map(v => v.replace(/[{}]/g, ''));
  const meta = {
    description: `original key: ${item.orig}`
  };

  if (vars.length > 0) {
    meta.placeholders = {};
    for (const v of vars) {
      meta.placeholders[v] = { type: "String" };
    }
  }

  arbEn[`@${camel}`] = meta;
}

// Ensure all placeholders in en exist in es and ar (must match exact names)
for (const [camel, item] of Object.entries(allEn)) {
  const vars = (item.val.match(/\{(\w+)\}/g) || []);
  for (const v of vars) {
    if (!arbEs[camel].includes(v)) {
      console.warn(`Missing var ${v} in ES for ${camel}: en="${item.val}", es="${arbEs[camel]}"`);
      arbEs[camel] = item.val; // fallback to en if placeholder missing
    }
    if (!arbAr[camel].includes(v)) {
      // Auto-insert placeholder if missing in Arabic
      arbAr[camel] = arbAr[camel] + " " + v;
    }
  }
}

fs.writeFileSync('lib/core/l10n/app_en.arb', JSON.stringify(arbEn, null, 2));
fs.writeFileSync('lib/core/l10n/app_es.arb', JSON.stringify(arbEs, null, 2));
fs.writeFileSync('lib/core/l10n/app_ar.arb', JSON.stringify(arbAr, null, 2));

console.log(`Generated ARB files with ${Object.keys(allEn).length} keys each.`);
