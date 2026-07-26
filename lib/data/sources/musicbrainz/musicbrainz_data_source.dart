import 'package:dio/dio.dart';

class MusicBrainzRelease {
  final String id;
  final String title;
  final String? artist;
  final String? date;
  final String? barcode;
  final String? coverArtUrl;

  const MusicBrainzRelease({
    required this.id,
    required this.title,
    this.artist,
    this.date,
    this.barcode,
    this.coverArtUrl,
  });

  factory MusicBrainzRelease.fromJson(Map<String, dynamic> json) {
    final artists = json['artist-credit'] as List<dynamic>? ?? [];
    return MusicBrainzRelease(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      artist: artists.isNotEmpty ? artists.first['name']?.toString() : null,
      date: json['date']?.toString(),
      barcode: json['barcode']?.toString(),
    );
  }
}

abstract class MusicBrainzDataSource {
  Future<MusicBrainzRelease?> lookupByIsrc(String isrc);
  Future<List<MusicBrainzRelease>> searchRelease(String query, {int limit = 5});
}

class MusicBrainzDataSourceImpl implements MusicBrainzDataSource {
  final Dio _dio;
  static const String _baseUrl = 'https://musicbrainz.org/ws/2';

  MusicBrainzDataSourceImpl()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          headers: {'User-Agent': 'Soundora/1.0 (soundora@app.com)'},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  @override
  Future<MusicBrainzRelease?> lookupByIsrc(String isrc) async {
    try {
      final response = await _dio.get('/recording', queryParameters: {
        'query': 'isrc:$isrc',
        'fmt': 'json',
        'limit': 1,
      });
      final recordings = response.data['recordings'] as List<dynamic>? ?? [];
      if (recordings.isEmpty) return null;
      final recording = recordings.first;
      final releases = recording['releases'] as List<dynamic>? ?? [];
      if (releases.isEmpty) return null;
      return MusicBrainzRelease.fromJson(releases.first as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<MusicBrainzRelease>> searchRelease(String query, {int limit = 5}) async {
    try {
      final response = await _dio.get('/release', queryParameters: {
        'query': query,
        'fmt': 'json',
        'limit': limit,
      });
      final releases = response.data['releases'] as List<dynamic>? ?? [];
      return releases
          .map((r) => MusicBrainzRelease.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
