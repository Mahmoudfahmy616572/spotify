import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);
  void updateTheme(ThemeMode thememode) => emit(thememode);
  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    try {
      final index = json['theme'] as int?;
      if (index == null || index < 0 || index >= ThemeMode.values.length) {
        return ThemeMode.dark;
      }
      return ThemeMode.values[index];
    } catch (_) {
      return ThemeMode.dark;
    }
  }

  @override
  Map<String, dynamic>? toJson(ThemeMode state) {
    return {'theme': state.index};
  }
}
