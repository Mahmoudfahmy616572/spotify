part of 'song_player_cubit.dart';

@immutable
sealed class SongPlayerState {
  final int? currentIndex;
  final List<SongModel>? playlist;
  final bool? isPlaying;
  const SongPlayerState({this.currentIndex = 0, this.isPlaying, this.playlist});
  SongModel? get currentSong => playlist?[currentIndex!];
}

final class SongPlayerLoading extends SongPlayerState {}

final class SongPlayerLoaded extends SongPlayerState {}

final class SongPlayerFailure extends SongPlayerState {
  final String? errorMessage;
  SongPlayerFailure({this.errorMessage});
}
