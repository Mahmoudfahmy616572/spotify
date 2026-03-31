import 'dart:io' show File;

import 'package:bloc/bloc.dart';
import 'package:flutter/painting.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meta/meta.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:spotify/data/models/songs/songs_model.dart';

part 'song_player_state.dart';

class SongPlayerCubit extends Cubit<SongPlayerState> {
  bool _isShuffleMode = false;
  bool get isShuffleMode => _isShuffleMode;
  LoopMode _loopMode = LoopMode.off;
  LoopMode get loopMode => _loopMode;
  bool _isLyricsVisable = false;
  Color dominantColor = const Color(0xff121212);
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
  void toggleShowLyrics() {
    if (state is SongPlayerLoaded) {
      _isLyricsVisable = !_isLyricsVisable;
      emit((state as SongPlayerLoaded).copyWith(
        isLyricsVisible: _isLyricsVisable,
      ));
    }
  }

  void updateSongPlayer() {
    if (!isClosed) emit(SongPlayerLoaded(isLyricsVisable: _isLyricsVisable));
  }

  void toggleShuffleMode() async {
    _isShuffleMode = !_isShuffleMode;
    await audioPlayer.setShuffleModeEnabled(_isShuffleMode);
    if (_isShuffleMode) {
      await audioPlayer.shuffle();
    }
    updateSongPlayer();
  }

  void toggleRepeatMode() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.one;
    } else if (_loopMode == LoopMode.one) {
      _loopMode = LoopMode.all;
    } else {
      _loopMode = LoopMode.off;
    }
    audioPlayer.setLoopMode(_loopMode);
    updateSongPlayer();
  }

  Future<void> upDateThemeColor(String imageUrl) async {
    try {
      PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
        maximumColorCount: 10,
      );
      dominantColor =
          paletteGenerator.dominantColor?.color ?? const Color(0xff121212);
      updateSongPlayer();
    } catch (e) {
      dominantColor = const Color(0xff121212);
      updateSongPlayer();
    }
  }

  Future<void> loadSong(
      List<SongModel> songs, int index, String urlImage) async {
    playList = songs;
    currentIndex = index;
    urlImage = url;
    upDateThemeColor(songs[index].imageUrl);

    try {
      emit(SongPlayerLoading());
      final box = Hive.box('offline_songs');
      final String? localPath = box.get(playList[currentIndex].id.toString());
      if (localPath != null && await File(localPath).exists()) {
        //(offline)
        await audioPlayer.setFilePath(localPath);
      } else {
        //(online)
        await audioPlayer.setUrl(songs[currentIndex].urlSongsbase);
      }
      audioPlayer.play();
      emit(SongPlayerLoaded(isLyricsVisable: _isLyricsVisable));
    } catch (e) {
      emit(SongPlayerFailure(errorMessage: 'Failed to load song: $e'));
    }
  }

  void playNext() {
    if (currentIndex < playList.length - 1) {
      currentIndex++;
    } else {
      currentIndex = 0;
    }
    loadSong(playList, currentIndex, url);
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
    emit(SongPlayerLoaded(isLyricsVisable: _isLyricsVisable));
  }

  @override
  Future<void> close() async {
    await audioPlayer.dispose();
    return super.close();
  }
}
