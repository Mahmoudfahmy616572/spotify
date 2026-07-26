import 'package:dio/dio.dart';
import 'models/wolfxspotify_track_model.dart';
import 'models/wolfxspotify_artist_model.dart';
import 'models/wolfxspotify_album_model.dart';

abstract class WolfXSpotifyDataSource {
  Future<List<WolfXSpotifyTrackModel>> searchTracks(String query, {int limit = 20});
  Future<WolfXSpotifyTrackModel?> getTrack(String id);
  Future<WolfXSpotifyArtistModel?> getArtist(String id);
  Future<List<WolfXSpotifyTrackModel>> getArtistTopTracks(String id);
  Future<WolfXSpotifyAlbumModel?> getAlbum(String id);
}

class WolfXSpotifyDataSourceImpl implements WolfXSpotifyDataSource {
  final Dio _dio;
  static const String _baseUrl = 'https://spotify.xwolf.space/api';

  WolfXSpotifyDataSourceImpl()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  @override
  Future<List<WolfXSpotifyTrackModel>> searchTracks(String query, {int limit = 20}) async {
    try {
      final response = await _dio.get('/search', queryParameters: {'q': query, 'type': 'track', 'limit': limit});
      final items = response.data['tracks']?['items'] as List<dynamic>? ?? [];
      return items
          .map((t) => WolfXSpotifyTrackModel.fromJson(t as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<WolfXSpotifyTrackModel?> getTrack(String id) async {
    try {
      final response = await _dio.get('/track/$id');
      return WolfXSpotifyTrackModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<WolfXSpotifyArtistModel?> getArtist(String id) async {
    try {
      final response = await _dio.get('/artist/$id');
      return WolfXSpotifyArtistModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<WolfXSpotifyTrackModel>> getArtistTopTracks(String id) async {
    try {
      final response = await _dio.get('/artist/$id/top', queryParameters: {'limit': 10});
      final items = response.data['tracks'] as List<dynamic>? ?? [];
      return items
          .map((t) => WolfXSpotifyTrackModel.fromJson(t as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<WolfXSpotifyAlbumModel?> getAlbum(String id) async {
    try {
      final response = await _dio.get('/album/$id');
      return WolfXSpotifyAlbumModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
