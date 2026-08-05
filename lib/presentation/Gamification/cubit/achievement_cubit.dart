import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:spotify/presentation/Gamification/models/achievement_model.dart';

import 'achievement_state.dart';

class AchievementCubit extends Cubit<AchievementState> {
  AchievementCubit() : super(AchievementInitial());

  final Random _random = Random();

  void loadAchievements() {
    emit(AchievementLoading());
    final achievements = AchievementModel.defaultAchievements();
    emit(AchievementLoaded(
      achievements: achievements,
      totalXp: 0,
      level: 1,
    ));
  }

  void updateProgress(String achievementId, int progress) {
    if (state is! AchievementLoaded) return;
    final current = state as AchievementLoaded;
    final updatedAchievements = current.achievements.map((a) {
      if (a.id == achievementId) {
        final newProgress = min(progress, a.requiredValue);
        final justUnlocked = !a.isUnlocked && newProgress >= a.requiredValue;
        return a.copyWith(
          currentProgress: newProgress,
          isUnlocked: newProgress >= a.requiredValue,
          xpReward: justUnlocked ? a.xpReward : 0,
        );
      }
      return a;
    }).toList();

    final newXp = updatedAchievements.fold<int>(
      0,
      (sum, a) => sum + (a.isUnlocked ? a.xpReward : 0),
    );
    final newLevel = 1 + (newXp ~/ 500);

    emit(AchievementLoaded(
      achievements: updatedAchievements,
      totalXp: newXp,
      level: newLevel,
    ));
  }

  void incrementProgress(String achievementId) {
    if (state is! AchievementLoaded) return;
    final current = state as AchievementLoaded;
    final achievement = current.achievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => AchievementModel(
          id: '', title: '', description: '', icon: ''),
    );
    if (achievement.id.isNotEmpty && !achievement.isUnlocked) {
      updateProgress(achievementId, achievement.currentProgress + 1);
    }
  }

  void simulateRandomProgress() {
    if (state is! AchievementLoaded) return;
    final current = state as AchievementLoaded;
    final lockedAchievements =
        current.achievements.where((a) => !a.isUnlocked).toList();
    if (lockedAchievements.isEmpty) return;

    final randomAchievement =
        lockedAchievements[_random.nextInt(lockedAchievements.length)];
    incrementProgress(randomAchievement.id);
  }
}
