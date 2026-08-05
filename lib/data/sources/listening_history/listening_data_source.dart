import 'dart:convert';

import 'package:hive/hive.dart';

abstract class ListeningDataSource {
  Future<void> recordSearch(String query);
  List<String> getSearchHistory({int limit = 20});
  Future<void> clearSearchHistory();

  Future<void> recordPlayEvent(PlayEvent event);
  List<PlayEvent> getPlayEvents({int limit = 200});

  Future<void> recordSkip(String songId, String title, String artist, Duration listenedDuration);
  List<SkipRecord> getSkipRecords({int limit = 200});

  Future<void> recordListenDuration(String songId, String title, String artist, Duration duration, Duration totalDuration);
  Map<String, ListenStats> getAllListenStats();

  Future<void> clearAll();
}

class PlayEvent {
  final String songId;
  final String title;
  final String artist;
  final DateTime timestamp;
  final Duration listenedDuration;
  final Duration totalDuration;
  final bool wasSkipped;

  PlayEvent({
    required this.songId,
    required this.title,
    required this.artist,
    required this.timestamp,
    required this.listenedDuration,
    required this.totalDuration,
    required this.wasSkipped,
  });

  double get completionRatio {
    if (totalDuration.inSeconds == 0) return 0;
    return listenedDuration.inSeconds / totalDuration.inSeconds;
  }

  Map<String, dynamic> toJson() => {
        'songId': songId,
        'title': title,
        'artist': artist,
        'timestamp': timestamp.toIso8601String(),
        'listenedDuration': listenedDuration.inMilliseconds,
        'totalDuration': totalDuration.inMilliseconds,
        'wasSkipped': wasSkipped,
      };

  factory PlayEvent.fromJson(Map<String, dynamic> json) => PlayEvent(
        songId: json['songId'] ?? '',
        title: json['title'] ?? '',
        artist: json['artist'] ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        listenedDuration: Duration(milliseconds: json['listenedDuration'] ?? 0),
        totalDuration: Duration(milliseconds: json['totalDuration'] ?? 0),
        wasSkipped: json['wasSkipped'] ?? false,
      );
}

class SkipRecord {
  final String songId;
  final String title;
  final String artist;
  final DateTime timestamp;
  final Duration listenedBeforeSkip;

  SkipRecord({
    required this.songId,
    required this.title,
    required this.artist,
    required this.timestamp,
    required this.listenedBeforeSkip,
  });

  Map<String, dynamic> toJson() => {
        'songId': songId,
        'title': title,
        'artist': artist,
        'timestamp': timestamp.toIso8601String(),
        'listenedBeforeSkip': listenedBeforeSkip.inMilliseconds,
      };

  factory SkipRecord.fromJson(Map<String, dynamic> json) => SkipRecord(
        songId: json['songId'] ?? '',
        title: json['title'] ?? '',
        artist: json['artist'] ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        listenedBeforeSkip: Duration(milliseconds: json['listenedBeforeSkip'] ?? 0),
      );
}

class ListenStats {
  final String songId;
  final String title;
  final String artist;
  int playCount;
  Duration totalListened;
  Duration totalDuration;
  int skipCount;

  ListenStats({
    required this.songId,
    required this.title,
    required this.artist,
    this.playCount = 0,
    this.totalListened = Duration.zero,
    this.totalDuration = Duration.zero,
    this.skipCount = 0,
  });

  double get averageCompletion {
    if (playCount == 0 || totalDuration.inSeconds == 0) return 0;
    return totalListened.inSeconds / (playCount * totalDuration.inSeconds);
  }

  bool get isFavourite => playCount >= 3 && averageCompletion > 0.6;
  bool get isSkippedOften => skipCount >= 2 && playCount > 0 && skipCount / playCount > 0.5;

  Map<String, dynamic> toJson() => {
        'songId': songId,
        'title': title,
        'artist': artist,
        'playCount': playCount,
        'totalListened': totalListened.inMilliseconds,
        'totalDuration': totalDuration.inMilliseconds,
        'skipCount': skipCount,
      };

  factory ListenStats.fromJson(Map<String, dynamic> json) => ListenStats(
        songId: json['songId'] ?? '',
        title: json['title'] ?? '',
        artist: json['artist'] ?? '',
        playCount: json['playCount'] ?? 0,
        totalListened: Duration(milliseconds: json['totalListened'] ?? 0),
        totalDuration: Duration(milliseconds: json['totalDuration'] ?? 0),
        skipCount: json['skipCount'] ?? 0,
      );
}

class ListeningDataSourceImpl implements ListeningDataSource {
  static const String _searchBox = 'search_history';
  static const String _playEventsBox = 'play_events';
  static const String _skipRecordsBox = 'skip_records';
  static const String _listenStatsBox = 'listen_stats';

  static const int _maxSearchHistory = 30;
  static const int _maxPlayEvents = 200;
  static const int _maxSkipRecords = 200;

