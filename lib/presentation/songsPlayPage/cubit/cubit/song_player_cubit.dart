import 'package:bloc/bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meta/meta.dart';
part 'song_player_state.dart';

class SongPlayerCubit extends Cubit<SongPlayerState> {
  final AudioPlayer audioPlayer = AudioPlayer();
  Duration songDuration = Duration.zero;
  Duration songPosition = Duration.zero;
  SongPlayerCubit() : super(SongPlayerLoading()) {
    audioPlayer.durationStream.listen((duration) {
      songDuration = duration!;
      updateSongPlayer();
    });
    audioPlayer.positionStream.listen((position) {
      songPosition = position;
      updateSongPlayer();
    });
  }
  void updateSongPlayer() {
    emit(SongPlayerLoaded());
  }

  Future<void> loadSong(String url) async {
    await audioPlayer.setUrl(url);
    try {
      emit(SongPlayerLoaded());
    } catch (e) {
      emit(SongPlayerFailure(errorMessage: 'Failed to load song: $e'));
    }
  }

  void seekTo(Duration? duration) {
    audioPlayer.seek(duration);
  }

  void playOrpauseSong() async {
    if (audioPlayer.playing) {
      await audioPlayer.stop();
    } else {
      await audioPlayer.play();
    }
    emit(SongPlayerLoaded());
  }

  @override
  Future<void> close() {
    audioPlayer.dispose();
    return super.close();
  }
}
