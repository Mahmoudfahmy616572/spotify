part of 'search_songs_cubit.dart';

@immutable
sealed class SearchSongsState {}

final class SearchSongsInitial extends SearchSongsState {}

final class SearchSongsLoading extends SearchSongsState {}

final class SearchSongsLoaded extends SearchSongsState {
  final List<SongModel> songs;
  SearchSongsLoaded(this.songs);
}

final class SearchSongsError extends SearchSongsState {
  final String errorMessage;
  SearchSongsError(this.errorMessage);
}
