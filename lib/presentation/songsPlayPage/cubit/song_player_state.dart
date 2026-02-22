part of 'song_player_cubit.dart';

@immutable
abstract class SongPlayerState {
  final int? currentIndex;
  final List<SongModel>? playlist;
  final bool? isPlaying;
  const SongPlayerState({this.currentIndex = 0, this.isPlaying, this.playlist});
  SongModel? get currentSong => playlist?[currentIndex!];
}

class SongPlayerLoading extends SongPlayerState {}

// ignore: must_be_immutable
class SongPlayerLoaded extends SongPlayerState {
  bool isLyricsVisable;
  SongPlayerLoaded({required this.isLyricsVisable});
  SongPlayerLoaded copyWith({bool? isLyricsVisible}) {
    return SongPlayerLoaded(
      isLyricsVisable: isLyricsVisible ?? this.isLyricsVisable,
    );
  }
}

final class SongPlayerFailure extends SongPlayerState {
  final String? errorMessage;
  const SongPlayerFailure({this.errorMessage});
}
