import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/activity_model.dart';
import '../repositories/weather_repository.dart';
import '../models/user_model.dart';

class WeatherViewModel extends ChangeNotifier {
  final WeatherRepository _repository = WeatherRepository();

  WeatherModel? weather;
  bool isLoading = false;
  String? errorMessage;
  List<ActivityModel> suggestedActivities = [];

  Future<void> fetchWeatherAndSuggestions(UserModel? user, {String city = "London"}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    weather = await _repository.getWeather(city);

    if (weather == null) {
      errorMessage = "Failed to load weather data.";
      suggestedActivities = [];
    } else {
      suggestedActivities = _calculateActivities(user, weather);
    }

    isLoading = false;
    notifyListeners();
  }

  List<ActivityModel> _calculateActivities(UserModel? user, WeatherModel? weather) {
    if (weather == null) return _defaultActivities();

    final int age = user?.age ?? 30;
    final double weight = user?.weight ?? 70.0;
    final double heightCm = user?.height ?? 170.0;
    
    // Calculate BMI to determine precise Weight Category
    final double heightM = heightCm / 100.0;
    final double bmi = weight / (heightM * heightM);
    final bool isOverweight = bmi >= 25.0; // Overweight category
    final bool isNormalOrAthletic = bmi < 25.0; // Normal/Athletic category

    final String condition = weather.condition.toLowerCase();
    final bool isClearOrSunny = condition.contains('clear') || condition.contains('sun');
    final bool isRainOrSnow = condition.contains('rain') || condition.contains('snow') || condition.contains('drizzle');
    final bool isExtremeHeat = weather.temp > 32;

    List<ActivityModel> recommendations = [];

    // ── Logic Engine Matrix ─────────────────────────────────────────

    // Rule 1: Clear/Sunny
    if (isClearOrSunny && !isExtremeHeat) {
      if (age < 50 && isNormalOrAthletic) {
        recommendations.add(const ActivityModel(
          title: 'Outdoor Running / High-Intensity Interval Training',
          category: 'Cardio',
          icon: Icons.directions_run_rounded,
          durationMins: 45, caloriesBurn: 480,
          difficulty: ActivityDifficulty.hard,
          tips: 'Start with a 5-min warm-up jog. Sprint 30s, rest 30s. Perfect for sunny days.',
          sampleMediaUrl: 'https://videos.pexels.com/video-files/3196144/3196144-uhd_2560_1440_25fps.mp4',
        ));
      } 
      if (age >= 50) {
        recommendations.add(const ActivityModel(
          title: 'Morning Walk / Tai Chi in the Park',
          category: 'Low Impact Cardio',
          icon: Icons.directions_walk_rounded,
          durationMins: 40, caloriesBurn: 200,
          difficulty: ActivityDifficulty.easy,
          tips: 'Focus on breathing and gentle movements. Enjoy the clear weather safely.',
          sampleMediaUrl: 'https://videos.pexels.com/video-files/2785536/2785536-uhd_3840_2160_25fps.mp4',
        ));
      }
    }

    // Rule 2: Rain/Snow
    if (isRainOrSnow) {
      recommendations.add(const ActivityModel(
        title: 'Indoor Yoga / Bodyweight Circuit',
        category: 'Strength & Flexibility',
        icon: Icons.fitness_center_rounded,
        durationMins: 35, caloriesBurn: 250,
        difficulty: ActivityDifficulty.moderate,
        tips: 'Stay inside away from the weather. Focus on core and flexibility using a mat.',
        sampleMediaUrl: 'https://videos.pexels.com/video-files/5319851/5319851-uhd_2160_3840_25fps.mp4',
      ));
    }

    // Rule 3: Extreme Heat
    if (isExtremeHeat) {
      if (isOverweight) {
        recommendations.add(const ActivityModel(
          title: 'Swimming / Hydrated Light Stretching',
          category: 'Water Sport',
          icon: Icons.pool_rounded,
          durationMins: 45, caloriesBurn: 400,
          difficulty: ActivityDifficulty.easy,
          tips: 'Avoid outdoor heat. Swimming puts zero stress on joints while keeping you cool.',
          sampleMediaUrl: 'https://videos.pexels.com/video-files/8040003/8040003-hd_1920_1080_30fps.mp4',
        ));
      }
    }

    // If no specific matrix rules match perfectly, or we need to pad the list, add defaults
    if (recommendations.isEmpty) {
      if (isExtremeHeat) {
        recommendations.add(const ActivityModel(
          title: 'Indoor Treadmill Walk',
          category: 'Indoor Cardio',
          icon: Icons.directions_walk_rounded,
          durationMins: 30, caloriesBurn: 200,
          difficulty: ActivityDifficulty.easy,
          tips: 'Stay indoors where there is AC.',
          sampleMediaUrl: 'https://videos.pexels.com/video-files/5319851/5319851-uhd_2160_3840_25fps.mp4',
        ));
      } else {
        recommendations.addAll(_defaultActivities());
      }
    } else if (recommendations.length < 2) {
      // Pad with a neutral indoor activity to ensure UI looks full
      recommendations.add(const ActivityModel(
        title: 'Flexibility & Mobility Flow',
        category: 'Recovery',
        icon: Icons.self_improvement_rounded,
        durationMins: 25, caloriesBurn: 100,
        difficulty: ActivityDifficulty.easy,
        tips: 'Perfect anytime activity. Focus on hip flexors, hamstrings, and shoulders.',
        sampleMediaUrl: 'https://videos.pexels.com/video-files/2785536/2785536-uhd_3840_2160_25fps.mp4',
      ));
    }

    return recommendations;
  }

  List<ActivityModel> _defaultActivities() => [
    const ActivityModel(
      title: 'Brisk Walking',
      category: 'Low Impact Cardio',
      icon: Icons.directions_walk_rounded,
      durationMins: 40, caloriesBurn: 210,
      difficulty: ActivityDifficulty.easy,
      tips: 'A 40-min brisk walk burns as much as a light jog. Aim for 6km/h.',
      sampleMediaUrl: 'https://videos.pexels.com/video-files/3196144/3196144-uhd_2560_1440_25fps.mp4',
    ),
    const ActivityModel(
      title: 'Full-Body Gym Workout',
      category: 'Strength',
      icon: Icons.fitness_center_rounded,
      durationMins: 60, caloriesBurn: 450,
      difficulty: ActivityDifficulty.moderate,
      tips: 'Compound lifts first (deadlift, squat, bench). Isolation exercises last.',
      sampleMediaUrl: 'https://videos.pexels.com/video-files/5319851/5319851-uhd_2160_3840_25fps.mp4',
    ),
    const ActivityModel(
      title: 'Flexibility & Mobility Flow',
      category: 'Recovery',
      icon: Icons.self_improvement_rounded,
      durationMins: 25, caloriesBurn: 100,
      difficulty: ActivityDifficulty.easy,
      tips: 'Perfect on rest days. Focus on hip flexors, hamstrings, and shoulders.',
      sampleMediaUrl: 'https://videos.pexels.com/video-files/2785536/2785536-uhd_3840_2160_25fps.mp4',
    ),
  ];
}
