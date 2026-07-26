class MusicIWantSongModel {
  final String title;
  final String artist;
  final double? bpm;
  final double? energy;
  final double? intensityScore;
  final String? mood;
  final String? recommendedUse;
  final double? danceability;
  final double? acousticness;

  const MusicIWantSongModel({
    required this.title,
    required this.artist,
    this.bpm,
    this.energy,
    this.intensityScore,
    this.mood,
    this.recommendedUse,
    this.danceability,
    this.acousticness,
  });

  factory MusicIWantSongModel.fromJson(Map<String, dynamic> json) {
    return MusicIWantSongModel(
      title: json['title']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      bpm: (json['bpm'] as num?)?.toDouble(),
      energy: (json['energy'] as num?)?.toDouble(),
      intensityScore: (json['intensity_score'] as num?)?.toDouble(),
      mood: json['mood']?.toString(),
      recommendedUse: json['recommended_use']?.toString(),
      danceability: (json['danceability'] as num?)?.toDouble(),
      acousticness: (json['acousticness'] as num?)?.toDouble(),
    );
  }
}
