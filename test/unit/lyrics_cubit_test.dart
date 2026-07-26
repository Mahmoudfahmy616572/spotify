import 'package:flutter_test/flutter_test.dart';
import 'package:spotify/data/sources/lyrics/lyrics_data_source.dart';
import 'package:spotify/presentation/songsPlayPage/cubit/lyrics/lyrics_state.dart';

void main() {
  group('LyricsState', () {
    test('LyricsInitial is initial state', () {
      expect(LyricsInitial(), isA<LyricsState>());
    });

    test('LyricsLoading is distinct from LyricsInitial', () {
      expect(LyricsLoading(), isNot(equals(LyricsInitial())));
    });

    test('LyricsNotFound is distinct', () {
      expect(LyricsNotFound(), isNot(equals(LyricsInitial())));
    });

    test('LyricsLoaded stores lyrics', () {
      final state = LyricsLoaded([
        LyricLine('Hello', Duration(seconds: 0)),
        LyricLine('World', Duration(seconds: 3)),
      ]);
      expect(state.lyrics.length, 2);
      expect(state.lyrics[0].text, 'Hello');
      expect(state.lyrics[1].text, 'World');
    });

    test('LyricsFailure stores error message', () {
      final state = LyricsFailure('error occurred');
      expect(state.errorMessage, 'error occurred');
    });

    test('LyricsLoaded equatable works', () {
      final a = LyricsLoaded([LyricLine('X', Duration(seconds: 0))]);
      final b = LyricsLoaded([LyricLine('X', Duration(seconds: 0))]);
      expect(a, equals(b));
    });

    test('LyricsLoaded different lengths not equal', () {
      final a = LyricsLoaded([LyricLine('A', Duration(seconds: 0))]);
      final b = LyricsLoaded([
        LyricLine('X', Duration(seconds: 0)),
        LyricLine('Y', Duration(seconds: 3)),
      ]);
      expect(a, isNot(equals(b)));
    });
  });
}
