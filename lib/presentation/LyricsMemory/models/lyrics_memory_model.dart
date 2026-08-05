class LyricsMemoryEntry {
  final String songId;
  final String title;
  final String artist;
  final String imageUrl;
  final DateTime firstHeard;
  final DateTime lastHeard;
  final int timesListened;
  final List<String> favoriteLines;

  const LyricsMemoryEntry({
    required this.songId,
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.firstHeard,
    required this.lastHeard,
    this.timesListened = 1,
    this.favoriteLines = const [],
  });

  int get daysSinceLastPlayed =>
      DateTime.now().difference(lastHeard).inDays;

  bool get isForgotten => daysSinceLastPlayed > 30;

  bool get isRecent => daysSinceLastPlayed <= 7;

  Map<String, dynamic> toJson() => {
        'songId': songId,
        'title': title,
        'artist': artist,
        'imageUrl': imageUrl,
        'firstHeard': firstHeard.toIso8601String(),
        'lastHeard': lastHeard.toIso8601String(),
        'timesListened': timesListened,
        'favoriteLines': favoriteLines,
      };

  static DateTime _safeParseDateTime(dynamic value, {DateTime? fallback}) {
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {}
    }
    return fallback ?? DateTime.now();
  }

  factory LyricsMemoryEntry.fromJson(Map<String, dynamic> json) =>
      LyricsMemoryEntry(
        songId: json['songId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        artist: json['artist'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
        firstHeard: _safeParseDateTime(json['firstHeard']),
        lastHeard: _safeParseDateTime(json['lastHeard']),
        timesListened: json['timesListened'] as int? ?? 1,
        favoriteLines: (json['favoriteLines'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );

  LyricsMemoryEntry copyWith({
    DateTime? lastHeard,
    int? timesListened,
    List<String>? favoriteLines,
  }) =>
      LyricsMemoryEntry(
        songId: songId,
        title: title,
        artist: artist,
        imageUrl: imageUrl,
        firstHeard: firstHeard,
        lastHeard: lastHeard ?? this.lastHeard,
        timesListened: timesListened ?? this.timesListened,
        favoriteLines: favoriteLines ?? this.favoriteLines,
      );
}

class LyricsMemoryStats {
  final int totalUniqueSongs;
  final int totalPlays;
  final int daysUsingApp;
  final String topArtist;

  const LyricsMemoryStats({
    required this.totalUniqueSongs,
    required this.totalPlays,
    required this.daysUsingApp,
    required this.topArtist,
  });
}
