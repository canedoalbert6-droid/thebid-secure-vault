import '../models/weather_model.dart';
import '../services/api_service.dart';

class WeatherRepository {
  final ApiService _apiService = ApiService();

  Future<WeatherModel?> getWeather(String city) async {
    return await _apiService.fetchWeather(city);
  }
}
