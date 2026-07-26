import 'package:equatable/equatable.dart';
import 'package:spotify/data/models/songs/songs_model.dart';

abstract class ChartsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChartsLoading extends ChartsState {}

class ChartsLoaded extends ChartsState {
  final List<SongModel> songs;
  ChartsLoaded({required this.songs});

  @override
  List<Object?> get props => [songs];
}

class ChartsFailure extends ChartsState {
  final String errorMessage;
  ChartsFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
