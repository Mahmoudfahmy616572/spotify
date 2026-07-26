import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:spotify/data/models/songs/songs_model.dart';

import 'recently_played_state.dart';

class RecentlyPlayedCubit extends Cubit<RecentlyPlayedState> {
  static const String _boxName = 'recently_played';
  static const int _maxItems = 20;

  RecentlyPlayedCubit() : super(RecentlyPlayedInitial()) {
    _loadRecentlyPlayed();
  }

  Future<void> _loadRecentlyPlayed() async {
    final box = await Hive.openBox(_boxName);
    final songsJson = box.get('songs', defaultValue: <String>[]) as List;
    final songs = songsJson
        .map((e) => SongModel.fromJson(jsonDecode(e.toString())))
        .toList();
    emit(RecentlyPlayedLoaded(songs));
  }

  Future<void> addSong(SongModel song) async {
    final box = await Hive.openBox(_boxName);
    final songsJson = box.get('songs', defaultValue: <String>[]) as List;
    final songs = songsJson
        .map((e) => SongModel.fromJson(jsonDecode(e.toString())))
        .toList();

    songs.removeWhere((s) => s.id == song.id);
    songs.insert(0, song);

    if (songs.length > _maxItems) {
      songs.removeRange(_maxItems, songs.length);
    }

    final encoded = songs.map((s) => jsonEncode(s.toJson())).toList();
    await box.put('songs', encoded);
    emit(RecentlyPlayedLoaded(songs));
  }

  Future<void> clearRecentlyPlayed() async {
    final box = await Hive.openBox(_boxName);
    await box.put('songs', <String>[]);
    emit(RecentlyPlayedLoaded([]));
  }
}
