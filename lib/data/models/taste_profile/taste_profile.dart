import 'package:equatable/equatable.dart';

class TasteProfile extends Equatable {
  final Map<String, double> genreScores;
  final List<String> topArtists;
  final List<String> topGenres;
  final String primaryLanguage;
  final Map<String, double> moodScores;
  final DateTime lastAnalyzed;

  const TasteProfile({
    this.genreScores = const {},
    this.topArtists = const [],
    this.topGenres = const [],
    this.primaryLanguage = 'unknown',
    this.moodScores = const {},
    required this.lastAnalyzed,
  });

  TasteProfile copyWith({
    Map<String, double>? genreScores,
    List<String>? topArtists,
    List<String>? topGenres,
    String? primaryLanguage,
    Map<String, double>? moodScores,
    DateTime? lastAnalyzed,
  }) {
    return TasteProfile(
      genreScores: genreScores ?? this.genreScores,
      topArtists: topArtists ?? this.topArtists,
      topGenres: topGenres ?? this.topGenres,
      primaryLanguage: primaryLanguage ?? this.primaryLanguage,
      moodScores: moodScores ?? this.moodScores,
      lastAnalyzed: lastAnalyzed ?? this.lastAnalyzed,
    );
  }

  @override
  List<Object?> get props => [
        genreScores,
        topArtists,
        topGenres,
        primaryLanguage,
        moodScores,
        lastAnalyzed,
      ];
}
