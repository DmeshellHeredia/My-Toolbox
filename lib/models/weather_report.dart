class WeatherReport {
  final DateTime date;
  final String updatedAt;
  final double temperature;
  final double feelsLike;
  final double maxTemperature;
  final double minTemperature;
  final double windSpeed;
  final int humidity;
  final int weatherCode;
  final int? rainProbability;
  final bool isDay;

  const WeatherReport({
    required this.date,
    required this.updatedAt,
    required this.temperature,
    required this.feelsLike,
    required this.maxTemperature,
    required this.minTemperature,
    required this.windSpeed,
    required this.humidity,
    required this.weatherCode,
    required this.rainProbability,
    required this.isDay,
  });

  factory WeatherReport.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;

    double number(Map<String, dynamic> data, String key) {
      final value = data[key];
      if (value is num) return value.toDouble();
      throw FormatException('Falta el campo $key');
    }

    double dailyNumber(String key) {
      final values = daily[key];
      if (values is List && values.isNotEmpty && values.first is num) {
        return (values.first as num).toDouble();
      }
      throw FormatException('Falta el campo diario $key');
    }

    final dates = daily['time'] as List<dynamic>;
    if (dates.isEmpty) {
      throw const FormatException('No hay fechas disponibles');
    }

    final rainValues = daily['precipitation_probability_max'];
    int? rainProbability;

    if (rainValues is List &&
        rainValues.isNotEmpty &&
        rainValues.first is num) {
      rainProbability = (rainValues.first as num).round();
    }

    return WeatherReport(
      date: DateTime.parse(dates.first as String),
      updatedAt: current['time'] as String,
      temperature: number(current, 'temperature_2m'),
      feelsLike: number(current, 'apparent_temperature'),
      maxTemperature: dailyNumber('temperature_2m_max'),
      minTemperature: dailyNumber('temperature_2m_min'),
      windSpeed: number(current, 'wind_speed_10m'),
      humidity: number(current, 'relative_humidity_2m').round(),
      weatherCode: number(current, 'weather_code').round(),
      rainProbability: rainProbability,
      isDay: number(current, 'is_day') == 1,
    );
  }

  String get condition {
    switch (weatherCode) {
      case 0:
        return 'Cielo despejado';
      case 1:
        return 'Mayormente despejado';
      case 2:
        return 'Parcialmente nublado';
      case 3:
        return 'Nublado';
      case 45:
      case 48:
        return 'Niebla';
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return 'Llovizna';
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
        return 'Lluvia';
      case 80:
      case 81:
      case 82:
        return 'Chubascos';
      case 95:
      case 96:
      case 99:
        return 'Tormenta eléctrica';
      default:
        return 'Condiciones variables';
    }
  }

  String get updateTime {
    final parts = updatedAt.split('T');
    return parts.length > 1 ? parts[1] : updatedAt;
  }
}
