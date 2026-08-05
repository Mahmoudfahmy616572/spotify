import 'package:dio/dio.dart';
import 'models/verome_track_model.dart';

abstract class VeromeDataSource {
  Future<List<VeromeTrackModel>> search(String query, {int limit = 20});
  Future<String?> getStreamUrl(String videoId);
  Future<List<String>> getAllStreamUrls(String videoId);
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
      final items = response.data['results'] as List<dynamic>? ?? [];
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
      final response = await _dio.get('/stream', queryParameters: {'id': videoId});
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final urls = data['streamingUrls'] as List<dynamic>?;
        if (urls != null && urls.isNotEmpty) {
          final directUrls = <String>[];
          final proxyUrls = <String>[];
          for (final entry in urls) {
            final direct = entry['directUrl']?.toString();
            if (direct != null && direct.isNotEmpty) directUrls.add(direct);
            final proxy = entry['url']?.toString();
            if (proxy != null && proxy.isNotEmpty) proxyUrls.add(proxy);
          }
          if (directUrls.isNotEmpty) return directUrls.first;
          if (proxyUrls.isNotEmpty) return proxyUrls.first;
        }
      }
      return data['url']?.toString();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<String>> getAllStreamUrls(String videoId) async {
    try {
      final response = await _dio.get('/stream', queryParameters: {'id': videoId});
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final urls = <String>[];
        final streamingUrls = data['streamingUrls'] as List<dynamic>?;
        if (streamingUrls != null) {
          for (final entry in streamingUrls) {
            final direct = entry['directUrl']?.toString();
            if (direct != null && direct.isNotEmpty) urls.add(direct);
            final proxy = entry['url']?.toString();
            if (proxy != null && proxy.isNotEmpty) urls.add(proxy);
          }
        }
        final fallback = data['url']?.toString();
        if (fallback != null && fallback.isNotEmpty) urls.add(fallback);
        return urls;
      }
    } catch (_) {}
    return [];
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
