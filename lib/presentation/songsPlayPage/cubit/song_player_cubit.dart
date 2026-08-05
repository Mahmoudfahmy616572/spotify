// ignore_for_file: avoid_print, experimental_member_use
import 'dart:async';
import 'dart:io' show File;

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spotify/core/services/sync_analyzer.dart';
import 'package:spotify/core/services/sync_offset_cache.dart';
import 'package:spotify/core/services/maqam_detector.dart';
import 'package:spotify/core/services/quran_resolver.dart';
import 'package:spotify/core/services/archive_resolver.dart';
import 'package:spotify/core/services/youtube_resolver.dart';
import 'package:spotify/data/sources/jamendo/jamendo_data_source.dart';
import 'package:spotify/data/sources/deezer/deezer_data_source.dart';
import 'package:spotify/data/sources/verome/verome_data_source.dart';
import 'package:spotify/data/models/songs/songs_model.dart';
import 'package:spotify/data/sources/listening_history/listening_data_source.dart';
import 'package:spotify/serviece_locator.dart';

import 'lyrics/lyrics_cubit.dart';
import 'lyrics/lyrics_state.dart';
import 'song_player_state.dart';

class SongPlayerCubit extends Cubit<SongPlayerState> {
  static const MethodChannel _audioDecoderChannel = MethodChannel('audio_decoder');
  bool _isShuffleMode = false;
  bool get isShuffleMode => _isShuffleMode;
  LoopMode _loopMode = LoopMode.off;
  LoopMode get loopMode => _loopMode;
  bool _isLyricsVisible = false;
  bool _showFullSongPopup = false;
  final AudioPlayer audioPlayer = AudioPlayer();
  final Dio _dio = Dio(BaseOptions(
    headers: {
      'User-Agent': 'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36',
    },
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));
  List<SongModel> _playList = [];
  int _currentIndex = 0;
  String _url = '';
  bool _isFullSong = false;
  Duration _songDuration = Duration.zero;
  Duration _songPosition = Duration.zero;
  Color _dominantColor = const Color(0xff121212);
  Function(SongModel)? onSongPlayed;
  LyricsCubit? _lyricsCubit;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  SongModel? _previousSong;
  DateTime? _songStartedAt;
  bool _songFullyListened = false;
  Timer? _listenDurationTimer;
  Duration _syncOffset = Duration.zero;
  final SyncOffsetCache _offsetCache = SyncOffsetCache();
  SyncAnalyzer? _analyzer;
  MaqamResult? _currentMaqam;
  final Map<String, MaqamResult> _maqamCache = {};

  List<SongModel> get playList => _playList;
  int get currentIndex => _currentIndex;
  Duration get songDuration => _songDuration;
  Duration get songPosition => _songPosition;
  Color get dominantColor => _dominantColor;
  MaqamResult? get currentMaqam => _currentMaqam;

