import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class FavouriteSongsDataSource {
  Future<List<Map<String, dynamic>>> fetchFavouriteEntries(String userId);
  Future<void> insertFavourite(String userId, int songId, Map<String, dynamic> songData);
  Future<void> deleteFavourite(String userId, int songId);
}

class FavouriteSongsDataSourceImpl implements FavouriteSongsDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<Map<String, dynamic>>> fetchFavouriteEntries(String userId) async {
    try {
      final List<dynamic> response = await _supabase
          .from('favourite_songs')
          .select('song_id,songs(*)')
          .eq('user_id', userId);
      return response.cast<Map<String, dynamic>>();
    } catch (_) {
      final List<dynamic> response = await _supabase
          .from('favourite_songs')
          .select('song_id')
          .eq('user_id', userId);
      return response.cast<Map<String, dynamic>>();
    }
  }

  @override
  Future<void> insertFavourite(String userId, int songId, Map<String, dynamic> songData) async {
    try {
      await _supabase.from('Songs').upsert(songData, onConflict: 'id');
    } catch (e) {
      // Swallowing this hid the real failure behind the favourite_songs FK.
      // Surface it so the root cause is visible in logs.
      debugPrint('song upsert failed for $songId: $e');
      return;
    }

    await _supabase.from('favourite_songs').upsert({
      "user_id": userId,
      "song_id": songId,
    }, onConflict: 'user_id,song_id');
  }

  @override
  Future<void> deleteFavourite(String userId, int songId) async {
    await _supabase.from('favourite_songs').delete().match({
      "user_id": userId,
      "song_id": songId,
    });
  }
}
