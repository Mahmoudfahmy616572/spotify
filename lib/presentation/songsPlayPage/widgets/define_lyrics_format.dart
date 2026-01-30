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
      final duration = Duration(
        minutes: int.parse(match.group(1)!),
        seconds: int.parse(match.group(2)!.split('.')[0]),
        milliseconds: int.parse(match.group(2)!.split('.')[1]),
      );
      return LyricLine(match.group(3)!.trim(), duration);
    }
    return LyricLine("", Duration.zero);
  }).where((l) => l.text.isNotEmpty).toList();
}
