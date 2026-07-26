import 'package:equatable/equatable.dart';

abstract class DownloadSongsForOfflineState extends Equatable {
  @override
  List<Object?> get props => [];
}

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

  @override
  List<Object?> get props => [downloads, completedIds];
}

class DownloadSongsForOfflineFailure extends DownloadSongsForOfflineState {}
