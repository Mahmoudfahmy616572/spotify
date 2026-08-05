import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:spotify/data/sources/deezer/deezer_data_source.dart';

import 'listening_party_state.dart';

class ListeningPartyCubit extends Cubit<ListeningPartyState> {
  final DeezerDataSource _deezerDataSource;
  final Random _random = Random();

  ListeningPartyCubit({DeezerDataSource? deezerDataSource})
      : _deezerDataSource = deezerDataSource ?? DeezerDataSourceImpl(),
        super(ListeningPartyInitial());

  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      6,
      (_) => chars[_random.nextInt(chars.length)],
    ).join();
  }

  Future<void> createRoom(String hostName) async {
    emit(ListeningPartyLoading());
    try {
      final code = _generateRoomCode();
      final host = PartyParticipant(
        id: 'host_${DateTime.now().millisecondsSinceEpoch}',
        name: hostName,
        isHost: true,
      );
      emit(ListeningPartyLobby(
        roomCode: code,
        participants: [host],
        isHost: true,
        hostName: hostName,
      ));
    } catch (e) {
      emit(ListeningPartyError('Failed to create room'));
    }
  }

  Future<void> joinRoom(String roomCode, String userName) async {
    emit(ListeningPartyLoading());
    try {
      final participant = PartyParticipant(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: userName,
      );
      emit(ListeningPartyLobby(
        roomCode: roomCode.toUpperCase(),
        participants: [
          const PartyParticipant(id: 'host', name: 'Host', isHost: true),
          participant,
        ],
        isHost: false,
        hostName: userName,
      ));
    } catch (e) {
      emit(ListeningPartyError('Failed to join room'));
    }
  }

  Future<void> startParty() async {
    if (state is! ListeningPartyLobby) return;
    final lobby = state as ListeningPartyLobby;

    emit(ListeningPartyLoading());
    try {
      final songs = await _deezerDataSource.getTopTracks(limit: 20);
      if (songs.isEmpty) {
        emit(ListeningPartyError('No songs available'));
        return;
      }
      emit(ListeningPartyActive(
        roomCode: lobby.roomCode,
        participants: lobby.participants,
        currentSong: songs.first,
        currentIndex: 0,
        queue: songs,
        isPlaying: true,
        isHost: lobby.isHost,
      ));
    } catch (e) {
      emit(ListeningPartyError('Failed to start party'));
    }
  }

  void playPause() {
    if (state is! ListeningPartyActive) return;
    final current = state as ListeningPartyActive;
    emit(current.copyWith(isPlaying: !current.isPlaying));
  }

  void nextSong() {
    if (state is! ListeningPartyActive) return;
    final current = state as ListeningPartyActive;
    if (current.currentIndex < current.queue.length - 1) {
      final newIndex = current.currentIndex + 1;
      emit(current.copyWith(
        currentIndex: newIndex,
        currentSong: current.queue[newIndex],
      ));
    }
  }

  void previousSong() {
    if (state is! ListeningPartyActive) return;
    final current = state as ListeningPartyActive;
    if (current.currentIndex > 0) {
      final newIndex = current.currentIndex - 1;
      emit(current.copyWith(
        currentIndex: newIndex,
        currentSong: current.queue[newIndex],
      ));
    }
  }

  void leaveParty() {
    emit(ListeningPartyInitial());
  }
}
