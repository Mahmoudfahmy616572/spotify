import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spotify/data/models/songs/songs_model.dart';

part 'download_songs_for_offline_state.dart';

class DownloadSongsForOfflineCubit extends Cubit<DownloadSongsForOfflineState> {
  DownloadSongsForOfflineCubit()
      : super(DownloadSongsForOfflineLoaded(downloads: {}, completedIds: {}));

  final Dio _dio = Dio();

  Future<void> downloadSongsForOffline(SongModel songs) async {
    if (state is! DownloadSongsForOfflineLoaded) return;
    final currentState = state as DownloadSongsForOfflineLoaded;
    if (currentState.downloads.containsKey(songs.id) ||
        currentState.completedIds.contains(songs.id)) {
      return;
    }
    try {
      final directory = await getApplicationCacheDirectory();
      final String savePath = '${directory.path}/${songs.id}.mp3';
      await _dio.download(
        songs.urlSongsbase,
        savePath,
        onReceiveProgress: (count, total) {
          if (total != -1 && state is DownloadSongsForOfflineLoaded) {
            final progress = count / total;
            final latestState = state as DownloadSongsForOfflineLoaded;
            final newDownloads =
                Map<String, double>.from(latestState.downloads);
            newDownloads[songs.id] = progress;

            emit(latestState.copyWith(downloads: newDownloads));
          }
        },
      );
      if (state is DownloadSongsForOfflineLoaded) {
        final latestState = state as DownloadSongsForOfflineLoaded;
        final newDownloads = Map<String, double>.from(latestState.downloads);
        newDownloads.remove(songs.id);
        final newCompletedIds = Set<String>.from(latestState.completedIds);
        newCompletedIds.add(songs.id);
        final box = Hive.box("offline_songs");
        await box.put(songs.id, savePath);
        emit(latestState.copyWith(
            downloads: newDownloads, completedIds: newCompletedIds));
      }
    } catch (e) {
      print("Downloaded failed: $e");
    }
  }
}
