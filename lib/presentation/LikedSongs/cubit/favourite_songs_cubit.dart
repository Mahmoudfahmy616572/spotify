import 'package:bloc/bloc.dart';
import 'package:spotify/data/models/songs/songs_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'favourite_songs_state.dart';

class FavouriteSongsCubit extends Cubit<FavouriteSongsState> {
  final SupabaseClient _supabase = Supabase.instance.client;
  Set<String> _favouriteSongsIds = {};
  List<SongModel> _favouriteSongsList = [];
  FavouriteSongsCubit() : super(FavouriteSongsInitial());
  bool isFavourite(String songId) => _favouriteSongsIds.contains(songId);

  Future<void> fetchFavourites() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    emit(FavouriteSongsLoading());
    try {
      final List<dynamic> response = await _supabase
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
    final userId = _supabase.auth.currentUser?.id;
    final String songId = song.id.toString();
    if (userId == null) return;

    if (state is FavouriteSongsFailure || state is FavouriteSongsInitial) {
      emit(FavouriteSongsLoaded(favouriteSongsIds: {}, favouriteSongs: []));
    }

    if (state is! FavouriteSongsLoaded) return;

    bool wasFavourite = _favouriteSongsIds.contains(songId);

    final updatedIds = Set<String>.from(_favouriteSongsIds);
    final updatedSongs = List<SongModel>.from(_favouriteSongsList);

    if (wasFavourite) {
      updatedIds.remove(songId);
      updatedSongs.removeWhere((s) => s.id.toString() == songId);
    } else {
      updatedIds.add(songId);
      updatedSongs.add(song);
    }

    _favouriteSongsIds = updatedIds;
    _favouriteSongsList = updatedSongs;

    emit(FavouriteSongsLoaded(
      favouriteSongsIds: updatedIds,
      favouriteSongs: updatedSongs,
    ));

    try {
      final int numericId = int.parse(songId);
      if (wasFavourite) {
        await _supabase.from('favourite_songs').delete().match({
          "user_id": userId,
          "song_id": numericId,
        });
      } else {
        await _supabase.from('favourite_songs').insert({
          "user_id": userId,
          "song_id": numericId,
        });
      }
    } catch (e) {
      fetchFavourites();
    }
  }

  Future<List<SongModel>> getFavouriteSongs() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];
    try {
      final response = await _supabase
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
