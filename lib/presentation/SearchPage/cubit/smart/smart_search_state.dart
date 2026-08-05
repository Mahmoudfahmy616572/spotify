part of 'smart_search_cubit.dart';

abstract class SmartSearchState extends Equatable {
  const SmartSearchState();

  @override
  List<Object?> get props => [];
}

class SmartSearchInitial extends SmartSearchState {}

class SmartSearchLoading extends SmartSearchState {}

class SmartSearchLoaded extends SmartSearchState {
  final List<SongModel> songs;
  final List<String> recentSearches;

  const SmartSearchLoaded(this.songs, {this.recentSearches = const []});

  @override
  List<Object?> get props => [songs, recentSearches];
}

class SmartSearchError extends SmartSearchState {
  final String message;
  const SmartSearchError(this.message);

  @override
  List<Object?> get props => [message];
}
