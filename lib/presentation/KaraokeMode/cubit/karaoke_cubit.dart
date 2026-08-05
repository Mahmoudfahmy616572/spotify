import 'package:bloc/bloc.dart';
import 'package:spotify/data/sources/lyrics/lyrics_data_source.dart';

part 'karaoke_state.dart';

class KaraokeCubit extends Cubit<KaraokeState> {
  List<LyricLine> _lyrics = [];
  int _currentLineIndex = -1;
  int _tappedCorrectly = 0;
  int _totalTaps = 0;
  DateTime? _songStartTime;
  bool _isRecording = false;

  KaraokeCubit() : super(const KaraokeInitial());

  void setLyrics(List<LyricLine> lyrics) {
    _lyrics = lyrics;
  }

  void updateCurrentLine(int index) {
    if (index >= 0 && index < _lyrics.length && index != _currentLineIndex) {
      _currentLineIndex = index;
    }
  }

  void startSession() {
    _tappedCorrectly = 0;
    _totalTaps = 0;
    _songStartTime = DateTime.now();
    _isRecording = true;
    _currentLineIndex = -1;
    emit(const KaraokeRecording(score: 0, linesCompleted: 0));
  }

  void stopSession() {
    _isRecording = false;
    final score = _totalTaps > 0
        ? ((_tappedCorrectly / _totalTaps) * 100).round()
        : 0;
    emit(KaraokeResult(
      score: score,
      totalLines: _lyrics.length,
      linesCompleted: _tappedCorrectly,
    ));
  }

  void onLineTapped(int lineNumber) {
    if (!_isRecording || _currentLineIndex < 0) return;

    _totalTaps++;

    final expectedLine = _lyrics[_currentLineIndex];
    final tolerance = Duration(
      milliseconds: (expectedLine.startTime.inMilliseconds * 0.25).round(),
    );

    final now = DateTime.now();
    if (_songStartTime == null) return;

    final userPosition = now.difference(_songStartTime!);
    final expectedPosition = expectedLine.startTime;
    final diff = (userPosition - expectedPosition).abs();

    if (diff <= tolerance) {
      _tappedCorrectly++;
    }

    final score = _totalTaps > 0
        ? ((_tappedCorrectly / _totalTaps) * 100).round()
        : 0;

    emit(KaraokeRecording(
      score: score,
      linesCompleted: _tappedCorrectly,
    ));
  }

  bool get isRecording => _isRecording;
}
