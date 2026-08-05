import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spotify/data/sources/lyrics/lyrics_data_source.dart';

class SyncAnalyzer {
  static const _channel = MethodChannel('audio_decoder');

  final Dio _dio;
  SyncAnalyzer(this._dio);

  Future<Duration?> analyze(String audioUrl, List<LyricLine> lyrics) async {
    if (lyrics.length < 3) return null;
    try {
      final tempDir = await getTemporaryDirectory();
      final audioFile = File('${tempDir.path}/sync_${DateTime.now().millisecondsSinceEpoch}.mp3');
      final wavFile = File('${tempDir.path}/sync_${DateTime.now().millisecondsSinceEpoch}.wav');

      await _dio.download(audioUrl, audioFile.path);
      if (!audioFile.existsSync()) return null;

      try {
        await _channel.invokeMethod('decodeToWav', {
          'inputPath': audioFile.path,
          'outputPath': wavFile.path,
        });
      } on MissingPluginException {
        audioFile.deleteSync();
        return null;
      }

      if (!wavFile.existsSync()) {
        audioFile.deleteSync();
        return null;
      }

      final wavBytes = await wavFile.readAsBytes();
      audioFile.deleteSync();
      wavFile.deleteSync();

      final samples = readWavSamples(wavBytes);
      if (samples.isEmpty) return null;

      final onsets = _detectOnsets(samples, 44100);
      if (onsets.length < 3) return null;

      return _alignOffset(lyrics, onsets);
    } catch (_) {
      return null;
    }
  }

  Float64List readWavSamples(Uint8List wavBytes) {    if (wavBytes.length < 44) return Float64List(0);
    final sampleRate = ByteData.sublistView(wavBytes, 24, 28).getUint32(0, Endian.little);
    if (sampleRate == 0) return Float64List(0);
    final dataSize = ByteData.sublistView(wavBytes, 40, 44).getUint32(0, Endian.little);
    final dataStart = 44;
    final sampleCount = dataSize ~/ 2;
    final result = Float64List(sampleCount);
    for (int i = 0; i < sampleCount; i++) {
      final offset = dataStart + i * 2;
      if (offset + 1 >= wavBytes.length) break;
      final sample = ByteData.sublistView(wavBytes, offset, offset + 2).getInt16(0, Endian.little);
      result[i] = sample / 32768.0;
    }
    return result;
  }

  List<Duration> _detectOnsets(Float64List samples, int sampleRate) {
    const frameSize = 1024;
    const hopSize = 512;
    final numFrames = (samples.length - frameSize) ~/ hopSize;
    if (numFrames < 1) return [];

    final energies = Float64List(numFrames);
    for (int i = 0; i < numFrames; i++) {
      final start = i * hopSize;
      double sum = 0;
      for (int j = 0; j < frameSize; j++) {
        if (start + j >= samples.length) break;
        sum += samples[start + j] * samples[start + j];
      }
      energies[i] = sqrt(sum / frameSize);
    }

    const smoothWindow = 4;
    final smoothed = Float64List(numFrames);
    for (int i = 0; i < numFrames; i++) {
      double s = 0;
      int count = 0;
      for (int j = -smoothWindow; j <= smoothWindow; j++) {
        final idx = i + j;
        if (idx >= 0 && idx < numFrames) {
          s += energies[idx];
          count++;
        }
      }
      smoothed[i] = s / count;
    }

    final novelty = Float64List(numFrames);
    for (int i = 1; i < numFrames; i++) {
      final diff = smoothed[i] - smoothed[i - 1];
      novelty[i] = diff > 0 ? diff : 0;
    }

    final onsets = <Duration>[];
    final halfWindow = 3;
    final threshold = _mean(novelty) * 1.5;
    for (int i = halfWindow; i < numFrames - halfWindow; i++) {
      if (novelty[i] < threshold) continue;
      bool isPeak = true;
      for (int j = -halfWindow; j <= halfWindow; j++) {
        if (j == 0) continue;
        if (novelty[i + j] >= novelty[i]) {
          isPeak = false;
          break;
        }
      }
      if (isPeak) {
        final timeMs = (i * hopSize * 1000) ~/ sampleRate;
        onsets.add(Duration(milliseconds: timeMs));
      }
    }
    return onsets;
  }

  Duration? _alignOffset(List<LyricLine> lyrics, List<Duration> onsets) {
    final lyricTimes = lyrics.map((l) => l.startTime.inMilliseconds).toList();
    final onsetTimes = onsets.map((o) => o.inMilliseconds).toList();

    if (lyricTimes.isEmpty || onsetTimes.isEmpty) return null;

    final estimatedSongMs = lyricTimes.last + 5000;
    final coarseStep = 500;
    final fineStep = 50;
    final fineRange = 500;

    // Coarse search across full song duration
    var bestOffset = 0;
    var bestScore = double.maxFinite;
    final coarseStart = -(estimatedSongMs);
    final coarseEnd = 10000;

    for (int offset = coarseStart; offset <= coarseEnd; offset += coarseStep) {
      final score = _matchScore(lyricTimes, onsetTimes, offset);
      if (score < bestScore) {
        bestScore = score;
        bestOffset = offset;
      }
    }

    // Fine search around best coarse offset
    final fineStart = (bestOffset - fineRange).clamp(coarseStart, coarseEnd);
    final fineEnd = (bestOffset + fineRange).clamp(coarseStart, coarseEnd);
    for (int offset = fineStart; offset <= fineEnd; offset += fineStep) {
      final score = _matchScore(lyricTimes, onsetTimes, offset);
      if (score < bestScore) {
        bestScore = score;
        bestOffset = offset;
      }
    }

    if (bestScore > 1000) return null;
    return Duration(milliseconds: bestOffset);
  }

  double _matchScore(List<int> lyricTimes, List<int> onsetTimes, int offset) {
    double score = 0;
    int matches = 0;
    final maxLen = lyricTimes.length < onsetTimes.length
        ? lyricTimes.length
        : onsetTimes.length;
    for (int i = 0; i < maxLen; i++) {
      final adjusted = lyricTimes[i] + offset;
      int best = onsetTimes[0];
      int bestDiff = (best - adjusted).abs();
      for (int j = 1; j < onsetTimes.length; j++) {
        final d = (onsetTimes[j] - adjusted).abs();
        if (d < bestDiff) {
          bestDiff = d;
          best = onsetTimes[j];
        }
      }
      if (bestDiff < 500) {
        score += bestDiff;
        matches++;
      }
    }
    if (matches == 0) return double.maxFinite;
    return score / matches;
  }

  double _mean(Float64List data) {
    if (data.isEmpty) return 0;
    double s = 0;
    for (final v in data) {
      s += v;
    }
    return s / data.length;
  }
}
