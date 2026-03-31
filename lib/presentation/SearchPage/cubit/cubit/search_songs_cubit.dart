import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:spotify/data/models/songs/songs_model.dart';
import 'package:spotify/main.dart';

part 'search_songs_state.dart';

class SearchSongsCubit extends Cubit<SearchSongsState> {
  SearchSongsCubit() : super(SearchSongsInitial());
  void searchSongs(String query) async {
    print("SEARCHING FOR: $query"); // DEBUG 1

    if (query.trim().isEmpty) {
      emit(SearchSongsInitial());
      return;
    }
    emit(SearchSongsLoading());

    try {
      final response = await supabase
          .from("Songs")
          .select()
          .or('title.ilike.%${query}%,artist.ilike.%${query}%');
      print("SUPABASE RESPONSE: $response"); // DEBUG 2

      final songs =
          (response as List).map((song) => SongModel.fromJson(song)).toList();
      emit(SearchSongsLoaded(songs));
    } catch (e) {
      print("Error searching songs: $e");
      emit(SearchSongsError(e.toString()));
    }
  }
}
