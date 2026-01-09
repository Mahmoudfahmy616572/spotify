import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:spotify/core/config/theme/app_colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: "Satoshi",
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundLightTheme,
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.transparent,
      filled: true,
      hintStyle: TextStyle(
          color: const Color(0xff383838),
          fontWeight: FontWeight.w500,
          fontSize: 16.sp),
      contentPadding: EdgeInsets.all(30.w),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.r),
        borderSide: const BorderSide(color: Colors.black),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.r),
        borderSide: const BorderSide(color: Colors.black, width: 0.4),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.r),
        borderSide: const BorderSide(color: Colors.black, width: 0.4),
      ),

      errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(
            width: 1,
            color: Color.fromARGB(255, 255, 108, 59),
          )),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        borderSide: BorderSide(
          width: 1,
          color: Colors.redAccent,
        ),
      ),

      // suffixIcon: suffexIcon,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          textStyle: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: "Satoshi",
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundDarkTheme,
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.transparent,
      filled: true,
      hintStyle: TextStyle(
          color: const Color(0xffA7A7A7),
          fontWeight: FontWeight.w500,
          fontSize: 16.sp),
      contentPadding: EdgeInsets.all(30.w),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.r),
        borderSide: const BorderSide(color: Colors.white),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.r),
        borderSide: const BorderSide(color: Colors.white, width: 0.4),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.r),
        borderSide: const BorderSide(color: Colors.white, width: 0.4),
      ),

      errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(
            width: 1,
            color: Color.fromARGB(255, 255, 108, 59),
          )),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        borderSide: BorderSide(
          width: 1,
          color: Colors.redAccent,
        ),
      ),

      // suffixIcon: suffexIcon,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          textStyle: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
    ),
  );
}