  Box get _searchBoxRef => Hive.box(_searchBox);
  Box get _playEventsBoxRef => Hive.box(_playEventsBox);
  Box get _skipRecordsBoxRef => Hive.box(_skipRecordsBox);
  Box get _listenStatsBoxRef => Hive.box(_listenStatsBox);

  @override
  Future<void> recordSearch(String query) async {
    if (query.trim().isEmpty) return;
    final searches = _searchBoxRef.get('queries', defaultValue: <String>[]) as List;
    searches.remove(query);
    searches.insert(0, query);
    if (searches.length > _maxSearchHistory) {
      searches.removeRange(_maxSearchHistory, searches.length);
    }
    await _searchBoxRef.put('queries', searches);
  }

  @override
  List<String> getSearchHistory({int limit = 20}) {
    final searches = _searchBoxRef.get('queries', defaultValue: <String>[]) as List;
    return searches.take(limit).map((e) => e.toString()).toList();
  }

  @override
  Future<void> clearSearchHistory() async {
    await _searchBoxRef.put('queries', <String>[]);
  }

  @override
  Future<void> recordPlayEvent(PlayEvent event) async {
    final raw = _playEventsBoxRef.get('events', defaultValue: <String>[]) as List;
    final events = raw.map((e) => jsonDecode(e.toString())).toList();

    events.insert(0, event.toJson());

    if (events.length > _maxPlayEvents) {
      events.removeRange(_maxPlayEvents, events.length);
    }

    final encoded = events.map((e) => jsonEncode(e)).toList();
    await _playEventsBoxRef.put('events', encoded);

    await _updateListenStats(event);
  }

  @override
  List<PlayEvent> getPlayEvents({int limit = 200}) {
    final raw = _playEventsBoxRef.get('events', defaultValue: <String>[]) as List;
    return raw
        .take(limit)
        .map((e) => PlayEvent.fromJson(jsonDecode(e.toString())))
        .toList();
  }

  @override
  Future<void> recordSkip(String songId, String title, String artist, Duration listenedDuration) async {
    final record = SkipRecord(
      songId: songId,
      title: title,
      artist: artist,
      timestamp: DateTime.now(),
      listenedBeforeSkip: listenedDuration,
    );

    final raw = _skipRecordsBoxRef.get('skips', defaultValue: <String>[]) as List;
    final skips = raw.map((e) => jsonDecode(e.toString())).toList();
    skips.insert(0, record.toJson());

    if (skips.length > _maxSkipRecords) {
      skips.removeRange(_maxSkipRecords, skips.length);
    }

    final encoded = skips.map((e) => jsonEncode(e)).toList();
    await _skipRecordsBoxRef.put('skips', encoded);

    final stats = _getStatsForSong(songId, title, artist);
    stats.skipCount++;
    await _saveStats(stats);
  }

  @override
  List<SkipRecord> getSkipRecords({int limit = 200}) {
    final raw = _skipRecordsBoxRef.get('skips', defaultValue: <String>[]) as List;
    return raw
        .take(limit)
        .map((e) => SkipRecord.fromJson(jsonDecode(e.toString())))
        .toList();
  }

  @override
  Future<void> recordListenDuration(
      String songId, String title, String artist, Duration duration, Duration totalDuration) async {
    final stats = _getStatsForSong(songId, title, artist);
    stats.totalListened += duration;
    stats.totalDuration = totalDuration;
    await _saveStats(stats);
  }

  @override
  Map<String, ListenStats> getAllListenStats() {
    final raw = _listenStatsBoxRef.get('stats', defaultValue: <String>[]) as List;
    final map = <String, ListenStats>{};
    for (final item in raw) {
      final stats = ListenStats.fromJson(jsonDecode(item.toString()));
      map[stats.songId] = stats;
    }
    return map;
  }

  @override
  Future<void> clearAll() async {
    await _searchBoxRef.clear();
    await _playEventsBoxRef.clear();
    await _skipRecordsBoxRef.clear();
    await _listenStatsBoxRef.clear();
  }

  ListenStats _getStatsForSong(String songId, String title, String artist) {
    final raw = _listenStatsBoxRef.get('stats', defaultValue: <String>[]) as List;
    for (final item in raw) {
      final stats = ListenStats.fromJson(jsonDecode(item.toString()));
      if (stats.songId == songId) return stats;
    }
    return ListenStats(songId: songId, title: title, artist: artist);
  }

  Future<void> _updateListenStats(PlayEvent event) async {
    final stats = _getStatsForSong(event.songId, event.title, event.artist);
    stats.playCount++;
    stats.totalListened += event.listenedDuration;
    stats.totalDuration = event.totalDuration;
    await _saveStats(stats);
  }

  Future<void> _saveStats(ListenStats stats) async {
    final raw = _listenStatsBoxRef.get('stats', defaultValue: <String>[]) as List;
    final all = raw.map((e) => ListenStats.fromJson(jsonDecode(e.toString()))).toList();
    all.removeWhere((s) => s.songId == stats.songId);
    all.add(stats);
    final encoded = all.map((s) => jsonEncode(s.toJson())).toList();
    await _listenStatsBoxRef.put('stats', encoded);
  }
}
