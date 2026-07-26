import 'package:dio/dio.dart';
import 'models/music_iwant_song_model.dart';

abstract class MusicIWantDataSource {
  Future<MusicIWantSongModel?> getSongFeatures(String title, String artist);
  Future<List<MusicIWantSongModel>> getBatchFeatures(List<Map<String, String>> songs);
  Future<List<MusicIWantSongModel>> getSimilarSongs(String title, String artist, {int limit = 10});
}

class MusicIWantDataSourceImpl implements MusicIWantDataSource {
  final Dio _dio;
  static const String _baseUrl = 'https://musiciwant.com/api/v1';

  MusicIWantDataSourceImpl()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  @override
  Future<MusicIWantSongModel?> getSongFeatures(String title, String artist) async {
    try {
      final response = await _dio.get('/song', queryParameters: {'title': title, 'artist': artist});
      return MusicIWantSongModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<MusicIWantSongModel>> getBatchFeatures(List<Map<String, String>> songs) async {
    try {
      final response = await _dio.post('/songs/batch', data: {'songs': songs});
      final items = response.data['songs'] as List<dynamic>? ?? [];
      return items
          .map((s) => MusicIWantSongModel.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<MusicIWantSongModel>> getSimilarSongs(String title, String artist, {int limit = 10}) async {
    try {
      final response = await _dio.get('/song/similar', queryParameters: {
        'title': title,
        'artist': artist,
        'limit': limit,
      });
      final items = response.data['songs'] as List<dynamic>? ?? [];
      return items
          .map((s) => MusicIWantSongModel.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
