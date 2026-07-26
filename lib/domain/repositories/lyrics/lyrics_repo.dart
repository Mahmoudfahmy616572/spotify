import 'package:spotify/data/sources/lyrics/lyrics_data_source.dart';

abstract class LyricsRepository {
  Future<List<LyricLine>> fetchSyncedLyrics({
    required String trackName,
    required String artistName,
  });
}

class LyricsRepositoryImpl implements LyricsRepository {
  final LyricsDataSource _lyricsDataSource;

  LyricsRepositoryImpl({LyricsDataSource? lyricsDataSource})
      : _lyricsDataSource = lyricsDataSource ?? LyricsDataSourceImpl();

  @override
  Future<List<LyricLine>> fetchSyncedLyrics({
    required String trackName,
    required String artistName,
  }) async {
    return await _lyricsDataSource.fetchSyncedLyrics(
      trackName: trackName,
      artistName: artistName,
    );
  }
}
