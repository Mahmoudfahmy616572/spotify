import 'package:dio/dio.dart';

class LyricLine {
  final String text;
  final Duration startTime;
  LyricLine(this.text, this.startTime);
}

abstract class LyricsDataSource {
  Future<List<LyricLine>> fetchSyncedLyrics({
    required String trackName,
    required String artistName,
  });
}

class LyricsDataSourceImpl implements LyricsDataSource {
  final Dio _dio = Dio();

  @override
  Future<List<LyricLine>> fetchSyncedLyrics({
    required String trackName,
    required String artistName,
  }) async {
    try {
      final response = await _dio.get(
        'https://lrclib.net/api/get',
        queryParameters: {
          'track_name': trackName,
          'artist_name': artistName,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final syncedLyrics = data['syncedLyrics'] as String?;
        if (syncedLyrics != null && syncedLyrics.isNotEmpty) {
          return _parseLrcLyrics(syncedLyrics);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  List<LyricLine> _parseLrcLyrics(String lrcContent) {
    final RegExp regExp = RegExp(r'\[(\d+):(\d+)\.(\d+)\](.*)');
    final List<LyricLine> lyrics = [];

    for (var line in lrcContent.split('\n')) {
      final match = regExp.firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final milliseconds = int.parse(match.group(3)!.padRight(2, '0'));
        final text = match.group(4)!.trim();

        if (text.isNotEmpty) {
          lyrics.add(LyricLine(
            text,
            Duration(
              minutes: minutes,
              seconds: seconds,
              milliseconds: milliseconds,
            ),
          ));
        }
      }
    }
    return lyrics;
  }
}
