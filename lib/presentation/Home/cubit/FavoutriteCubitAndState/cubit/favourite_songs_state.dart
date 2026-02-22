part of 'favourite_songs_cubit.dart';

@immutable
abstract class FavouriteSongsState {}

class FavouriteSongsInitial extends FavouriteSongsState {}

class FavouriteSongsLoading extends FavouriteSongsState {}

// ignore: must_be_immutable
class FavouriteSongsLoaded extends FavouriteSongsState {
  Set<String> favouriteSongsIds;
  FavouriteSongsLoaded({required this.favouriteSongsIds});
}

class FavouriteSongsFailure extends FavouriteSongsState {
  final String errorMessage;
  FavouriteSongsFailure(this.errorMessage);
}
