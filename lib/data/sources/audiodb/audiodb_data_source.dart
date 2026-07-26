import 'package:dio/dio.dart';
import 'models/audiodb_video_model.dart';
import 'models/audiodb_artist_model.dart';

abstract class AudioDbDataSource {
  Future<List<AudioDbVideoModel>> getMusicVideos(String artistName);
  Future<AudioDbArtistModel?> searchArtist(String name);
  Future<AudioDbArtistModel?> getArtistById(String id);
}

class AudioDbDataSourceImpl implements AudioDbDataSource {
  final Dio _dio;
  static const String _baseUrl = 'https://www.theaudiodb.com/api/v1/json/123';

  AudioDbDataSourceImpl()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  @override
  Future<List<AudioDbVideoModel>> getMusicVideos(String artistName) async {
    try {
      final artist = await searchArtist(artistName);
      if (artist == null) return [];
      final response = await _dio.get('/mvid.php', queryParameters: {'i': artist.id});
      final mvids = response.data['mvids'] as List<dynamic>? ?? [];
      return mvids
          .map((m) => AudioDbVideoModel.fromJson(m as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<AudioDbArtistModel?> searchArtist(String name) async {
    try {
      final response = await _dio.get('/search.php', queryParameters: {'s': name});
      final artists = response.data['artists'] as List<dynamic>? ?? [];
      if (artists.isEmpty) return null;
      return AudioDbArtistModel.fromJson(artists.first as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AudioDbArtistModel?> getArtistById(String id) async {
    try {
      final response = await _dio.get('/artist.php', queryParameters: {'i': id});
      final artists = response.data['artists'] as List<dynamic>? ?? [];
      if (artists.isEmpty) return null;
      return AudioDbArtistModel.fromJson(artists.first as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
