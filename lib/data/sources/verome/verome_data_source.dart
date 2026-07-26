import 'package:dio/dio.dart';
import 'models/verome_track_model.dart';

abstract class VeromeDataSource {
  Future<List<VeromeTrackModel>> search(String query, {int limit = 20});
  Future<String?> getStreamUrl(String videoId);
  Future<List<VeromeTrackModel>> getCharts(String countryCode);
  Future<List<VeromeTrackModel>> getTrending({String? countryCode});
}

class VeromeDataSourceImpl implements VeromeDataSource {
  final Dio _dio;
  static const String _baseUrl = 'https://verome-api.deno.dev/api';

  VeromeDataSourceImpl()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ));

  @override
  Future<List<VeromeTrackModel>> search(String query, {int limit = 20}) async {
    try {
      final response = await _dio.get('/search', queryParameters: {'q': query, 'limit': limit});
      final items = response.data['data'] as List<dynamic>? ?? [];
      return items
          .map((t) => VeromeTrackModel.fromJson(t as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<String?> getStreamUrl(String videoId) async {
    try {
      final response = await _dio.get('/stream/$videoId');
      return response.data['url']?.toString();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<VeromeTrackModel>> getCharts(String countryCode) async {
    try {
      final response = await _dio.get('/charts', queryParameters: {'country': countryCode});
      final items = response.data['data'] as List<dynamic>? ?? [];
      return items
          .map((t) => VeromeTrackModel.fromJson(t as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<VeromeTrackModel>> getTrending({String? countryCode}) async {
    try {
      final response = await _dio.get('/trending', queryParameters: {
        if (countryCode != null) 'country': countryCode,
      });
      final items = response.data['data'] as List<dynamic>? ?? [];
      return items
          .map((t) => VeromeTrackModel.fromJson(t as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
