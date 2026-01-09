import 'package:flutter/material.dart';

extension Darkmode on BuildContext {
  bool get isDarkMode {
    return Theme.of(this).brightness == Brightness.dark;
  }
}
