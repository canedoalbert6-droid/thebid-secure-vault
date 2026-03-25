import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/weather_model.dart';
import '../utils/env_config.dart';

class ApiService {
  Future<WeatherModel?> fetchWeather(String? fallbackCity) async {
    try {
      double lat = 14.5995; // default Manila
      double lon = 120.9842;
      String city = fallbackCity ?? "Manila";
      bool gpsSuccess = false;

      // 1. Try Hardware GPS Location First
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        LocationPermission permission = await Geolocator.checkPermission();
        
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (serviceEnabled && (permission == LocationPermission.whileInUse || permission == LocationPermission.always)) {
          Position? position;
          try {
            position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium).timeout(const Duration(seconds: 5));
          } catch (_) {
            position = await Geolocator.getLastKnownPosition();
          }

          if (position != null) {
            lat = position.latitude;
            lon = position.longitude;

            try {
              final placemarks = await placemarkFromCoordinates(lat, lon).timeout(const Duration(seconds: 5));
              if (placemarks.isNotEmpty) {
                final p = placemarks.first;
                final locality = p.locality?.isNotEmpty == true ? p.locality : p.subAdministrativeArea;
                
                if (locality != null && locality.isNotEmpty) {
                   city = locality;
                   gpsSuccess = true;
                }
              }
            } catch (_) {
              debugPrint("Reverse geocoding timed out.");
            }
          }
        }
      } catch (e) {
        debugPrint("Hardware GPS failed or denied: $e");
      }

      // 2. Fallback Location if GPS failed or was denied
      if (!gpsSuccess) {
        debugPrint("Using default fallback location: $city to avoid inconsistent IP bouncing.");
      }

      // 2. Get Weather via Open-Meteo (Free, no API key required)
      final weatherUrl = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code');
      final weatherRes = await http.get(weatherUrl).timeout(const Duration(seconds: 5));

      if (weatherRes.statusCode == 200) {
        final wData = json.decode(weatherRes.body);
        final current = wData['current'];
        final temp = current['temperature_2m'];
        final humidity = current['relative_humidity_2m'];
        final code = current['weather_code'];
        
        String condition = 'Clear';
        if (code == 1 || code == 2 || code == 3) condition = 'Cloudy';
        else if (code >= 45 && code <= 48) condition = 'Fog';
        else if (code >= 51 && code <= 67) condition = 'Rain';
        else if (code >= 71 && code <= 77) condition = 'Snow';
        else if (code >= 80 && code <= 82) condition = 'Rain showers';
        else if (code >= 95) condition = 'Thunderstorm';

        return WeatherModel(
          temp: (temp as num).toDouble(),
          humidity: (humidity as num).toInt(),
          condition: condition,
          description: city, // Displaying the detected city as description
        );
      }
    } catch (e) {
      debugPrint("Virtual weather fetch failed: $e, using fallback.");
    }
    
    return WeatherModel(temp: 28.0, humidity: 65, condition: 'Clear', description: 'Manila (Fallback)');
  }
}
