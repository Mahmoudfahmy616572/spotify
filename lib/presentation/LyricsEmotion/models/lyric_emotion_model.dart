import 'package:flutter/material.dart';

enum EmotionType { love, sadness, joy, anger, hope, calm, energy, pain }

class LyricEmotion {
  final String text;
  final Duration startTime;
  final EmotionType emotion;
  final Color color;
  final double intensity;

  const LyricEmotion({
    required this.text,
    required this.startTime,
    required this.emotion,
    required this.color,
    this.intensity = 0.5,
  });
}
