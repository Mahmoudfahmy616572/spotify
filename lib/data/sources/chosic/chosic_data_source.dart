import 'package:dio/dio.dart';

class ChosicSimilarSong {
  final String name;
  final String artist;
  final String? imageUrl;
  final double? energy;
  final double? happiness;
  final String? spotifyId;

  const ChosicSimilarSong({
    required this.name,
    required this.artist,
    this.imageUrl,
    this.energy,
    this.happiness,
    this.spotifyId,
  });

  factory ChosicSimilarSong.fromJson(Map<String, dynamic> json) {
    return ChosicSimilarSong(
      name: json['name']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      imageUrl: json['image']?.toString(),
      energy: (json['energy'] as num?)?.toDouble(),
      happiness: (json['happiness'] as num?)?.toDouble(),
      spotifyId: json['spotify_id']?.toString(),
    );
  }
}

abstract class ChosicDataSource {
  Future<List<ChosicSimilarSong>> getSimilarSongs(
    String name, {
    String? artist,
    double? minEnergy,
    double? maxEnergy,
    int limit = 20,
  });
}

class ChosicDataSourceImpl implements ChosicDataSource {
  final Dio _dio;
  static const String _baseUrl = 'https://parse.bot/api';

  ChosicDataSourceImpl()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  @override
  Future<List<ChosicSimilarSong>> getSimilarSongs(
    String name, {
    String? artist,
    double? minEnergy,
    double? maxEnergy,
    int limit = 20,
  }) async {
    try {
      final params = <String, dynamic>{'name': name, 'limit': limit};
      if (artist != null) params['artist'] = artist;
      if (minEnergy != null) params['min_energy'] = minEnergy;
      if (maxEnergy != null) params['max_energy'] = maxEnergy;
      final response = await _dio.get('/similar', queryParameters: params);
      final items = response.data['songs'] as List<dynamic>? ?? [];
      return items
          .map((s) => ChosicSimilarSong.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
