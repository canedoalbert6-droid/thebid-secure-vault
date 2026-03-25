class WeatherModel {
  final double temp;
  final int humidity;
  final String condition;
  final String description;

  WeatherModel({
    required this.temp,
    required this.humidity,
    required this.condition,
    required this.description,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temp: (json['main']['temp'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      condition: json['weather'][0]['main'] as String,
      description: json['weather'][0]['description'] as String,
    );
  }
}
