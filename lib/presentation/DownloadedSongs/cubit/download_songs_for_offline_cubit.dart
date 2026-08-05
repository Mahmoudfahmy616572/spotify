import 'dart:io' show File;

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spotify/core/services/quran_resolver.dart';
import 'package:spotify/core/services/archive_resolver.dart';
import 'package:spotify/core/services/youtube_resolver.dart';
import 'package:spotify/data/models/songs/songs_model.dart';
import 'package:spotify/data/sources/jamendo/jamendo_data_source.dart';
import 'package:spotify/data/sources/verome/verome_data_source.dart';
import 'package:spotify/serviece_locator.dart';

import 'download_songs_for_offline_state.dart';

class DownloadSongsForOfflineCubit extends Cubit<DownloadSongsForOfflineState> {
  DownloadSongsForOfflineCubit()
      : super(DownloadSongsForOfflineLoaded(downloads: {}, completedIds: {}));

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/120.0 Safari/537.36',
    },
  ));
  final ArchiveResolver _archiveResolver = ArchiveResolver();
  final YoutubeResolver _youtubeResolver = YoutubeResolver();
  Map<String, String> _resolveHeaders = const {};

  /// Resolve the best full-song URL to download.
  ///
  /// Order matters:
  /// 1. Uploaded songs (Supabase storage) are already complete files.
  /// 2. Jamendo full CC audio — the same source used for playback, so the
  ///    downloaded song matches what the user is listening to.
  /// 3. Verome (YouTube) full audio for anything Jamendo does not have.
  /// 4. Whatever the app is currently streaming (often a 30s preview).
  Future<String?> _resolveDownloadUrl(SongModel song) async {
    _resolveHeaders = const {};
    final direct = song.urlSongsbase;
    if (direct.isNotEmpty &&
        (direct.contains('supabase.co') || direct.contains('supabase'))) {
      debugPrint('downloadSongsForOffline: direct Supabase URL');
      return direct;
    }

    final quranUrl = QuranResolver.resolve(song);
    if (quranUrl != null) {
      debugPrint('downloadSongsForOffline: Quran full recitation $quranUrl');
      return quranUrl;
    }

    if (getIt.isRegistered<JamendoDataSource>()) {
      final jamendo = getIt<JamendoDataSource>();
      final title = song.title;
      final queries = [
        '$title ${song.artist}',
        title,
      ];
      for (final q in queries) {
        try {
          debugPrint('downloadSongsForOffline: Jamendo searching "$q"');
          final results = await jamendo
              .search(q, limit: 3)
              .timeout(const Duration(seconds: 5));
          if (results.isNotEmpty) {
            debugPrint('downloadSongsForOffline: Jamendo ${results.first.audioUrl}');
            return results.first.audioUrl;
          }
        } catch (e) {
          debugPrint('downloadSongsForOffline: Jamendo error $e');
        }
      }
    }

    try {
      debugPrint(
          'downloadSongsForOffline: YouTube resolving "${song.title} ${song.artist}"');
      final yt = await _youtubeResolver.resolve(
        title: song.title,
        artist: song.artist,
      );
      if (yt != null) {
        _resolveHeaders = yt.headers;
        debugPrint('downloadSongsForOffline: YouTube ${yt.title} (${yt.url})');
        return yt.url;
      }
      debugPrint('downloadSongsForOffline: YouTube no result');
    } catch (e) {
      debugPrint('downloadSongsForOffline: YouTube error $e');
    }

    try {
      debugPrint('downloadSongsForOffline: Archive searching "${song.title} ${song.artist}"');
      final archiveUrl = await _archiveResolver.searchFullSong(
        title: song.title,
        artist: song.artist,
      );
      if (archiveUrl != null) {
        debugPrint('downloadSongsForOffline: Archive $archiveUrl');
        return archiveUrl;
      }
      debugPrint('downloadSongsForOffline: Archive no results');
    } catch (e) {
      debugPrint('downloadSongsForOffline: Archive error $e');
    }

    try {
      debugPrint(
          'downloadSongsForOffline: Verome searching "${song.title} ${song.artist}"');
      final verome = getIt<VeromeDataSource>();
      final results = await verome.search(
        '${song.title} ${song.artist}',
        limit: 3,
      );
      if (results.isNotEmpty) {
        final fullUrl = await verome.getStreamUrl(results.first.id);
        if (fullUrl != null && fullUrl.isNotEmpty) {
          debugPrint('downloadSongsForOffline: Verome $fullUrl');
          return fullUrl;
        }
      } else {
        debugPrint('downloadSongsForOffline: Verome no results');
      }
    } catch (e) {
      debugPrint('downloadSongsForOffline: Verome error $e');
    }

    return direct.isNotEmpty ? direct : null;
  }

  Future<void> downloadSongsForOffline(SongModel songs) async {
    if (state is! DownloadSongsForOfflineLoaded) return;
    final currentState = state as DownloadSongsForOfflineLoaded;
    if (currentState.downloads.containsKey(songs.id) ||
        currentState.completedIds.contains(songs.id)) {
      return;
    }

    debugPrint('downloadSongsForOffline: START ${songs.title} (${songs.id})');

    // Show the spinner immediately while the URL is being resolved.
    final started = Map<String, double>.from(currentState.downloads);
    started[songs.id] = 0.01;
    emit(currentState.copyWith(downloads: started));

    try {
      final downloadUrl = await _resolveDownloadUrl(songs);
      if (downloadUrl == null) {
        debugPrint('downloadSongsForOffline: no URL resolved for ${songs.id}');
        emit(currentState.copyWith(
            downloads: Map<String, double>.from(started)..remove(songs.id)));
        return;
      }

      debugPrint('downloadSongsForOffline: downloading from $downloadUrl');

      final directory = await getApplicationCacheDirectory();
      final String savePath = '${directory.path}/${songs.id}.mp3';
      final response = await _dio.download(
        downloadUrl,
        savePath,
        options: Options(
          headers: _resolveHeaders.isNotEmpty
              ? _resolveHeaders
              : downloadUrl.contains('dzcdn.net')
                  ? {
                      'Referer': 'https://deezer.com',
                      'Origin': 'https://deezer.com',
                    }
                  : null,
        ),
        onReceiveProgress: (count, total) {
          if (total > 0 && state is DownloadSongsForOfflineLoaded) {
            final progress = count / total;
            final latestState = state as DownloadSongsForOfflineLoaded;
            final newDownloads = Map<String, double>.from(latestState.downloads);
            newDownloads[songs.id] = progress;

            emit(latestState.copyWith(downloads: newDownloads));
          }
        },
      );

      final contentType = response.headers.value('content-type') ?? '';
      var finalPath = savePath;
      if (contentType.contains('audio/webm')) {
        finalPath = '${directory.path}/${songs.id}.webm';
      } else if (contentType.contains('audio/mp4') ||
          contentType.contains('audio/m4a')) {
        finalPath = '${directory.path}/${songs.id}.m4a';
      } else if (contentType.contains('audio/ogg')) {
        finalPath = '${directory.path}/${songs.id}.ogg';
      }
      if (finalPath != savePath && await File(finalPath).exists()) {
        await File(finalPath).delete();
      }
      if (finalPath != savePath) {
        await File(savePath).rename(finalPath);
      }
      if (state is DownloadSongsForOfflineLoaded) {
        final latestState = state as DownloadSongsForOfflineLoaded;
        final newDownloads = Map<String, double>.from(latestState.downloads);
        newDownloads.remove(songs.id);
        final newCompletedIds = Set<String>.from(latestState.completedIds);
        newCompletedIds.add(songs.id);
        final pathBox = Hive.box("offline_songs");
        await pathBox.put(songs.id, finalPath);
        final metaBox = Hive.box("songs_metadata");
        await metaBox.put(songs.id, songs.toJson());

        debugPrint('downloadSongsForOffline: DONE ${songs.title} -> $finalPath');

        emit(latestState.copyWith(
            downloads: newDownloads, completedIds: newCompletedIds));
      }
    } catch (e) {
      debugPrint('downloadSongsForOffline failed for ${songs.id}: $e');
      emit(currentState.copyWith(
          downloads: Map<String, double>.from(started)..remove(songs.id)));
    }
  }

  @override
  Future<void> close() {
    _dio.close();
    _archiveResolver.close();
    _youtubeResolver.close();
    return super.close();
  }
}
