import 'package:dartz/dartz.dart';
import 'package:spotify/data/sources/lyrics/lyrics_data_source.dart';
import 'package:spotify/domain/repositories/lyrics/lyrics_repo.dart';
import 'package:spotify/serviece_locator.dart';

class LyricsParams {
  final String trackName;
  final String artistName;
  LyricsParams({required this.trackName, required this.artistName});
}

class FetchLyricsUsecase {
  Future<Either<String, List<LyricLine>>> call({
    required LyricsParams params,
  }) async {
    try {
      final lyrics = await getIt<LyricsRepository>().fetchSyncedLyrics(
        trackName: params.trackName,
        artistName: params.artistName,
      );
      if (lyrics.isNotEmpty) {
        return Right(lyrics);
      } else {
        return const Left("No synced lyrics found");
      }
    } catch (e) {
      return Left("Failed to fetch lyrics: $e");
    }
  }
}