  SongPlayerCubit({LyricsCubit? lyricsCubit})
      : _lyricsCubit = lyricsCubit,
        super(const SongPlayerLoading()) {
    _subscriptions.add(audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _songDuration = duration;
        _checkPreviewAndShowPopup();
        _emitCurrentState();
      }
    }));
    _subscriptions.add(audioPlayer.positionStream.listen((position) {
      _songPosition = position;
      _checkPreviewAndShowPopup();
      _emitCurrentState();
    }));
    _subscriptions.add(audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_showFullSongPopup) return;
        _songFullyListened = true;
        _recordFinalListenDuration();
        playNext();
      }
    }));
  }

  void setLyricsCubit(LyricsCubit cubit) {
    _lyricsCubit = cubit;
  }

  void _emitCurrentState() {
    if (!isClosed) {
      emit(SongPlayerLoaded(
        isLyricsVisible: _isLyricsVisible,
        showFullSongPopup: _showFullSongPopup,
        isFullSong: _isFullSong,
        syncOffset: _syncOffset,
        currentIndex: _currentIndex,
        playlist: List.unmodifiable(_playList),
        isPlaying: audioPlayer.playing,
        songPosition: _songPosition,
        songDuration: _songDuration,
        dominantColor: _dominantColor,
      ));
    }
  }

  void _trackSkipIfNeeded() {
    if (_previousSong == null || _songStartedAt == null) return;

    final listened = DateTime.now().difference(_songStartedAt!);
    if (listened.inSeconds < 15 && !_songFullyListened) {
      try {
        final ds = getIt<ListeningDataSource>();
        ds.recordSkip(
          _previousSong!.id,
          _previousSong!.title,
          _previousSong!.artist,
          listened,
        );
      } catch (_) {}
    }

    if (_previousSong != null && _songStartedAt != null) {
      try {
        final ds = getIt<ListeningDataSource>();
        final listened = DateTime.now().difference(_songStartedAt!);
        ds.recordListenDuration(
          _previousSong!.id,
          _previousSong!.title,
          _previousSong!.artist,
          listened,
          _songDuration,
        );
      } catch (_) {}
    }
  }

  void _recordPlayEvent(SongModel song, {bool wasSkipped = false}) {
    try {
      final ds = getIt<ListeningDataSource>();
      final listened = _songStartedAt != null
          ? DateTime.now().difference(_songStartedAt!)
          : Duration.zero;
      ds.recordPlayEvent(PlayEvent(
        songId: song.id,
        title: song.title,
        artist: song.artist,
        timestamp: DateTime.now(),
        listenedDuration: listened,
        totalDuration: _songDuration,
        wasSkipped: wasSkipped,
      ));
    } catch (_) {}
  }

  void _recordFinalListenDuration() {
    if (_previousSong == null || _songStartedAt == null) return;
    try {
      final ds = getIt<ListeningDataSource>();
      final listened = DateTime.now().difference(_songStartedAt!);
      ds.recordListenDuration(
        _previousSong!.id,
        _previousSong!.title,
        _previousSong!.artist,
        listened,
        _songDuration,
      );
    } catch (_) {}
  }

  void _checkPreviewAndShowPopup() {}

  void dismissFullSongPopup() {
    _showFullSongPopup = false;
    _emitCurrentState();
  }

  Future<void> resolveFullSong() async {
    _showFullSongPopup = false;
    _emitCurrentState();
    audioPlayer.play();
    _emitCurrentState();
  }

  void toggleShowLyrics() {
    _isLyricsVisible = !_isLyricsVisible;
    _emitCurrentState();
  }

  void setLyricsVisible(bool visible) {
    _isLyricsVisible = visible;
    _emitCurrentState();
  }

  void updatePlaylist(List<SongModel> newPlaylist) {
    _playList = newPlaylist;
    _emitCurrentState();
  }

  void toggleShuffleMode() async {
    _isShuffleMode = !_isShuffleMode;
    await audioPlayer.setShuffleModeEnabled(_isShuffleMode);
    if (_isShuffleMode) {
      await audioPlayer.shuffle();
    }
    _emitCurrentState();
  }

  void toggleRepeatMode() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.one;
    } else if (_loopMode == LoopMode.one) {
      _loopMode = LoopMode.all;
    } else {
      _loopMode = LoopMode.off;
    }
    audioPlayer.setLoopMode(_loopMode);
    _emitCurrentState();
  }

  Future<void> upDateThemeColor(String imageUrl) async {
    final uri = Uri.tryParse(imageUrl);
    if (imageUrl.isEmpty || uri == null || uri.host.isEmpty) {
      _dominantColor = const Color(0xff121212);
      _emitCurrentState();
      return;
    }
    try {
      PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
        maximumColorCount: 10,
      );
      _dominantColor =
          paletteGenerator.dominantColor?.color ?? const Color(0xff121212);
    } catch (e) {
      _dominantColor = const Color(0xff121212);
    }
    _emitCurrentState();
  }

  void _autoFetchLyrics(SongModel song) {
    if (_lyricsCubit != null && !_lyricsCubit!.isClosed) {
      _lyricsCubit!.fetchLyrics(
        trackName: song.title,
        artistName: song.artist,
      );
    }
  }

  final Map<String, String> _jamendoCache = {};
  final ArchiveResolver _archiveResolver = ArchiveResolver();
  final YoutubeResolver _youtubeResolver = YoutubeResolver();
  final Map<String, Map<String, String>> _ytHeadersByUrl = {};

  StreamAudioSource _dioAudioSource(String url, {Map<String, String>? headers}) {
    return _DioStreamAudioSource(_dio, url, headers);
  }

  Future<void> loadSong(
      List<SongModel> songs, int index, String urlImage, {bool skipLoadingEmit = false}) async {
    _trackSkipIfNeeded();
    _listenDurationTimer?.cancel();

    final previousSong = _playList.isNotEmpty && _currentIndex < _playList.length
        ? _playList[_currentIndex]
        : null;
    if (previousSong != null && _songStartedAt != null) {
      _recordPlayEvent(previousSong, wasSkipped: true);
    }

    _previousSong = songs[index];
    _songStartedAt = DateTime.now();
    _songFullyListened = false;
    _showFullSongPopup = false;
    _isFullSong = false;

    _playList = songs;
    _currentIndex = index;
    _url = urlImage;
    _loadSyncOffset(songs[index].id.toString());
    upDateThemeColor(songs[index].imageUrl);
    onSongPlayed?.call(songs[index]);
    _autoFetchLyrics(songs[index]);

    try {
      if (!skipLoadingEmit) emit(const SongPlayerLoaded(isLyricsVisible: false, isFullSong: false));
      final box = Hive.box('offline_songs');
      final String? localPath = box.get(_playList[_currentIndex].id.toString());
      if (localPath != null && await File(localPath).exists()) {
        print('[PLAY] Offline: ${songs[_currentIndex].title}');
        await audioPlayer.setFilePath(localPath);
      } else {
        String? streamUrl;

        // ── 0. Quran surah (full recitation from mp3quran.net) ──
        final quranUrl =
            QuranResolver.resolve(songs[_currentIndex]);
        if (quranUrl != null) {
          streamUrl = quranUrl;
          print('[QURAN] Full recitation: ${songs[_currentIndex].title}');
        }

        // ── 1. Try Jamendo (full CC audio) ──
        if (getIt.isRegistered<JamendoDataSource>()) {
          final songKey = '${songs[_currentIndex].title}|${songs[_currentIndex].artist}';
          if (_jamendoCache.containsKey(songKey)) {
            streamUrl = _jamendoCache[songKey];
            print('[JAMENDO] Cache hit: ${songs[_currentIndex].title}');
          } else {
            print('[JAMENDO] Searching: ${songs[_currentIndex].title} - ${songs[_currentIndex].artist}');
            final title = songs[_currentIndex].title;
            final queries = [
              '$title ${songs[_currentIndex].artist}',
              title,
            ];
            final clean = title.replaceAll(RegExp(r'\(feat\..*?\)|\[feat\..*?\]|\(ft\..*?\)'), '').trim();
            if (clean != title) queries.add('$clean ${songs[_currentIndex].artist}');
            for (final q in queries) {
              try {
                final jamendo = getIt<JamendoDataSource>();
                final results = await jamendo.search(q, limit: 3)
                    .timeout(const Duration(seconds: 5));
                if (results.isNotEmpty) {
                  streamUrl = results.first.audioUrl;
                  _jamendoCache[songKey] = streamUrl;
                  print('[JAMENDO] Found: ${results.first.name} - ${results.first.artistName}');
                  break;
                }
              } catch (_) {}
            }
          }
        }

        // ── 1.25 Try YouTube via resolver backend (full audio) ──
        if (streamUrl == null) {
          final songKey =
              '${songs[_currentIndex].title}|${songs[_currentIndex].artist}';
          if (!_jamendoCache.containsKey(songKey)) {
            try {
              print('[YT] Resolving: ${songs[_currentIndex].title}');
              final yt = await _youtubeResolver
                  .resolve(
                      title: songs[_currentIndex].title,
                      artist: songs[_currentIndex].artist)
                  .timeout(const Duration(seconds: 25));
              if (yt != null) {
                streamUrl = yt.url;
                _jamendoCache[songKey] = yt.url;
                if (yt.headers.isNotEmpty) _ytHeadersByUrl[yt.url] = yt.headers;
                print('[YT] Found: ${yt.title}');
              } else {
                print('[YT] No result');
              }
            } catch (e) {
              print('[YT] Error: $e');
            }
          } else {
            streamUrl = _jamendoCache[songKey];
            print('[YT] Cache hit: ${songs[_currentIndex].title}');
          }
        }

        // ── 1.5 Try Archive.org (full-length audio) when Jamendo has no match ──
        if (streamUrl == null) {
          final songKey =
              '${songs[_currentIndex].title}|${songs[_currentIndex].artist}';
          if (!_jamendoCache.containsKey(songKey)) {
            try {
              print('[ARCHIVE] Searching: ${songs[_currentIndex].title}');
              final aUrl = await _archiveResolver
                  .searchFullSong(
                      title: songs[_currentIndex].title,
                      artist: songs[_currentIndex].artist)
                  .timeout(const Duration(seconds: 12));
              if (aUrl != null && aUrl.isNotEmpty) {
                streamUrl = aUrl;
                _jamendoCache[songKey] = aUrl;
                print('[ARCHIVE] Found: ${songs[_currentIndex].title}');
              } else {
                print('[ARCHIVE] No results');
              }
            } catch (e) {
              print('[ARCHIVE] Search error: $e');
            }
          } else {
            streamUrl = _jamendoCache[songKey];
            print('[ARCHIVE] Cache hit: ${songs[_currentIndex].title}');
          }
        }

        // ── 1.5 Try Verome (YouTube full audio) when Jamendo has no match ──
        if (streamUrl == null && getIt.isRegistered<VeromeDataSource>()) {
          final songKey =
              '${songs[_currentIndex].title}|${songs[_currentIndex].artist}';
          if (!_jamendoCache.containsKey(songKey)) {
            try {
              print('[VEROME] Searching: ${songs[_currentIndex].title}');
              final verome = getIt<VeromeDataSource>();
              final vResults = await verome
                  .search(
                      '${songs[_currentIndex].title} ${songs[_currentIndex].artist}',
                      limit: 3)
                  .timeout(const Duration(seconds: 5));
              if (vResults.isNotEmpty) {
                final vUrl = await verome
                    .getStreamUrl(vResults.first.id)
                    .timeout(const Duration(seconds: 8));
                if (vUrl != null && vUrl.isNotEmpty) {
                  streamUrl = vUrl;
                  _jamendoCache[songKey] = vUrl;
                  print('[VEROME] Found: ${vResults.first.title}');
                } else {
                  print('[VEROME] No stream URL for ${vResults.first.title}');
                }
              } else {
                print('[VEROME] No search results');
              }
            } catch (e) {
              print('[VEROME] Search error: $e');
            }
          } else {
            streamUrl = _jamendoCache[songKey];
            print('[VEROME] Cache hit: ${songs[_currentIndex].title}');
          }
        }

        // ── 2. Play ──
        if (streamUrl != null && streamUrl.isNotEmpty) {
          print('[PLAY] Full song: ${songs[_currentIndex].title}');
          _isFullSong = !streamUrl.contains('dzcdn.net');
          final ytHeaders = _ytHeadersByUrl[streamUrl];
          await audioPlayer.setAudioSource(
              _dioAudioSource(streamUrl, headers: ytHeaders));
        } else {
          final songUrl = songs[_currentIndex].urlSongsbase;
          final uri = Uri.tryParse(songUrl);
          if (songUrl.isEmpty || uri == null || uri.host.isEmpty) {
            print('[PLAY] No playable URL for ${songs[_currentIndex].title}');
            throw Exception('No playable URL');
          }
          print('[PLAY] Preview (Deezer): ${songs[_currentIndex].title}');
          _isFullSong = !songUrl.contains('dzcdn.net');
          await audioPlayer.setAudioSource(_dioAudioSource(songUrl));
        }
      }
      audioPlayer.play();
      _emitCurrentState();
      _preloadNextSong();
    } on Exception catch (e) {
      print('[PLAY] Failed: $e');
      final song = songs[_currentIndex];
      final isOldDeezer = song.urlSongsbase.contains('dzcdn.net');
      if (isOldDeezer && getIt.isRegistered<DeezerDataSource>()) {
        print('[PLAY] Deezer URL expired, re-fetching...');
        try {
          final deezer = getIt<DeezerDataSource>();
          final fresh = await deezer.searchTracks(
            '${song.title} ${song.artist}',
            limit: 1,
          );
          if (fresh.isNotEmpty && fresh.first.urlSongsbase.isNotEmpty) {
            print('[PLAY] Fresh Deezer URL obtained');
            _isFullSong = false;
            await audioPlayer.setAudioSource(_dioAudioSource(fresh.first.urlSongsbase));
            audioPlayer.play();
            _emitCurrentState();
            _preloadNextSong();
            return;
          }
        } catch (_) {}
      }
      emit(SongPlayerFailure(errorMessage: 'Failed to load song'));
    }
  }

  Future<void> _preloadNextSong() async {
    final nextIndex = _currentIndex < _playList.length - 1 ? _currentIndex + 1 : 0;
    if (nextIndex == _currentIndex) return;
    final song = _playList[nextIndex];
    final songKey = '${song.title}|${song.artist}';
    if (_jamendoCache.containsKey(songKey)) return;

    // Try Jamendo
    if (getIt.isRegistered<JamendoDataSource>()) {
      try {
        final jamendo = getIt<JamendoDataSource>();
        final results = await jamendo.search(
          '${song.title} ${song.artist}',
          limit: 1,
        ).timeout(const Duration(seconds: 5));
        if (results.isNotEmpty) {
          _jamendoCache[songKey] = results.first.audioUrl;
          return;
        }
      } catch (_) {}
    }

    // Try Verome (YouTube full audio)
    if (getIt.isRegistered<VeromeDataSource>()) {
      try {
        final verome = getIt<VeromeDataSource>();
        final vResults = await verome
            .search('${song.title} ${song.artist}', limit: 1)
            .timeout(const Duration(seconds: 5));
        if (vResults.isNotEmpty) {
          final vUrl = await verome
              .getStreamUrl(vResults.first.id)
              .timeout(const Duration(seconds: 8));
          if (vUrl != null && vUrl.isNotEmpty) {
            _jamendoCache[songKey] = vUrl;
          }
        }
      } catch (_) {}
    }

    // Try Archive.org (full-length audio)
    if (!_jamendoCache.containsKey(songKey)) {
      try {
        final aUrl = await _archiveResolver
            .searchFullSong(title: song.title, artist: song.artist)
            .timeout(const Duration(seconds: 12));
        if (aUrl != null && aUrl.isNotEmpty) {
          _jamendoCache[songKey] = aUrl;
        }
      } catch (_) {}
    }

    // Try YouTube via resolver backend (full audio)
    if (!_jamendoCache.containsKey(songKey)) {
      try {
        final yt = await _youtubeResolver
            .resolve(title: song.title, artist: song.artist)
            .timeout(const Duration(seconds: 25));
        if (yt != null && yt.url.isNotEmpty) {
          _jamendoCache[songKey] = yt.url;
          if (yt.headers.isNotEmpty) _ytHeadersByUrl[yt.url] = yt.headers;
        }
      } catch (_) {}
    }
  }

  Future<void> _loadSyncOffset(String songId) async {
    final cached = await _offsetCache.getOffset(songId);
    if (cached != null) {
      _syncOffset = cached;
      _emitCurrentState();
    } else {
      _triggerAnalysis(songId);
    }
    detectMaqam(songId, _playList[_currentIndex].urlSongsbase);
  }

  Future<void> _triggerAnalysis(String songId) async {
    if (_lyricsCubit == null || _lyricsCubit!.isClosed) return;
    final lyricsState = _lyricsCubit!.state;
    if (lyricsState is! LyricsLoaded || lyricsState.lyrics.length < 3) return;

    String? audioUrl;
    if (getIt.isRegistered<JamendoDataSource>()) {
      final songKey = '${_playList[_currentIndex].title}|${_playList[_currentIndex].artist}';
      if (_jamendoCache.containsKey(songKey)) {
        audioUrl = _jamendoCache[songKey];
      }
    }
    audioUrl ??= _playList[_currentIndex].urlSongsbase;
    if (audioUrl.isEmpty) return;

    try {
      _analyzer ??= SyncAnalyzer(_dio);
      final offset = await _analyzer!.analyze(audioUrl, lyricsState.lyrics);
      if (offset != null && !isClosed) {
        await _offsetCache.setOffset(songId, offset);
        _syncOffset = offset;
        _emitCurrentState();
      }
    } catch (_) {}
  }

  Future<void> detectMaqam(String songId, String audioUrl) async {
    if (_maqamCache.containsKey(songId)) {
      _currentMaqam = _maqamCache[songId];
      _emitCurrentState();
      return;
    }
    try {
      final detector = MaqamDetector();
      final analyzer = _analyzer ??= SyncAnalyzer(_dio);
      final tempDir = await getTemporaryDirectory();
      final audioFile = File('${tempDir.path}/maqam_$songId.mp3');
      final wavFile = File('${tempDir.path}/maqam_$songId.wav');

      await _dio.download(audioUrl, audioFile.path);
      if (!audioFile.existsSync()) return;
      try {
        await _audioDecoderChannel.invokeMethod('decodeToWav', {
          'inputPath': audioFile.path,
          'outputPath': wavFile.path,
        });
      } on MissingPluginException {
        audioFile.deleteSync();
        return;
      }
      if (!wavFile.existsSync()) {
        audioFile.deleteSync();
        return;
      }

      final wavBytes = await wavFile.readAsBytes();
      audioFile.deleteSync();
      wavFile.deleteSync();

      final samples = analyzer.readWavSamples(wavBytes);
      final result = detector.detect(samples, 44100);
      if (result != null && !isClosed) {
        _currentMaqam = result;
        _maqamCache[songId] = result;
        _emitCurrentState();
      }
    } catch (_) {}
  }

  void playNext() {
    final nextIndex = _currentIndex < _playList.length - 1 ? _currentIndex + 1 : 0;
    _currentIndex = nextIndex;
    loadSong(_playList, _currentIndex, _url, skipLoadingEmit: true);
  }

  void playPrevious() {
    final prevIndex = _currentIndex > 0 ? _currentIndex - 1 : _playList.length - 1;
    _currentIndex = prevIndex;
    loadSong(_playList, _currentIndex, _url, skipLoadingEmit: true);
  }

  void seekTo(Duration? duration) {
    audioPlayer.seek(duration);
  }

  void playOrpauseSong() async {
    if (audioPlayer.playing) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }
    _emitCurrentState();
  }

  void stopAndDismiss() async {
    await audioPlayer.stop();
    _emitCurrentState();
  }

  @override
  Future<void> close() async {
    _listenDurationTimer?.cancel();
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _archiveResolver.close();
    _youtubeResolver.close();
    await audioPlayer.dispose();
    return super.close();
  }
}

