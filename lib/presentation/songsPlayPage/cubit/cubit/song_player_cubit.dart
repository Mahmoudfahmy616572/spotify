import 'package:bloc/bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meta/meta.dart';
import 'package:spotify/data/models/songs/songs_model.dart';

part 'song_player_state.dart';

class SongPlayerCubit extends Cubit<SongPlayerState> {
  final AudioPlayer audioPlayer = AudioPlayer();
  List<SongModel> playList = [];
  int currentIndex = 0;
  String url = '';
  Duration songDuration = Duration.zero;
  Duration songPosition = Duration.zero;
  SongPlayerCubit() : super(SongPlayerLoading()) {
    audioPlayer.durationStream.listen((duration) async {
      if (duration != null) {
        songDuration = duration;
        updateSongPlayer();
      }
    });
    audioPlayer.positionStream.listen((position) {
      songPosition = position;
      updateSongPlayer();
    });
    audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        playNext();
      }
    });
  }
  void updateSongPlayer() {
    if (!isClosed) emit(SongPlayerLoaded());
  }

  Future<void> loadSong(
      List<SongModel> songs, int index, String urlImage) async {
    playList = songs;
    currentIndex = index;
    urlImage = url;

    try {
      emit(SongPlayerLoading());
      await audioPlayer.setUrl(songs[currentIndex].urlSongsbase);
      audioPlayer.play();
      emit(SongPlayerLoaded());
    } catch (e) {
      emit(SongPlayerFailure(errorMessage: 'Failed to load song: $e'));
    }
  }

  void playNext() {
    if (currentIndex > playList.length - 1) {
      currentIndex++;
      loadSong(playList, currentIndex, url);
    } else {
      currentIndex = 0;
      loadSong(playList, currentIndex, url);
    }
  }

  void playPrevious() {
    if (currentIndex > 0) {
      currentIndex--;
      loadSong(playList, currentIndex, url);
    } else {
      currentIndex = playList.length - 1;
      loadSong(playList, currentIndex, url);
    }
  }

  void seekTo(Duration? duration) {
    audioPlayer.seek(duration);
  }

  void playOrpauseSong() async {
    if (audioPlayer.playing) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }
    emit(SongPlayerLoaded());
  }

  @override
  Future<void> close() async {
    await audioPlayer.dispose();
    return super.close();
  }
}
