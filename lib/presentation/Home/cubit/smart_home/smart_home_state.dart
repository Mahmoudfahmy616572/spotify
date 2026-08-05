part of 'smart_home_cubit.dart';

abstract class SmartHomeState extends Equatable {
  const SmartHomeState();

  @override
  List<Object?> get props => [];
}

class SmartHomeInitial extends SmartHomeState {}

class SmartHomeLoading extends SmartHomeState {}

class SmartHomeContent extends SmartHomeState {
  final List<SongModel> forYou;
  final List<SongModel> newSongs;
  final List<SongModel> recentlyPlayed;
  final List<SongModel> basedOnGenre;
  final List<String> topGenres;
  final List<String> topArtists;

  const SmartHomeContent({
    required this.forYou,
    required this.newSongs,
    required this.recentlyPlayed,
    required this.basedOnGenre,
    required this.topGenres,
    required this.topArtists,
  });

  @override
  List<Object?> get props => [forYou, newSongs, recentlyPlayed, basedOnGenre, topGenres, topArtists];
}

class SmartHomeError extends SmartHomeState {
  final String message;
  const SmartHomeError(this.message);

  @override
  List<Object?> get props => [message];
}
