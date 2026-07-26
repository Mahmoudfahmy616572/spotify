import 'package:equatable/equatable.dart';
import 'package:spotify/data/sources/lyrics/lyrics_data_source.dart';

abstract class LyricsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LyricsInitial extends LyricsState {}

class LyricsLoading extends LyricsState {}

class LyricsLoaded extends LyricsState {
  final List<LyricLine> lyrics;
  LyricsLoaded(this.lyrics);

  @override
  List<Object?> get props => [lyrics.length];
}

class LyricsNotFound extends LyricsState {}

class LyricsFailure extends LyricsState {
  final String errorMessage;
  LyricsFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
