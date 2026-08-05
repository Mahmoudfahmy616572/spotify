class LyricLine {
  final String text;
  final Duration startTime;
  LyricLine(this.text, this.startTime);
}

// Simple Parser
List<LyricLine> parseLyrics(String lyrics) {
  final RegExp regExp = RegExp(r'\[(\d+):(\d+\.\d+)\](.*)');
  return lyrics.split('\n').map((line) {
    final match = regExp.firstMatch(line);
    if (match != null) {
      try {
        final minutes = int.parse(match.group(1)!);
        final secondsStr = match.group(2)!;
        final parts = secondsStr.split('.');
        final seconds = int.parse(parts[0]);
        final millis = parts.length > 1
            ? int.parse(parts[1].padRight(3, '0'))
            : 0;
        return LyricLine(
          match.group(3)?.trim() ?? '',
          Duration(
            minutes: minutes,
            seconds: seconds,
            milliseconds: millis,
          ),
        );
      } catch (_) {
        return LyricLine("", Duration.zero);
      }
    }
    return LyricLine("", Duration.zero);
  }).where((l) => l.text.isNotEmpty).toList();
}
