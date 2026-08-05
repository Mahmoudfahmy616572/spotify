import 'package:dio/dio.dart';

class ResolvedAudio {
  const ResolvedAudio({
    required this.url,
    required this.headers,
    required this.title,
  });

  final String url;
  final Map<String, String> headers;
  final String title;
}

/// Resolves full-length audio by searching YouTube through the app's
/// resolver backend (backend/main.py, powered by yt-dlp).
class YoutubeResolver {
  static const String baseUrl = String.fromEnvironment(
    'RESOLVER_URL',
    defaultValue: 'https://soundora-resolver.onrender.com',
  );

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 25),
  ));

  Future<ResolvedAudio?> resolve({
    required String title,
    required String artist,
  }) async {
    try {
      final resp = await _dio.get<Map<String, dynamic>>(
        '$baseUrl/resolve',
        queryParameters: {
          'title': title,
          'artist': artist,
        },
        options: Options(responseType: ResponseType.json),
      ).timeout(const Duration(seconds: 25));
      final data = resp.data;
      final url = data?['url'] as String?;
      if (url == null || url.isEmpty) return null;

      final rawHeaders = data?['headers'] as Map<String, dynamic>? ?? const {};
      final headers = <String, String>{};
      rawHeaders.forEach((key, value) {
        if (value is String) headers[key] = value;
      });

      return ResolvedAudio(
        url: url,
        headers: headers,
        title: data?['title'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  void close() => _dio.close(force: true);
}
