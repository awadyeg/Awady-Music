// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class L10nEs extends L10n {
  L10nEs([String locale = 'es']) : super(locale);

  @override
  String get appDismissUpdate => 'Descartar';

  @override
  String get appDownload => 'Descargar';

  @override
  String get appOffline =>
      'Estás desconectado. Mostrando música descargada y en caché';

  @override
  String get appRestart => 'Reiniciar';

  @override
  String get appUpdateAvail => 'Actualización disponible';

  @override
  String get appUpdateManualHint => 'Descarga el nuevo dmg';

  @override
  String appUpdateReady(String version) {
    return 'v$version lista';
  }

  @override
  String get appUpdateRestartHint => 'Reinicia para actualizar';

  @override
  String get cardAlbum => 'Álbum';

  @override
  String get cardArtist => 'Artista';

  @override
  String cardFollowers(String n) {
    return '$n seguidores';
  }

  @override
  String get cardOpen => 'Abrir';

  @override
  String get cardPlay => 'Reproducir';

  @override
  String get cardPlaylist => 'Playlist';

  @override
  String cardPlays(String n) {
    return '$n reproducciones';
  }

  @override
  String get cardScrollLeft => 'Desplazar a la izquierda';

  @override
  String get cardScrollRight => 'Desplazar a la derecha';

  @override
  String cardTracks(String n) {
    return '$n canciones';
  }

  @override
  String get eqCrossfade => 'Fundido cruzado';

  @override
  String get eqDrive => 'Saturación';

  @override
  String get eqEcho => 'Eco';

  @override
  String get eqEnhance => 'Mejorar';

  @override
  String get eqReverb => 'Reverb';

  @override
  String get eqSpace => 'Espacio';

  @override
  String get eqCrossfadeSeconds => 'Segundos de fundido';

  @override
  String get eqCustom => 'Personalizado';

  @override
  String get eqNormalize => 'Normalizar volumen';

  @override
  String get eqOff => 'apagado';

  @override
  String get eqPresetBass => 'Realce de graves';

  @override
  String get eqPresetBright => 'Brillante';

  @override
  String get eqPresetFlat => 'Plano';

  @override
  String get eqPresetVocal => 'Realce vocal';

  @override
  String get eqPresetVshape => 'En V';

  @override
  String get eqResetAria => 'Restablecer ecualizador';

  @override
  String get eqResetTitle => 'Volver a plano';

  @override
  String eqSleepIn(String n) {
    return 'en $n min';
  }

  @override
  String get eqSleepOff => 'Apagado';

  @override
  String get eqSleepTimer => 'Temporizador';

  @override
  String get eqTitle => 'Ecualizador';

  @override
  String get navHome => 'Inicio';

  @override
  String get navHomeAria => 'Inicio de Freebify';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navSearch => 'Buscar';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get navStats => 'Estadísticas';

  @override
  String get playerCancelLoading => 'Cancelar carga';

  @override
  String get playerLike => 'Guardar en Canciones favoritas';

  @override
  String get playerMute => 'Silenciar';

  @override
  String get playerNext => 'Siguiente';

  @override
  String get playerNowPlaying => 'Sonando ahora';

  @override
  String get playerOpenNowPlaying => 'Abrir Sonando ahora';

  @override
  String get playerPause => 'Pausar';

  @override
  String get playerPick => 'Elige algo para reproducir';

  @override
  String get playerPlay => 'Reproducir';

  @override
  String get playerPrev => 'Anterior';

  @override
  String get playerQueue => 'Cola';

  @override
  String get playerRepeatAll => 'Repetir: todas';

  @override
  String get playerRepeatOff => 'Repetir: no';

  @override
  String get playerRepeatOne => 'Repetir: una';

  @override
  String get playerSeek => 'Progreso';

  @override
  String get playerShuffle => 'Aleatorio';

  @override
  String get playerUnlike => 'Quitar de Canciones favoritas';

  @override
  String get playerUnmute => 'Activar sonido';

  @override
  String get playerVolume => 'Volumen';

  @override
  String get queueAutoplay => 'Reproducción automática de canciones similares';

  @override
  String get queueClear => 'Vaciar cola';

  @override
  String get queueClearConfirmAria => 'Confirmar: vaciar cola';

  @override
  String get queueClearConfirmTitle => 'Haz clic de nuevo para vaciar la cola';

  @override
  String get queueClearQuestion => '¿Vaciar toda la cola de reproducción?';

  @override
  String get queueClose => 'Cerrar cola';

  @override
  String get queueEmpty => 'La cola está vacía';

  @override
  String get queueEndHint =>
      'La reproducción automática añadirá canciones similares cuando la cola se agote';

  @override
  String get queueNextUp => 'A continuación';

  @override
  String get queueNowPlaying => 'Sonando ahora';

  @override
  String get queueRadio => 'Iniciar radio desde esta canción';

  @override
  String queueRemoveTrack(String title) {
    return 'Quitar $title de la cola';
  }

  @override
  String get queueSaveAs => 'Guardar cola como playlist';

  @override
  String get queueSavedAsPlaylist => 'Cola guardada como playlist';

  @override
  String get queueTitle => 'Cola';

  @override
  String get sideDownloads => 'Descargas';

  @override
  String get sideLiked => 'Canciones favoritas';

  @override
  String sideMorePlaylists(String n) {
    return '+$n más, ver todas';
  }

  @override
  String get sideRecentlyPlayed => 'Reproducido recientemente';

  @override
  String sideTracks(String n) {
    return '$n canciones';
  }

  @override
  String get sideYourLibrary => 'Tu biblioteca';

  @override
  String get tableAddPlaylist => 'Añadir a playlist';

  @override
  String get tableAddQueue => 'Añadir a la cola';

  @override
  String get tableAddedNewPlaylist => 'Añadida a nueva playlist';

  @override
  String tableAddedToPlaylist(String name) {
    return 'Añadida a \\\"$name\\\"';
  }

  @override
  String get tableBadgeEdit => 'Edit';

  @override
  String get tableBadgeSet => 'Set';

  @override
  String get tableColArtist => 'Artista';

  @override
  String get tableColPlays => 'Reproducciones';

  @override
  String get tableColTime => 'Duración';

  @override
  String get tableColTitle => 'Título';

  @override
  String get tableCopied => 'Copiado';

  @override
  String get tableCopyLink => 'Copiar enlace';

  @override
  String get tableDownload => 'Descargar';

  @override
  String tableDownloading(String pct) {
    return 'Descargando… $pct%';
  }

  @override
  String get tableEmpty => 'Nada por aquí todavía.';

  @override
  String get tableGoAlbum => 'Ir al álbum';

  @override
  String get tableGoArtist => 'Ir al artista';

  @override
  String get tableLike => 'Guardar en Canciones favoritas';

  @override
  String get tableLinkCopied => 'Enlace copiado';

  @override
  String get tableMore => 'Más opciones';

  @override
  String get tableNewPlaylist => 'Nueva playlist';

  @override
  String get tablePlayNext => 'Reproducir después';

  @override
  String tablePlayTrack(String title) {
    return 'Reproducir $title';
  }

  @override
  String get tableRadioFail => 'No se pudo iniciar la radio de esta canción';

  @override
  String get tableRemoveDownload => 'Eliminar descarga';

  @override
  String get tableRemoveFrom => 'Quitar de la playlist';

  @override
  String tableRemovedFromPlaylist(String name) {
    return 'Quitada de \\\"$name\\\"';
  }

  @override
  String get tableStartRadio => 'Iniciar radio';

  @override
  String get tableUnlike => 'Quitar de Canciones favoritas';

  @override
  String get topBack => 'Atrás';

  @override
  String get topForward => 'Adelante';

  @override
  String get winClose => 'Cerrar';

  @override
  String get winCloseToTray => 'Cerrar a la bandeja';

  @override
  String get winMaximize => 'Maximizar';

  @override
  String get winMinimize => 'Minimizar';

  @override
  String get winRestore => 'Restaurar';

  @override
  String get coreNoConnection =>
      'No se pudo reproducir. Revisa tu conexión e inténtalo de nuevo';

  @override
  String get coreNothingPlayable => 'No hay nada reproducible en esta lista';

  @override
  String get coreUnavailable => 'Esa canción no está disponible para streaming';

  @override
  String get coreQueueFull => 'La cola está llena';

  @override
  String get coreAddedQueue => 'Añadida a la cola';

  @override
  String get corePlayNext => 'Sonará después';

  @override
  String get coreRadioStarted => 'Radio iniciada. Canciones similares en cola';

  @override
  String get coreSleepPaused => 'Temporizador: reproducción pausada';

  @override
  String get errorBody => 'Ocurrió un error inesperado al cargar esta vista.';

  @override
  String get errorReload => 'Recargar';

  @override
  String get errorTitle => 'Algo salió mal';

  @override
  String get npAccuracyNote =>
      'La letra puede no ser exacta en algunas canciones';

  @override
  String get npClose => 'Cerrar';

  @override
  String get npLike => 'Guardar en Me gusta';

  @override
  String get npLineHint =>
      'Clic para saltar · Shift+clic para fijar esta línea al instante';

  @override
  String get npLyrics => 'Letra';

  @override
  String get npMute => 'Silenciar';

  @override
  String get npNext => 'Siguiente';

  @override
  String get npNoLyrics => 'No se encontró la letra de esta canción.';

  @override
  String get npPause => 'Pausar';

  @override
  String get npPlay => 'Reproducir';

  @override
  String get npPrev => 'Anterior';

  @override
  String get npQueue => 'Cola';

  @override
  String get npRepeatAll => 'Repetir: todas';

  @override
  String get npRepeatOff => 'Repetir: desactivado';

  @override
  String get npRepeatOne => 'Repetir: una canción';

  @override
  String get npSeek => 'Posición';

  @override
  String get npShuffle => 'Aleatorio';

  @override
  String get npTitle => 'Sonando ahora';

  @override
  String get npUnlike => 'Quitar de Me gusta';

  @override
  String get npUnmute => 'Quitar silencio';

  @override
  String get npVolume => 'Volumen';

  @override
  String rewindArtistStats(String plays, String time) {
    return '$plays reproducciones · $time este mes';
  }

  @override
  String rewindChipArtists(String n) {
    return '$n artistas';
  }

  @override
  String rewindChipPlays(String n) {
    return '$n reproducciones';
  }

  @override
  String rewindChipTotal(String time) {
    return '$time en total';
  }

  @override
  String rewindChipTracks(String n) {
    return '$n canciones';
  }

  @override
  String get rewindClose => 'Cerrar rewind';

  @override
  String rewindDurHm(String h, String m) {
    return '$h h $m min';
  }

  @override
  String rewindDurM(String m) {
    return '$m min';
  }

  @override
  String get rewindIntroLine =>
      'Un mes tuyo: cada reproducción, contada en este dispositivo.';

  @override
  String get rewindIntroLinePartial =>
      'Tu mes hasta ahora: cada reproducción, contada en este dispositivo.';

  @override
  String get rewindIntroTag => 'Freebify · mensual';

  @override
  String get rewindIntroTagPartial => 'Freebify · aún contando';

  @override
  String get rewindKeepListening => 'Seguir escuchando';

  @override
  String get rewindListenedFor => 'escuchaste';

  @override
  String get rewindMin => 'min';

  @override
  String get rewindNext => 'Siguiente';

  @override
  String get rewindNextSlide => 'Diapositiva siguiente';

  @override
  String get rewindOnRepeat => 'en bucle';

  @override
  String get rewindPlayAgain => 'Escuchar de nuevo';

  @override
  String get rewindPlayTop => 'Escuchar las más escuchadas';

  @override
  String rewindPlaysAcross(String time, String plays, String tracks) {
    return '$time · $plays reproducciones en $tracks canciones';
  }

  @override
  String get rewindPrev => 'Anterior';

  @override
  String get rewindPrevSlide => 'Diapositiva anterior';

  @override
  String get rewindThatWas => 'eso fue';

  @override
  String rewindTitle(String month) {
    return 'Rewind de $month';
  }

  @override
  String get rewindTopArtist => 'tu artista n.º 1';

  @override
  String get rewindTracksTitle =>
      'Las canciones que no podías dejar de escuchar';

  @override
  String get downloadsCancel => 'Cancelar descarga';

  @override
  String get downloadsEmptyCta => 'Buscar música para descargar';

  @override
  String get downloadsEmptyHint =>
      'Descarga pistas para escuchar sin conexión en cualquier momento';

  @override
  String get downloadsEmptyNeedDesktop =>
      'Las descargas necesitan la app de escritorio.';

  @override
  String get downloadsEmptyTitle => 'No hay canciones descargadas';

  @override
  String get downloadsKicker => 'Sin conexión';

  @override
  String get downloadsOpenFolder => 'Abrir carpeta';

  @override
  String get downloadsPlayAll => 'Reproducir todo';

  @override
  String get downloadsQueued => 'En cola';

  @override
  String get downloadsRemoveLabel => 'Eliminar descarga';

  @override
  String downloadsSubtitle(String n) {
    return '$n canciones guardadas en este dispositivo, disponibles sin conexión';
  }

  @override
  String get downloadsTitle => 'Descargas';

  @override
  String get genreKicker => 'Género';

  @override
  String get genreLoadError => 'No se pudo cargar este género ahora.';

  @override
  String get genrePlay => 'Reproducir';

  @override
  String get genreRetry => 'Reintentar';

  @override
  String get genreTimeAllTime => 'Histórico';

  @override
  String get genreTimeMonth => 'Este mes';

  @override
  String get genreTimeWeek => 'Esta semana';

  @override
  String get genreTopHits => 'Éxitos';

  @override
  String get genreTrending => '· tendencias';

  @override
  String homeBecauseListened(String name) {
    return 'Porque escuchaste $name';
  }

  @override
  String get homeChart => 'Listas';

  @override
  String get homeGreetingAfternoon => 'Buenas tardes';

  @override
  String get homeGreetingEvening => 'Buenas noches';

  @override
  String get homeGreetingLate => '¿Aún despierto?';

  @override
  String get homeGreetingMorning => 'Buenos días';

  @override
  String get homeHotPlaylists => 'Playlists del momento';

  @override
  String get homeLoadError => 'No se pudo cargar tu música';

  @override
  String get homeLoadErrorHint =>
      'Comprueba tu conexión. Los dos catálogos están inaccesibles.';

  @override
  String homeMoodMixes(String name) {
    return 'Mixes de $name';
  }

  @override
  String get homeNewForYou => 'Nuevo para ti';

  @override
  String get homeNewReleases => 'Nuevos lanzamientos';

  @override
  String get homeRetry => 'Reintentar';

  @override
  String homeRewindPartialReady(String label) {
    return 'Tu $label hasta ahora está listo';
  }

  @override
  String homeRewindReady(String label) {
    return 'Tu Rewind de $label está listo';
  }

  @override
  String get homeRewindSub => 'Cada reproducción, contada en este dispositivo.';

  @override
  String get homeRewindWatch => 'Ver';

  @override
  String get homeTopArtists => 'Artistas populares';

  @override
  String get homeTopSongs => 'Éxitos de la semana';

  @override
  String get homeTrending => 'Tendencias de la semana';

  @override
  String get moodLoadError => 'No se pudo cargar esta categoría';

  @override
  String get moodMixes => 'Mixes';

  @override
  String moodPlaylists(String name) {
    return 'Playlists de $name';
  }

  @override
  String get moodRetry => 'Reintentar';

  @override
  String get moodTopTracks => 'Canciones populares';

  @override
  String get searchAria => 'Buscar';

  @override
  String get searchArtists => 'Artistas';

  @override
  String get searchBrowseGenres => 'Explorar géneros';

  @override
  String get searchClear => 'Borrar';

  @override
  String get searchFailed => 'Error en la búsqueda';

  @override
  String get searchFailedHint =>
      'No se pudo conectar con el catálogo de música. Comprueba tu conexión e intenta de nuevo';

  @override
  String get searchMoods => 'Estados de ánimo y momentos';

  @override
  String get searchMoreTracks => 'Más canciones';

  @override
  String searchNoResults(String q) {
    return 'No hay resultados para “$q”';
  }

  @override
  String get searchNoResultsHint =>
      'Comprueba la ortografía o intenta buscar otra canción, artista o álbum';

  @override
  String get searchPlaceholder => 'Canciones, artistas, playlists…';

  @override
  String get searchPlaylistsAlbums => 'Playlists y álbumes';

  @override
  String get searchRetry => 'Reintentar';

  @override
  String get searchSong => 'Canción';

  @override
  String get searchSongs => 'Canciones';

  @override
  String get searchTopResult => 'Resultado principal';

  @override
  String get statsArtistsHeard => 'Artistas escuchados';

  @override
  String get statsEmptyHint =>
      'Comienza a reproducir canciones para ver aquí tus hábitos y tendencias de escucha';

  @override
  String get statsEmptyTitle => 'Aún no hay estadísticas';

  @override
  String get statsListeningTime => 'Tiempo de escucha';

  @override
  String get statsNoListening => 'sin escuchas';

  @override
  String statsRewindFull(String label) {
    return 'Ver tu Rewind de $label';
  }

  @override
  String statsRewindPartial(String label) {
    return 'Ver tu $label hasta ahora';
  }

  @override
  String get statsSubtitle => 'Contado en este dispositivo. Nunca se sube.';

  @override
  String get statsThisWeek => 'Esta semana';

  @override
  String get statsTitle => 'Tus estadísticas';

  @override
  String get statsTopArtists => 'Artistas populares';

  @override
  String get statsTopTracks => 'Canciones populares';

  @override
  String get statsTotalPlays => 'Reproducciones totales';

  @override
  String get statsTracksPlayed => 'Canciones reproducidas';

  @override
  String statsWeekTotal(String t) {
    return '$t esta semana';
  }

  @override
  String get artistAbout => 'Acerca de';

  @override
  String get artistAlbums => 'Álbumes';

  @override
  String get artistFollow => 'Seguir';

  @override
  String get artistFollowing => 'Siguiendo';

  @override
  String artistMonthlyListeners(String n) {
    return '$n oyentes mensuales';
  }

  @override
  String get artistNoTracks => 'Este artista aún no ha subido canciones.';

  @override
  String get artistNotFound => 'No se encontró el artista';

  @override
  String artistNotFoundNamed(String name) {
    return 'No se pudo cargar la página de $name. Puede que se haya movido o que la red haya fallado.';
  }

  @override
  String get artistNotFoundSub =>
      'Puede que se haya movido o que la red haya fallado.';

  @override
  String get artistPlay => 'Reproducir';

  @override
  String get artistPopular => 'Popular';

  @override
  String get artistRetry => 'Reintentar';

  @override
  String artistShowAll(String n) {
    return 'Mostrar todo ($n)';
  }

  @override
  String get artistShowLess => 'Mostrar menos';

  @override
  String get artistSingles => 'Sencillos y EP';

  @override
  String artistStats(String followers, String tracks) {
    return '$followers seguidores · $tracks canciones';
  }

  @override
  String get artistTracksError =>
      'No se pudieron cargar las canciones; la página del artista está bien.';

  @override
  String get artistVerified => 'Artista verificado';

  @override
  String get importBadCsv => 'No se pudo leer ese CSV';

  @override
  String get importBadJson =>
      'No se pudo leer ese archivo. Se esperaba una playlist .freebify.json';

  @override
  String get importButton => 'Importar';

  @override
  String get importChooseCsv => 'Elegir archivo .csv';

  @override
  String get importClose => 'Cerrar';

  @override
  String get importCsvHint =>
      'Para playlists más largas o privadas. Las columnas de título y artista se detectan automáticamente. Máx. 5000.';

  @override
  String get importCsvLabel => 'Archivo CSV';

  @override
  String get importFailed => 'Error al importar. Vuelve a intentarlo';

  @override
  String importImported(String n) {
    return '$n canciones importadas';
  }

  @override
  String importLimited(String n) {
    return 'Importadas $n canciones. Spotify solo publicó las primeras 100, exporta un CSV para traer el resto.';
  }

  @override
  String get importLinkHint =>
      'Spotify: pega cualquier playlist pública, lista completa. YouTube Music: lista completa, sin emparejamientos.';

  @override
  String get importLinkLabel => 'Enlace de Spotify o YouTube Music';

  @override
  String get importNotFound =>
      'Playlist no encontrada. Comprueba que no sea privada';

  @override
  String get importPasteLink =>
      'Pega un enlace de playlist de Spotify o YouTube Music';

  @override
  String get importSubmit => 'Importar playlist';

  @override
  String get importTitle => 'Importar una playlist';

  @override
  String get importUnreadable =>
      'No se pudo leer esa playlist. Comprueba que sea pública';

  @override
  String get libraryEmptyLikedCta => 'Busca algo que te encante';

  @override
  String get libraryEmptyLikedSub =>
      'Toca el corazón de cualquier canción para guardarla.';

  @override
  String get libraryEmptyLikedTitle =>
      'Las canciones que te gusten aparecerán aquí';

  @override
  String get libraryEmptyPlaylists =>
      'Crea una playlist y añade canciones desde el menú ··· de cualquier canción.';

  @override
  String get libraryFollowed => 'Artistas que sigues';

  @override
  String get libraryLikedSongs => 'Canciones que te gustan';

  @override
  String get libraryNewPlaylist => 'Nueva playlist';

  @override
  String get libraryPlayAll => 'Reproducir todo';

  @override
  String get libraryPlaylistLabel => 'Playlist';

  @override
  String get libraryRecents => 'Reproducido recientemente';

  @override
  String libraryTrackCount(String n) {
    return '$n canciones';
  }

  @override
  String get libraryYourPlaylists => 'Tus playlists';

  @override
  String get playlistAlbum => 'Álbum';

  @override
  String get playlistAlreadyDownloaded => 'Ya descargado';

  @override
  String get playlistCopyLink => 'Copiar enlace';

  @override
  String get playlistCopyLinkAria => 'Copiar enlace de la playlist';

  @override
  String get playlistDelete => 'Eliminar';

  @override
  String get playlistDeleteConfirm => '¿Eliminar?';

  @override
  String get playlistDownloadAll => 'Descargar todo';

  @override
  String get playlistDownloadAllTitle =>
      'Descargar todas las canciones para escuchar sin conexión';

  @override
  String playlistDownloading(String n) {
    return 'Descargando $n canciones';
  }

  @override
  String get playlistEmpty => 'Esta playlist está vacía.';

  @override
  String get playlistExport => 'Exportar';

  @override
  String get playlistExportTitle =>
      'Exportar como archivo .freebify.json para compartir';

  @override
  String get playlistExported => 'Playlist exportada';

  @override
  String get playlistEmptyLocalSub => 'Usa el menú ··· de cualquier canción.';

  @override
  String get playlistEmptyLocalTitle =>
      'Las canciones que añadas aparecerán aquí';

  @override
  String get playlistFindInPlaylist => 'Buscar en la playlist';

  @override
  String get playlistFindSongs => 'Buscar canciones';

  @override
  String playlistNoMatch(String q) {
    return 'Ninguna canción coincide con “$q”.';
  }

  @override
  String get playlistNotFound => 'Playlist no encontrada';

  @override
  String get playlistNotFoundLocalSub => 'Puede que se haya eliminado.';

  @override
  String get playlistNotFoundSub =>
      'Puede que se haya eliminado o que la red haya fallado.';

  @override
  String get playlistPlay => 'Reproducir';

  @override
  String get playlistPlaylist => 'Playlist';

  @override
  String playlistPlays(String n) {
    return '$n reproducciones';
  }

  @override
  String get playlistRemoveLabel => 'Quitar de la playlist';

  @override
  String get playlistRename => 'Cambiar nombre';

  @override
  String get playlistRenameAria => 'Cambiar nombre de la playlist';

  @override
  String get playlistRetry => 'Reintentar';

  @override
  String get playlistSaveToLibrary => 'Guardar en tu biblioteca';

  @override
  String get playlistSort => 'Ordenar';

  @override
  String get playlistSortTitle => 'Título';

  @override
  String get playlistSortArtist => 'Artista';

  @override
  String get playlistSortDuration => 'Duración';

  @override
  String playlistTrackCount(String n) {
    return '$n canciones';
  }

  @override
  String get playlistTracksError =>
      'No se pudieron cargar las canciones; la playlist está bien.';

  @override
  String get playlistUnknown => 'Desconocido';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsAboutBody =>
      'Música gratis y sin anuncios. Freebify es un reproductor, no un host: todo el audio y los metadatos los obtiene tu dispositivo directamente de YouTube Music y de la API pública de Audius, bajo sus propios términos. Para uso personal y no comercial. No está afiliado a Spotify, YouTube, Google ni Audius.';

  @override
  String settingsAboutVersions(String electron, String chromium) {
    return 'Electron $electron · Chromium $chromium';
  }

  @override
  String get settingsAutoplay =>
      'Reproducción automática de canciones similares';

  @override
  String get settingsAutoplaySub => 'La cola sigue sonando al terminar';

  @override
  String get settingsBackupExported => 'Copia de seguridad exportada';

  @override
  String get settingsCacheCleared =>
      'Caché borrada. Tu biblioteca sigue intacta';

  @override
  String get settingsCacheFailed => 'No se pudo borrar la caché';

  @override
  String get settingsCheckUpdates => 'Buscar actualizaciones';

  @override
  String get settingsChecking => 'Comprobando…';

  @override
  String get settingsClearCache => 'Borrar caché de portadas y letras';

  @override
  String get settingsContribute => 'Código abierto. Colabora en GitHub';

  @override
  String get settingsDiscord => 'Estado de Discord';

  @override
  String get settingsDiscordSub => 'Muestra lo que escuchas en tu perfil';

  @override
  String get settingsExport => 'Exportar biblioteca y estadísticas';

  @override
  String get settingsExportFailed => 'Error al exportar';

  @override
  String get settingsKSpace => 'Espacio';

  @override
  String get settingsLegal => 'Legal: descargo y términos';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSub => 'Se aplica a toda la app al instante.';

  @override
  String get settingsLibrary => 'Biblioteca';

  @override
  String settingsLibraryStats(String liked, String playlists) {
    return '$liked canciones que te gustan · $playlists playlists, guardado en este dispositivo.';
  }

  @override
  String get settingsLogin => 'Abrir Freebify al iniciar sesión';

  @override
  String get settingsLoginSub =>
      'Arranca con el escritorio, listo en segundo plano';

  @override
  String get settingsOpenLogs => 'Abrir carpeta de logs';

  @override
  String get settingsPlayback => 'Reproducción';

  @override
  String get settingsScClosePanels => 'Cerrar paneles';

  @override
  String get settingsScLike => 'Dar me gusta a la canción actual';

  @override
  String get settingsScMute => 'Silenciar';

  @override
  String get settingsScNowPlaying => 'Reproduciendo ahora';

  @override
  String get settingsScPlayPause => 'Reproducir / pausar';

  @override
  String get settingsScQueue => 'Cola';

  @override
  String get settingsScSearch => 'Buscar';

  @override
  String get settingsScSeek => 'Saltar 10 segundos';

  @override
  String get settingsScVolume => 'Volumen';

  @override
  String get settingsShortcuts => 'Atajos de teclado';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String settingsUpdateAvailable(String v) {
    return 'v$v disponible, descargando en segundo plano';
  }

  @override
  String get settingsUpdateFailed => 'Error al buscar actualizaciones';

  @override
  String get settingsUpdateFailedLater =>
      'Error al buscar actualizaciones. Inténtalo más tarde';

  @override
  String get settingsUpdateLatest => 'Ya tienes la última versión';

  @override
  String settingsUpdatePending(String v) {
    return 'v$v lista. Reinicia desde el banner';
  }

  @override
  String get themeMode => 'Tema';

  @override
  String get themeSystem => 'Predeterminado del sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get reduceTransparency => 'Reducir transparencia';

  @override
  String get reduceTransparencySubtitle =>
      'Usar superficies sólidas en lugar de efectos translúcidos de desenfoque';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get streamQuality => 'Calidad de transmisión de audio';

  @override
  String get qualityHigh => 'Alta (mejor audio)';

  @override
  String get qualityLow => 'Ahorro de datos (baja)';

  @override
  String get wifiOnlyDownloads => 'Descargar solo por Wi-Fi';

  @override
  String get clearCache => 'Borrar caché';

  @override
  String get cacheCleared => 'Caché borrada con éxito';

  @override
  String get exportBackup => 'Exportar copia de seguridad';

  @override
  String get importBackup => 'Importar copia de seguridad';

  @override
  String get importBackupSuccess => 'Copia de seguridad importada con éxito';

  @override
  String get importBackupConfirm =>
      'Importar esta copia combinará listas, canciones favoritas e historial. ¿Continuar?';

  @override
  String get shareLogs => 'Compartir registros';

  @override
  String get noLogs => 'No se encontraron registros para compartir';

  @override
  String get synced => 'Línea sincronizada con el momento actual';

  @override
  String get syncLineToNow => 'Sincronizar esta línea con ahora';

  @override
  String get accuracyNote =>
      'La sincronización de la letra puede variar según la grabación';

  @override
  String get appUpdateDownload => 'Descargar actualización';

  @override
  String get nowPlaying => 'Reproduciendo ahora';

  @override
  String get newPlaylist => 'Nueva lista de reproducción';

  @override
  String get createPlaylist => 'Crear lista de reproducción';

  @override
  String get playlistNamePlaceholder => 'Nombre de la lista';

  @override
  String get disclaimer => 'Descargo de responsabilidad';

  @override
  String get terms => 'Términos del servicio';

  @override
  String get privacy => 'Política de privacidad';

  @override
  String get legal => 'Avisos legales y licencias';

  @override
  String get aboutAttribution =>
      'Basado en Freebify por govu — https://github.com/govu/freebify';

  @override
  String get retry => 'Reintentar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get save => 'Guardar';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get editAction => 'Editar';

  @override
  String get doneAction => 'Listo';

  @override
  String get removeAction => 'Quitar';

  @override
  String get playAction => 'Reproducir';

  @override
  String get pauseAction => 'Pausar';

  @override
  String get shuffleAction => 'Aleatorio';

  @override
  String get addTracks => 'Añadir canciones';

  @override
  String get renamePlaylist => 'Renombrar lista';

  @override
  String get deletePlaylistConfirm =>
      '¿Seguro que quieres eliminar esta lista de reproducción?';

  @override
  String get startRadio => 'Iniciar radio';

  @override
  String get goToArtist => 'Ir al artista';

  @override
  String get goToAlbum => 'Ir al álbum';

  @override
  String get saveToLibrary => 'Guardar en tu biblioteca';

  @override
  String get removeFromLibrary => 'Quitar de tu biblioteca';

  @override
  String get downloadTrack => 'Descargar canción';

  @override
  String get removeDownload => 'Eliminar descarga';

  @override
  String get downloaded => 'Descargado';

  @override
  String get downloading => 'Descargando';

  @override
  String get queued => 'En cola';

  @override
  String get shareTrack => 'Compartir canción';

  @override
  String get sharePlaylist => 'Compartir lista';

  @override
  String get copyLink => 'Copiar enlace';

  @override
  String get linkCopied => 'Enlace copiado al portapapeles';

  @override
  String get noLyrics => 'No hay letras disponibles para esta canción';

  @override
  String matchingProgress(String matched, String total) {
    return 'Coincidiendo $matched de $total canciones…';
  }

  @override
  String get importPlaylistTitle => 'Importar lista de reproducción';

  @override
  String get importUrlHint => 'Pega el enlace de Spotify o YouTube Music';

  @override
  String get importFileButton => 'Elegir archivo CSV o .freebify.json';

  @override
  String get allFilter => 'Todo';

  @override
  String get songsFilter => 'Canciones';

  @override
  String get artistsFilter => 'Artistas';

  @override
  String get playlistsFilter => 'Listas y álbumes';

  @override
  String get topResult => 'Resultado principal';

  @override
  String get moreTracks => 'Más canciones';

  @override
  String get popularTracks => 'Populares';

  @override
  String get discography => 'Discografía';

  @override
  String get albumsSection => 'Álbumes';

  @override
  String get singlesSection => 'Sencillos y EPs';

  @override
  String get aboutArtist => 'Información';

  @override
  String monthlyListenersCount(String n) {
    return '$n oyentes mensuales';
  }

  @override
  String followersCount(String n) {
    return '$n seguidores';
  }

  @override
  String trackCountLabel(String n) {
    return '$n canciones';
  }

  @override
  String get listeningTime => 'Tiempo de escucha';

  @override
  String get totalPlays => 'Reproducciones totales';

  @override
  String get tracksPlayed => 'Canciones reproducidas';

  @override
  String get artistsHeard => 'Artistas escuchados';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get topTracks => 'Canciones más escuchadas';

  @override
  String get topArtists => 'Artistas principales';

  @override
  String get rewindAction => 'Ver Rewind';

  @override
  String get equalizerTitle => 'Ecualizador';

  @override
  String get eqPresetCustom => 'Personalizado';

  @override
  String get sleepTimerTitle => 'Temporizador de apagado';

  @override
  String get sleepTimerOff => 'Desactivado';

  @override
  String get sleepTimer5 => '5 minutos';

  @override
  String get sleepTimer15 => '15 minutos';

  @override
  String get sleepTimer30 => '30 minutos';

  @override
  String get sleepTimer45 => '45 minutos';

  @override
  String get sleepTimer60 => '60 minutos';

  @override
  String get sleepTimerTrackEnd => 'Al final de la canción actual';
}
