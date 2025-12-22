import 'package:flutter/material.dart';
import 'package:spotify/core/config/theme/app_colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: "Satoshi",
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundLightTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: "Satoshi",
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundDarkTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
    ),
  );
}
