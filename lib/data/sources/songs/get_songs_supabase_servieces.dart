import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/songs/songs_model.dart';

abstract class SongsSupabaseServieces {
  Future<Either> getNewSongs();
}

class SongsSupabaseServiecesimpl implements SongsSupabaseServieces {
  @override
  Future<Either> getNewSongs() async {
    try {
      final supabase = Supabase.instance.client;

      // 1. Fetch metadata from the table
      final List<Map<String, dynamic>> response = await supabase
          .from('Songs') // Your table name
          .select('*')
          .order('id', ascending: false);
      // 2. Map JSON to Song objects and generate public URLs
      final songs = response.map((json) {
        final song = SongModel.fromJson(json);

        // Generate the actual playable URL from Storage bucket
        final String publicSongsUrl;
        if (song.urlSongsbase.startsWith('http')) {
          publicSongsUrl = song.urlSongsbase; // It's already a full URL!
        } else {
          publicSongsUrl =
              supabase.storage.from('songs').getPublicUrl(song.urlSongsbase);
        }

        final String publicImageUrl;
        if (song.imageUrl.startsWith('http')) {
          publicImageUrl = song.imageUrl; // It's already a full URL!
        } else {
          publicImageUrl =
              supabase.storage.from('covers').getPublicUrl(song.imageUrl);
        }

        return SongModel(
          id: song.id,
          title: song.title,
          artist: song.artist,
          urlSongsbase: publicSongsUrl,
          imageUrl: publicImageUrl,
          duration: song.duration,
          releaseDate: song.releaseDate,
          lyrics: song.lyrics,
        );
      }).toList();
      return Right(songs);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
