part of 'karaoke_cubit.dart';

sealed class KaraokeState {
  const KaraokeState();
}

final class KaraokeInitial extends KaraokeState {
  const KaraokeInitial();
}

final class KaraokeRecording extends KaraokeState {
  final int score;
  final int linesCompleted;

  const KaraokeRecording({
    required this.score,
    required this.linesCompleted,
  });
}

final class KaraokeResult extends KaraokeState {
  final int score;
  final int totalLines;
  final int linesCompleted;

  const KaraokeResult({
    required this.score,
    required this.totalLines,
    required this.linesCompleted,
  });
}
