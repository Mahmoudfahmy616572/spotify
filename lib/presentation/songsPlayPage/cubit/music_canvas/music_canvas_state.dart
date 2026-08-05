import 'package:equatable/equatable.dart';

abstract class MusicCanvasState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MusicCanvasInitial extends MusicCanvasState {}

class MusicCanvasLoading extends MusicCanvasState {}

class MusicCanvasLoaded extends MusicCanvasState {
  final String videoUrl;
  final String? youtubeId;

  MusicCanvasLoaded({required this.videoUrl, this.youtubeId});

  @override
  List<Object?> get props => [videoUrl, youtubeId];
}

class MusicCanvasEmpty extends MusicCanvasState {}

class MusicCanvasError extends MusicCanvasState {
  final String errorMessage;

  MusicCanvasError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
