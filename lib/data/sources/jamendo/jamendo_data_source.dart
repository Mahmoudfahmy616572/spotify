import 'package:dio/dio.dart';
import 'models/jamendo_track_model.dart';

abstract class JamendoDataSource {
  Future<List<JamendoTrackModel>> search(String query, {int limit = 20, int offset = 0});
  Future<List<JamendoTrackModel>> getPopular({int limit = 20, String? tag});
  Future<List<JamendoTrackModel>> getNewReleases({int limit = 20});
  Future<List<JamendoTrackModel>> getRadio(String radioName, {int limit = 20});
  Future<String?> getStreamUrl(int trackId);
}

class JamendoDataSourceImpl implements JamendoDataSource {
  final Dio _dio;
  final String _clientId;
  static const String _baseUrl = 'https://api.jamendo.com/v3.0';

  JamendoDataSourceImpl({required String clientId})
      : _clientId = clientId,
        _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ));

  Map<String, dynamic> _baseParams({Map<String, String>? extra}) {
    return {
      'client_id': _clientId,
      'format': 'json',
      ...?extra,
    };
  }

  List<JamendoTrackModel> _parseTracks(dynamic data) {
    final results = data?['results'] as List<dynamic>? ?? [];
    return results
        .map((t) => JamendoTrackModel.fromJson(t as Map<String, dynamic>))
        .where((t) => t.audioUrl.isNotEmpty)
        .toList();
  }

  @override
  Future<List<JamendoTrackModel>> search(String query, {int limit = 20, int offset = 0}) async {
    try {
      final response = await _dio.get('/tracks', queryParameters: _baseParams(extra: {
        'search': query,
        'limit': limit.toString(),
        'offset': offset.toString(),
        'audioformat': 'mp32',
        'include': 'musicinfo',
      }));
      return _parseTracks(response.data);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<JamendoTrackModel>> getPopular({int limit = 20, String? tag}) async {
    try {
      final params = _baseParams(extra: {
        'limit': limit.toString(),
        'order': 'popularity_total_desc',
        'audioformat': 'mp32',
      });
      if (tag != null) params['tags'] = tag;
      final response = await _dio.get('/tracks', queryParameters: params);
      return _parseTracks(response.data);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<JamendoTrackModel>> getNewReleases({int limit = 20}) async {
    try {
      final response = await _dio.get('/tracks', queryParameters: _baseParams(extra: {
        'limit': limit.toString(),
        'order': 'releasedate_desc',
        'audioformat': 'mp32',
      }));
      return _parseTracks(response.data);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<JamendoTrackModel>> getRadio(String radioName, {int limit = 20}) async {
    try {
      final response = await _dio.get('/radios/stream', queryParameters: _baseParams(extra: {
        'name': radioName,
      }));
      final streamUrl = response.data?['results']?[0]?['stream'] as String?;
      if (streamUrl != null && streamUrl.isNotEmpty) {
        return [JamendoTrackModel(
          id: 0,
          name: radioName,
          artistName: 'Radio',
          artistId: 0,
          audioUrl: streamUrl,
          imageUrl: '',
          duration: Duration.zero,
        )];
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<String?> getStreamUrl(int trackId) async {
    try {
      final response = await _dio.get('/tracks/file', queryParameters: {
        'client_id': _clientId,
        'id': trackId.toString(),
        'action': 'stream',
        'audioformat': 'mp32',
      });
      return response.data?.toString();
    } catch (_) {
      return null;
    }
  }
}
