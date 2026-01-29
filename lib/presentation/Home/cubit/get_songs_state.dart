import 'package:spotify/data/models/songs/songs_model.dart';

abstract class GetSongsState {}

class GetSongsLoading extends GetSongsState {}

class GetSongsLoaded extends GetSongsState {
  final List<SongModel> songs;
  GetSongsLoaded({required this.songs});
}

class GetSongsFailure extends GetSongsState {
  final String errorMessage;
  GetSongsFailure(this.errorMessage);
}
