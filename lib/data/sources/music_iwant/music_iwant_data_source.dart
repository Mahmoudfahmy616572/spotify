import 'package:dio/dio.dart';
import 'models/music_iwant_song_model.dart';

abstract class MusicIWantDataSource {
  Future<MusicIWantSongModel?> getSongFeatures(String title, String artist);
  Future<List<MusicIWantSongModel>> getBatchFeatures(List<Map<String, String>> songs);
  Future<List<MusicIWantSongModel>> getSimilarSongs(String title, String artist, {int limit = 10});
}

class MusicIWantDataSourceImpl implements MusicIWantDataSource {
  final Dio _dio;

  MusicIWantDataSourceImpl()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ));

  @override
  Future<MusicIWantSongModel?> getSongFeatures(String title, String artist) async {
    try {
      final mbid = await _searchMusicBrainz(title, artist);
      if (mbid == null) return null;

      final highLevel = await _fetchHighLevel(mbid);
      final lowLevel = await _fetchLowLevel(mbid);

      if (highLevel == null) return null;

      return _mapToModel(title, artist, highLevel, lowLevel);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _searchMusicBrainz(String title, String artist) async {
    final query = 'artist:"${artist.replaceAll('"', '')}" AND recording:"${title.replaceAll('"', '')}"';
    final response = await _dio.get(
      'https://musicbrainz.org/ws/2/recording',
      queryParameters: {'query': query, 'fmt': 'json', 'limit': 1},
      options: Options(
        headers: {
          'User-Agent': 'Soundora/1.0 (flutter-app)',
          'Accept': 'application/json',
        },
      ),
    );

    final recordings = response.data['recordings'] as List<dynamic>?;
    if (recordings == null || recordings.isEmpty) return null;

    final recording = recordings[0] as Map<String, dynamic>;
    final id = recording['id'] as String?;
    return id;
  }

  Future<Map<String, dynamic>?> _fetchHighLevel(String mbid) async {
    try {
      final response = await _dio.get('https://acousticbrainz.org/api/v1/$mbid/high-level');
      return response.data as Map<String, dynamic>?;
    } on DioException {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _fetchLowLevel(String mbid) async {
    try {
      final response = await _dio.get('https://acousticbrainz.org/api/v1/$mbid/low-level');
      return response.data as Map<String, dynamic>?;
    } on DioException {
      return null;
    }
  }

  MusicIWantSongModel _mapToModel(
    String title,
    String artist,
    Map<String, dynamic> highLevel,
    Map<String, dynamic>? lowLevel,
  ) {
    final hl = highLevel['highlevel'] as Map<String, dynamic>? ?? {};

    double prob(String category, String label) {
      final cat = hl[category] as Map<String, dynamic>?;
      if (cat == null) return 0.0;
      final all = cat['all'] as Map<String, dynamic>?;
      if (all == null) return 0.0;
      return (all[label] as num?)?.toDouble() ?? 0.0;
    }

    final danceability = prob('danceability', 'danceable');
    final acousticness = prob('mood_acoustic', 'acoustic');
    final aggressive = prob('mood_aggressive', 'aggressive');
    final happy = prob('mood_happy', 'happy');
    final electronic = prob('mood_electronic', 'electronic');
    final relaxed = prob('mood_relaxed', 'relaxed');
    final sad = prob('mood_sad', 'sad');
    final party = prob('mood_party', 'party');
    final instrumental = prob('voice_instrumental', 'instrumental');

    final energy = ((aggressive + happy + party + electronic) / 4).clamp(0.0, 1.0);
    final intensityScore = ((aggressive + electronic) / 2).clamp(0.0, 1.0);

    final moods = {
      if (happy > 0.5) 'happy': happy,
      if (sad > 0.5) 'sad': sad,
      if (relaxed > 0.5) 'relaxed': relaxed,
      if (aggressive > 0.5) 'aggressive': aggressive,
      if (party > 0.5) 'party': party,
      if (acousticness > 0.5) 'acoustic': acousticness,
      if (instrumental > 0.5) 'instrumental': instrumental,
    };
    final mood = moods.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final moodStr = mood.isNotEmpty ? mood.first.key : 'neutral';
    final isInstrumental = instrumental > 0.6;

    double? bpm;
    if (lowLevel != null) {
      final rhythm = lowLevel['rhythm'] as Map<String, dynamic>?;
      bpm = (rhythm?['bpm'] as num?)?.toDouble();
    }

    return MusicIWantSongModel(
      title: title,
      artist: artist,
      bpm: bpm,
      energy: double.parse(energy.toStringAsFixed(2)),
      intensityScore: double.parse(intensityScore.toStringAsFixed(2)),
      mood: moodStr,
      recommendedUse: isInstrumental ? 'Background / Focus' : _recommendedUse(energy, danceability, happy, relaxed),
      danceability: double.parse(danceability.toStringAsFixed(2)),
      acousticness: double.parse(acousticness.toStringAsFixed(2)),
    );
  }

  String _recommendedUse(double energy, double danceability, double happy, double relaxed) {
    if (energy > 0.7 && danceability > 0.7) return 'Workout / Party';
    if (energy > 0.7) return 'Gym / High Energy';
    if (relaxed > 0.6) return 'Study / Relax';
    if (happy > 0.6) return 'Morning / Chill';
    if (danceability > 0.6) return 'Dance / Groove';
    return 'Casual Listening';
  }

  @override
  Future<List<MusicIWantSongModel>> getBatchFeatures(List<Map<String, String>> songs) async {
    final results = <MusicIWantSongModel>[];
    for (final song in songs) {
      final features = await getSongFeatures(song['title'] ?? '', song['artist'] ?? '');
      if (features != null) results.add(features);
    }
    return results;
  }

  @override
  Future<List<MusicIWantSongModel>> getSimilarSongs(String title, String artist, {int limit = 10}) async {
    return [];
  }
}
