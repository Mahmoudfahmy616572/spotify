import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';

class LyricLine {
  final String text;
  final Duration startTime;

  LyricLine(this.text, this.startTime);

  Map<String, dynamic> toJson() => {
        'text': text,
        'ms': startTime.inMilliseconds,
      };

  factory LyricLine.fromJson(Map<String, dynamic> json) => LyricLine(
        json['text'] as String? ?? '',
        Duration(milliseconds: (json['ms'] as num?)?.toInt() ?? 0),
      );
}

abstract class LyricsDataSource {
  Future<List<LyricLine>> fetchSyncedLyrics({
    required String trackName,
    required String artistName,
  });

  Future<List<String>> fetchPlainLyrics({
    required String trackName,
    required String artistName,
  });

  Future<List<LyricLine>> fetchLyricsWithEmotion({
    required String trackName,
    required String artistName,
  });
}

class LyricsDataSourceImpl implements LyricsDataSource {
  final Dio _dio;
  final Box _cacheBox;

  static const String _lyricaBase = 'https://wilooper-lyrica.hf.space';
  static const String _lrclibBase = 'https://lrclib.net/api';

  LyricsDataSourceImpl({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
            )),
        _cacheBox = Hive.box('lyrics_cache');

  String _cacheKey(String track, String artist) =>
      '${artist.toLowerCase().trim()}_${track.toLowerCase().trim()}';

  String get _lyricaUrl => dotenv.env['LYRICA_API_URL'] ?? _lyricaBase;

  @override
  Future<List<LyricLine>> fetchSyncedLyrics({
    required String trackName,
    required String artistName,
  }) async {
    final key = _cacheKey(trackName, artistName);
    final cached = _cacheBox.get(key);
    if (cached != null) {
      try {
        final list = (jsonDecode(cached) as List)
            .map((e) => LyricLine.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) return list;
      } catch (_) {}
    }

    final lyrics = await _firstNonEmpty([
      _fetchFromLyrica(trackName, artistName),
      _fetchFromLrclib(trackName, artistName),
    ], const Duration(seconds: 8));
    if (lyrics.isNotEmpty) {
      _cacheLyrics(key, lyrics);
    }

    return lyrics;
  }

  /// Resolves as soon as any source returns non-empty lyrics, capped by [timeout].
  Future<List<LyricLine>> _firstNonEmpty(
    List<Future<List<LyricLine>>> futures,
    Duration timeout,
  ) async {
    final completer = Completer<List<LyricLine>>();
    for (final future in futures) {
      future.then((lines) {
        if (!completer.isCompleted && lines.isNotEmpty) {
          completer.complete(lines);
        }
      }).catchError((_) {});
    }
    Future.delayed(timeout).then((_) {
      if (!completer.isCompleted) completer.complete(const []);
    });
    return completer.future;
  }

  @override
  Future<List<String>> fetchPlainLyrics({
    required String trackName,
    required String artistName,
  }) async {
    try {
      final response = await _dio.get(
        '$_lyricaUrl/lyrics/',
        queryParameters: {
          'artist': artistName,
          'song': trackName,
          'timestamps': false,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success' && data['data'] != null) {
          final lyricsText = data['data']['lyrics'] as String?;
          if (lyricsText != null && lyricsText.isNotEmpty) {
            return lyricsText
                .split('\n')
                .where((l) => l.trim().isNotEmpty)
                .toList();
          }
        }
      }
    } catch (_) {}

    return [];
  }

  @override
  Future<List<LyricLine>> fetchLyricsWithEmotion({
    required String trackName,
    required String artistName,
  }) async {
    final lyrics = await fetchSyncedLyrics(
      trackName: trackName,
      artistName: artistName,
    );

    return lyrics;
  }

  Future<List<LyricLine>> _fetchFromLyrica(
      String track, String artist) async {
    try {
      final response = await _dio.get(
        '$_lyricaUrl/lyrics/',
        queryParameters: {
          'artist': artist,
          'song': track,
          'timestamps': true,
          'fast': true,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success' && data['data'] != null) {
          final lyricsData = data['data'];
          final syncedLyrics = lyricsData['synced_lyrics'] as String?;
          if (syncedLyrics != null && syncedLyrics.isNotEmpty) {
            return _parseLrcLyrics(syncedLyrics);
          }

          final plainLyrics = lyricsData['lyrics'] as String?;
          if (plainLyrics != null && plainLyrics.isNotEmpty) {
            return _generateTimestampsFromPlain(plainLyrics);
          }
        }
      }
    } catch (_) {}
    return [];
  }

  Future<List<LyricLine>> _fetchFromLrclib(
      String track, String artist) async {
    try {
      final response = await _dio.get(
        '$_lrclibBase/get',
        queryParameters: {
          'track_name': track,
          'artist_name': artist,
        },
        options: Options(
          headers: {'Accept': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final syncedLyrics = data['syncedLyrics'] as String?;
        if (syncedLyrics != null && syncedLyrics.isNotEmpty) {
          return _parseLrcLyrics(syncedLyrics);
        }

        final plainLyrics = data['plainLyrics'] as String?;
        if (plainLyrics != null && plainLyrics.isNotEmpty) {
          return _generateTimestampsFromPlain(plainLyrics);
        }
      }
    } catch (_) {}
    return [];
  }

  List<LyricLine> _generateTimestampsFromPlain(String plainText) {
    final lines = plainText
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();
    if (lines.isEmpty) return [];

    const totalDuration = Duration(minutes: 3, seconds: 30);
    final avgLineDuration = Duration(
      milliseconds: totalDuration.inMilliseconds ~/ lines.length,
    );
    final List<LyricLine> lyrics = [];
    var currentTime = Duration.zero;

    for (final line in lines) {
      lyrics.add(LyricLine(line.trim(), currentTime));
      currentTime += avgLineDuration;
    }
    return lyrics;
  }

  List<LyricLine> _parseLrcLyrics(String lrcContent) {
    final RegExp regExpMmSsMs = RegExp(r'\[(\d+):(\d+)\.(\d+)\](.*)');
    final RegExp regExpMmSs = RegExp(r'\[(\d+):(\d+)\](.*)');
    final List<LyricLine> lyrics = [];

    for (var line in lrcContent.split('\n')) {
      final match = regExpMmSsMs.firstMatch(line);
      if (match != null) {
        try {
          final minutes = int.parse(match.group(1)!);
          final seconds = int.parse(match.group(2)!);
          final milliseconds =
              int.parse(match.group(3)!.padRight(2, '0'));
          final text = match.group(4)?.trim() ?? '';

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
        } catch (_) {}
        continue;
      }

      final matchSimple = regExpMmSs.firstMatch(line);
      if (matchSimple != null) {
        try {
          final minutes = int.parse(matchSimple.group(1)!);
          final seconds = int.parse(matchSimple.group(2)!);
          final text = matchSimple.group(3)?.trim() ?? '';

          if (text.isNotEmpty) {
            lyrics.add(LyricLine(
              text,
              Duration(
                minutes: minutes,
                seconds: seconds,
              ),
            ));
          }
        } catch (_) {}
      }
    }
    return lyrics;
  }

  void _cacheLyrics(String key, List<LyricLine> lyrics) {
    try {
      final json = jsonEncode(lyrics.map((l) => l.toJson()).toList());
      _cacheBox.put(key, json);
    } catch (_) {}
  }
}
