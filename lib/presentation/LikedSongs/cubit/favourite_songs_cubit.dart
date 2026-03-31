import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:spotify/data/models/songs/songs_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'favourite_songs_state.dart';

class FavouriteSongsCubit extends Cubit<FavouriteSongsState> {
  final supabase = Supabase.instance.client;
  Set<String> _favouriteSongsIds = {};
  List<SongModel> _favouriteSongsList = [];
  FavouriteSongsCubit() : super(FavouriteSongsInitial());
  bool isFavourite(String songId) => _favouriteSongsIds.contains(songId);
  Future<void> fetchFavourits() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    emit(FavouriteSongsLoading());
    try {
      final List<dynamic> response = await supabase
          .from('favourite_songs')
          .select('song_id,songs(*)')
          .eq('user_id', userId);
      _favouriteSongsIds = response.map((f) => f['song_id'].toString()).toSet();
      _favouriteSongsList =
          response.map((item) => SongModel.fromJson(item['songs'])).toList();
      emit(FavouriteSongsLoaded(
          favouriteSongsIds: _favouriteSongsIds,
          favouriteSongs: _favouriteSongsList));
    } catch (e) {
      emit(FavouriteSongsFailure("Failed to load favorites: $e"));
    }
  }

  Future<void> toggleFavourite(SongModel song) async {
    final userId = supabase.auth.currentUser?.id;
    final String songId = song.id.toString(); // Force to String

    print("--- TOGGLE ATTEMPT ---");
    print("User: $userId | Song: $songId | State: $state");

    if (userId == null) return;

    // FIX: If state is Initial, we must allow it to toggle
    if (state is FavouriteSongsFailure || state is FavouriteSongsInitial) {
      emit(FavouriteSongsLoaded(favouriteSongsIds: {}, favouriteSongs: []));
    }

    // Now ensure we are in Loaded state
    if (state is! FavouriteSongsLoaded) {
      print("❌ BLOCKED: State is not Loaded");
      return;
    }

    final currentState = state as FavouriteSongsLoaded;
    bool wasFavourite = _favouriteSongsIds.contains(songId);

    // 1. CREATE NEW COPIES (Forcing Bloc to see a change)
    final updatedIds = Set<String>.from(_favouriteSongsIds);
    final updatedSongs = List<SongModel>.from(_favouriteSongsList);

    if (wasFavourite) {
      updatedIds.remove(songId);
      updatedSongs.removeWhere((s) => s.id.toString() == songId);
    } else {
      updatedIds.add(songId);
      updatedSongs.add(song);
    }

    // 2. Update Private Variables
    _favouriteSongsIds = updatedIds;
    _favouriteSongsList = updatedSongs;

    // 3. Emit NEW State
    emit(FavouriteSongsLoaded(
      favouriteSongsIds: updatedIds,
      favouriteSongs: updatedSongs,
    ));
    print("✅ UI UPDATED: isFav now: ${!wasFavourite}");

    try {
      final int numericId = int.parse(songId);
      if (wasFavourite) {
        await supabase.from('favourite_songs').delete().match({
          "user_id": userId,
          "song_id": numericId,
        });
      } else {
        await supabase.from('favourite_songs').insert({
          "user_id": userId,
          "song_id": numericId,
        });
      }
    } catch (e) {
      print("❌ DATABASE ERROR: $e");
      fetchFavourits(); // Rollback by re-fetching
    }
  }

  Future<List<SongModel>> getFavouriteSongs() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];
    try {
      final response = await supabase
          .from("favourite_songs")
          .select("Songs(*)")
          .eq("user_id", userId);
      final List<dynamic> data = response as List;
      return data.map((item) => SongModel.fromJson(item['songs'])).toList();
    } catch (e) {
      return [];
    }
  }
}