class _DioStreamAudioSource extends StreamAudioSource {
  final Dio _dio;
  final String _url;
  final Map<String, String>? _extraHeaders;

  _DioStreamAudioSource(this._dio, this._url, [this._extraHeaders]);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final uri = Uri.tryParse(_url);
    if (_url.isEmpty || uri == null || uri.host.isEmpty) {
      throw StateError('Invalid audio URL: $_url');
    }
    final isDeezer = _url.contains('dzcdn.net') || _url.contains('cdn-preview');
    final response = await _dio.get<Uint8List>(
      _url,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          if (start != null) 'Range': 'bytes=$start-${end != null ? end - 1 : ''}',
          if (isDeezer) 'Referer': 'https://www.deezer.com/',
          if (isDeezer) 'Origin': 'https://www.deezer.com',
          if (isDeezer) 'Accept': 'audio/mpeg,audio/*;q=0.9,*/*;q=0.8',
          ...?_extraHeaders,
        },
      ),
    );
    final contentType = response.headers.value('content-type') ?? 'audio/mpeg';
    final contentLengthHeader = response.headers.value('content-length');
    final contentLength = contentLengthHeader != null
        ? int.tryParse(contentLengthHeader)
        : response.data?.length;

    return StreamAudioResponse(
      sourceLength: response.data?.length ?? 0,
      contentLength: contentLength ?? response.data?.length ?? 0,
      stream: Stream.value(response.data ?? Uint8List(0)),
      offset: start ?? 0,
      contentType: contentType,
    );
  }
}
