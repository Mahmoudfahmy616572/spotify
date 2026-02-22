import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'favourite_songs_state.dart';

class FavouriteSongsCubit extends Cubit<FavouriteSongsState> {
  final supabase = Supabase.instance.client;
  Set<String> _favouriteSongsIds = {};
  FavouriteSongsCubit() : super(FavouriteSongsInitial());
  bool isFavourite(String songId) => _favouriteSongsIds.contains(songId);
  Future<void> fetchFavourits() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    emit(FavouriteSongsLoading());
    try {
      final List<dynamic> response = await supabase
          .from('favourite_songs')
          .select('song_id')
          .eq('user_id', userId);
      _favouriteSongsIds = response.map((f) => f['song_id'].toString()).toSet();
      emit(FavouriteSongsLoaded(favouriteSongsIds: _favouriteSongsIds));
    } catch (e) {
      emit(FavouriteSongsFailure("Failed to load favorites: $e"));
    }
  }

  Future<void> toggleFavourite(String songId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    if (songId.isEmpty) {
      print("Error: songId is empty!");
      return;
    } else {
      print("Toggling favourite for songId: $songId");
    }
    bool wasFavourite = _favouriteSongsIds.contains(songId);
    //for ui update
    if (wasFavourite) {
      _favouriteSongsIds.remove(songId);
    } else {
      _favouriteSongsIds.add(songId);
    }
    emit(FavouriteSongsLoaded(favouriteSongsIds: Set.from(_favouriteSongsIds)));

    try {
      final int numericSongId = int.parse(songId);
      //for supabase update
      if (wasFavourite) {
        await supabase.from('favourite_songs').delete().match({
          "user_id": userId,
          "song_id": numericSongId,
        });
      } else {
        await supabase.from('favourite_songs').insert({
          "user_id": userId,
          "song_id": numericSongId,
        });
      }
    } catch (e) {
      if (e is PostgrestException) {
        // Look for message: "invalid input syntax for type uuid"
        print("Supabase Error: ${e.message}");
        print("Supabase Details: ${e.details}");
      } else {
        print("Unexpected error: $e");
        if (wasFavourite) {
          _favouriteSongsIds.add(songId);
        } else {
          _favouriteSongsIds.remove(songId);
        }
        emit(FavouriteSongsLoaded(
            favouriteSongsIds: Set.from(_favouriteSongsIds)));
      }
    }
  }
}
