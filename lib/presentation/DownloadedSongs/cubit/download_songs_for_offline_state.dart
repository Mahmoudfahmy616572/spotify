part of 'download_songs_for_offline_cubit.dart';

@immutable
abstract class DownloadSongsForOfflineState {}

class DownloadSongsForOfflineLoading extends DownloadSongsForOfflineState {}

class DownloadSongsForOfflineLoaded extends DownloadSongsForOfflineState {
  final Map<String, double> downloads;
  final Set<String> completedIds;
  DownloadSongsForOfflineLoaded(
      {this.completedIds = const {}, this.downloads = const {}});
  DownloadSongsForOfflineLoaded copyWith(
      {Set<String>? completedIds, Map<String, double>? downloads}) {
    return DownloadSongsForOfflineLoaded(
        completedIds: completedIds ?? this.completedIds,
        downloads: downloads ?? this.downloads);
  }
}

class DownloadSongsForOfflineFailure extends DownloadSongsForOfflineState {}
