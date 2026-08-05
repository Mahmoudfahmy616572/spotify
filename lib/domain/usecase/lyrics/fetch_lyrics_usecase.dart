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
      final lyricsRepo = getIt<LyricsRepository>();
      final lyrics = await lyricsRepo.fetchSyncedLyrics(
        trackName: params.trackName,
        artistName: params.artistName,
      );
      if (lyrics.isNotEmpty) {
        return Right(lyrics);
      }

      // Fallback: try plain lyrics and generate timestamps
      final lyricsDataSource = getIt<LyricsDataSource>();
      final plainLines = await lyricsDataSource.fetchPlainLyrics(
        trackName: params.trackName,
        artistName: params.artistName,
      );
      if (plainLines.isNotEmpty) {
        const totalDuration = Duration(minutes: 3, seconds: 30);
        final avgLineDuration = Duration(
          milliseconds: totalDuration.inMilliseconds ~/ plainLines.length,
        );
        final syncedLyrics = <LyricLine>[];
        var currentTime = Duration.zero;
        for (final line in plainLines) {
          syncedLyrics.add(LyricLine(line.trim(), currentTime));
          currentTime += avgLineDuration;
        }
        return Right(syncedLyrics);
      }

      return const Left("No lyrics found");
    } catch (e) {
      return Left("Failed to fetch lyrics: $e");
    }
  }
}
