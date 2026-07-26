import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';
import 'package:spotify/data/models/songs/songs_model.dart';

abstract class SongPlayerState extends Equatable {
  final int? currentIndex;
  final List<SongModel>? playlist;
  final bool? isPlaying;
  const SongPlayerState({this.currentIndex = 0, this.isPlaying, this.playlist});
  SongModel? get currentSong => playlist?[currentIndex!];

  @override
  List<Object?> get props => [currentIndex, playlist, isPlaying];
}

class SongPlayerLoading extends SongPlayerState {}

class SongPlayerLoaded extends SongPlayerState {
  final bool isLyricsVisible;
  const SongPlayerLoaded({required this.isLyricsVisible});

  SongPlayerLoaded copyWith({bool? isLyricsVisible, Color? dominantColor}) {
    return SongPlayerLoaded(
      isLyricsVisible: isLyricsVisible ?? this.isLyricsVisible,
    );
  }

  @override
  List<Object?> get props => [isLyricsVisible];
}

final class SongPlayerFailure extends SongPlayerState {
  final String? errorMessage;
  const SongPlayerFailure({this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
