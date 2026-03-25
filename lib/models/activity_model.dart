import 'package:flutter/material.dart';

enum ActivityDifficulty { easy, moderate, hard }

class ActivityModel {
  final String title;
  final String category;
  final String sampleMediaUrl;
  final IconData icon;
  final int durationMins;
  final int caloriesBurn;
  final ActivityDifficulty difficulty;
  final String tips;

  const ActivityModel({
    required this.title,
    required this.category,
    required this.sampleMediaUrl,
    this.icon = Icons.fitness_center_rounded,
    this.durationMins = 30,
    this.caloriesBurn = 200,
    this.difficulty = ActivityDifficulty.moderate,
    this.tips = 'Stay hydrated and warm up before starting.',
  });

  Color get difficultyColor {
    switch (difficulty) {
      case ActivityDifficulty.easy:
        return const Color(0xFF2ECC71);
      case ActivityDifficulty.moderate:
        return const Color(0xFFF39C12);
      case ActivityDifficulty.hard:
        return const Color(0xFFE74C3C);
    }
  }

  String get difficultyLabel {
    switch (difficulty) {
      case ActivityDifficulty.easy:     return 'Easy';
      case ActivityDifficulty.moderate: return 'Moderate';
      case ActivityDifficulty.hard:     return 'Hard';
    }
  }
}
