import 'dart:convert';

import 'package:dio/dio.dart';

/// Resolves full-length audio from the Internet Archive (archive.org) for
/// songs that Jamendo/Deezer do not carry (Arabic anasheed, tarab, classics).
class ArchiveResolver {
  static const String _searchUrl = 'https://archive.org/advancedsearch.php';
  static const String _metadataUrl = 'https://archive.org/metadata';
  static const String _downloadUrl = 'https://archive.org/download';

  static final RegExp _tokenSplit = RegExp('[\u0000-\\s\\-،,.;:()\\[\\]{}«»؟!?]+');
  static const Set<String> _stopwords = {
    'من', 'في', 'على', 'عن', 'الى', 'إلى', 'ال', 'التي', 'الذي', 'هذه',
    'هذا', 'كل', 'يا', 'بدون', 'مع', 'بين', 'ثم', 'لا', 'ما', 'منذ',
    'هو', 'هي', 'أن', 'ان', 'لو', 'و', 'وال', 'او', 'أو',
  };

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 20),
    followRedirects: true,
    maxRedirects: 5,
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/120.0 Safari/537.36',
    },
  ));

  Future<String?> searchFullSong({
    required String title,
    required String artist,
  }) async {
    final tt = _tokenize(title);
    final at = _tokenize(artist);
    if (tt.isEmpty && at.isEmpty) return null;

    final queries = <String>[
      if (tt.isNotEmpty) '"${title.trim()}"',
      if (tt.isNotEmpty && at.isNotEmpty)
        '"${tt.join(' ')}" AND (${at.join(' OR ')})',
      if (tt.isNotEmpty) tt.join(' AND '),
      if (at.isNotEmpty) at.join(' OR '),
    ];

    for (final q in queries) {
      final results = await _search(q);
      if (results.isEmpty) continue;
      final ranked = results
          .map((r) => (
                id: r.$1,
                title: r.$2,
                score: _score(r.$2, tt, at),
              ))
          .toList()
        ..sort((a, b) => b.score.compareTo(a.score));
      final strict = q.startsWith('"');
      for (final r in ranked) {
        if (!strict && r.score < 0.6) continue;
        final url = await _firstMp3Url(r.id);
        if (url != null) return url;
      }
    }
    return null;
  }

  Future<List<(String, String)>> _search(String query) async {
    try {
      final uri = Uri.parse(_searchUrl).replace(queryParameters: {
        'q': '$query AND mediatype:audio',
        'fl[]': 'identifier,title',
        'rows': '10',
        'output': 'json',
      });
      final resp = await _dio.getUri(
        uri,
        options: Options(responseType: ResponseType.bytes),
      ).timeout(const Duration(seconds: 10));
      final json =
          jsonDecode(utf8.decode(resp.data as List<int>)) as Map<String, dynamic>;
      final docs = (json['response']?['docs'] as List<dynamic>? ?? []);
      return docs.map((d) {
        final m = d as Map<String, dynamic>;
        return (m['identifier'] as String? ?? '', m['title'] as String? ?? '');
      }).where((e) => e.$1.isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }

  Future<String?> _firstMp3Url(String identifier) async {
    try {
      final resp = await _dio.get(
        '$_metadataUrl/$identifier',
        options: Options(responseType: ResponseType.bytes),
      ).timeout(const Duration(seconds: 12));
      final json =
          jsonDecode(utf8.decode(resp.data as List<int>)) as Map<String, dynamic>;
      final files = (json['files'] as List<dynamic>? ?? []);
      for (final f in files) {
        final name = (f as Map<String, dynamic>)['name'] as String? ?? '';
        if (name.toLowerCase().endsWith('.mp3')) {
          return '$_downloadUrl/$identifier/$name';
        }
      }
    } catch (_) {}
    return null;
  }

  double _score(String candidate, List<String> tt, List<String> at) {
    if (candidate.isEmpty) return 0;
    final lower = _norm(candidate);
    var titleHits = 0;
    for (final t in tt) {
      if (lower.contains(t)) titleHits++;
    }
    var artistHits = 0;
    for (final a in at) {
      if (lower.contains(a)) artistHits++;
    }
    final titleScore = tt.isEmpty ? 0 : titleHits / tt.length;
    final artistScore = at.isEmpty ? 0 : artistHits / at.length;
    return (titleScore * 0.7) + (artistScore * 0.3);
  }

  List<String> _tokenize(String input) {
    return _norm(input)
        .split(_tokenSplit)
        .where((t) => t.length >= 2 && !_stopwords.contains(t))
        .toList();
  }

  String _norm(String input) {
    return input
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp('[\u064B-\u0652\u0670\u0640]'), '')
        .toLowerCase();
  }

  void close() => _dio.close(force: true);
}
